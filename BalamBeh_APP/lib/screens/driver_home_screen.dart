import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Versión 2.0
import 'dart:async';
import '../services/route_service.dart';
import '../services/request_service.dart';

class DriverHomeScreen extends StatefulWidget {
  final int conductorId;
  final String conductorNombre;

  const DriverHomeScreen({
    super.key,
    required this.conductorId,
    required this.conductorNombre,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowAccent = const Color(0xFFF4D35E);
  final Color lightGreyBg = const Color(0xFFF5F5F5);

  // --- VARIABLES DEL MAPA ---
  final Completer<GoogleMapController> _mapController = Completer();

  // TU API KEY
  final String googleApiKey = "AIzaSyDFbZFR8SkoaVnXWIW7pEERmLU8zjhIXt8";

  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(20.2045, -89.2835),
    zoom: 14.5,
  );

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  bool _isTripActive = false;
  Timer? _requestTimer;
  int _selectedIndex = 0;
  int? _selectedRouteId;
  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _availableRoutes = [];

  @override
  void initState() {
    super.initState();
    _cargarRutasDesdeBD();
  }

  void _cargarRutasDesdeBD() async {
    final rutas = await RouteService.getRoutes();
    if (mounted) {
      setState(() {
        _availableRoutes = rutas;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _requestTimer?.cancel();
    super.dispose();
  }

  // --- FUNCIÓN CORREGIDA PARA LA NUEVA VERSIÓN ---
  void _trazarRutaEnMapa(int idRuta) async {
    setState(() => _isLoading = true);

    final puntosBD = await RouteService.getRoutePoints(idRuta);

    if (puntosBD.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    Set<Marker> nuevosMarcadores = {};
    List<LatLng> coordenadasCarretera = [];
    PolylinePoints polylinePoints = PolylinePoints();

    for (int i = 0; i < puntosBD.length; i++) {
      var puntoActual = puntosBD[i];
      LatLng posActual = LatLng(
        puntoActual['LATITUD'],
        puntoActual['LONGITUD'],
      );

      nuevosMarcadores.add(
        Marker(
          markerId: MarkerId(puntoActual['NOMBRE_PUEBLO']),
          position: posActual,
          infoWindow: InfoWindow(title: puntoActual['NOMBRE_PUEBLO']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0
                ? BitmapDescriptor.hueGreen
                : (i == puntosBD.length - 1
                      ? BitmapDescriptor.hueRed
                      : BitmapDescriptor.hueOrange),
          ),
        ),
      );

      if (i < puntosBD.length - 1) {
        var puntoSiguiente = puntosBD[i + 1];

        // --- AQUÍ ESTABA EL ERROR: CORREGIDO PARA V2.0 ---
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: googleApiKey, // Ahora es un parámetro nombrado
          request: PolylineRequest(
            // Ahora todo va dentro de 'request'
            origin: PointLatLng(
              puntoActual['LATITUD'],
              puntoActual['LONGITUD'],
            ),
            destination: PointLatLng(
              puntoSiguiente['LATITUD'],
              puntoSiguiente['LONGITUD'],
            ),
            mode: TravelMode.driving,
          ),
        );
        // ------------------------------------------------

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            coordenadasCarretera.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          // Fallback si no hay internet o ruta
          coordenadasCarretera.add(posActual);
          coordenadasCarretera.add(
            LatLng(puntoSiguiente['LATITUD'], puntoSiguiente['LONGITUD']),
          );
        }
      }
    }

    Polyline rutaLinea = Polyline(
      polylineId: const PolylineId("ruta_carretera"),
      points: coordenadasCarretera,
      color: Colors.blueAccent,
      width: 5,
    );

    setState(() {
      _polylines = {rutaLinea};
      _markers = nuevosMarcadores;
      _isLoading = false;
    });

    if (coordenadasCarretera.isNotEmpty) {
      final controller = await _mapController.future;
      LatLngBounds bounds = _calcularLimites(coordenadasCarretera);
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _calcularLimites(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _toggleViaje() async {
    if (!_isTripActive && _selectedRouteId == null) return;
    setState(() => _isSaving = true);
    Map<String, dynamic> result;

    if (_isTripActive) {
      result = await RouteService.endTrip(widget.conductorId);
      if (result['success'] == true) {
        _requestTimer?.cancel();
        setState(() => _isTripActive = false);
      }
    } else {
      result = await RouteService.startTrip(
        widget.conductorId,
        _selectedRouteId!,
      );
      if (result['success'] == true) {
        setState(() => _isTripActive = true);
        _startListeningForRequests();
      }
    }
    setState(() => _isSaving = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isTripActive ? "¡Viaje Iniciado!" : "Viaje Finalizado",
            ),
            backgroundColor: _isTripActive ? Colors.green : Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${result['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startListeningForRequests() {
    _requestTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isTripActive) {
        timer.cancel();
        return;
      }
      final solicitudes = await RequestService.checkPendingRequests(
        widget.conductorId,
      );
      if (solicitudes.isNotEmpty && mounted) {
        _requestTimer?.cancel();
        _showRequestDialog(solicitudes[0]);
      }
    });
  }

  void _showRequestDialog(Map<String, dynamic> solicitud) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.notifications_active, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text("Nueva Solicitud"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${solicitud['NOMBRE_CLIENTE']}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Solicita parada en tu ruta."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await RequestService.respondRequest(
                  solicitud['ID_SOLICITUD'],
                  'RECHAZADO',
                );
                _startListeningForRequests();
              },
              child: const Text(
                "Rechazar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                await RequestService.respondRequest(
                  solicitud['ID_SOLICITUD'],
                  'ACEPTADO',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cliente Aceptado"),
                    backgroundColor: Colors.green,
                  ),
                );
                _startListeningForRequests();
              },
              child: const Text("ACEPTAR PASAJERO"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Map<String, dynamic>? get _currentRouteData {
    if (_selectedRouteId == null) return null;
    return _availableRoutes.firstWhere(
      (r) => r['ID_RUTA'] == _selectedRouteId,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _currentRouteData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. MAPA REAL
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicionInicial,
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_mapController.isCompleted)
                  _mapController.complete(controller);
              },
            ),
          ),

          // 2. HEADER
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola,",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.conductorNombre,
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: lightGreyBg,
                        child: Icon(Icons.person, color: darkBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(Icons.circle, color: Colors.blue, size: 12),
                          Container(
                            height: 25,
                            width: 2,
                            color: Colors.grey[300],
                          ),
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLocationRow(
                              currentRoute != null && currentRoute.isNotEmpty
                                  ? "Ruta Activa:"
                                  : "Sin ruta asignada",
                              isHint:
                                  currentRoute == null || currentRoute.isEmpty,
                            ),
                            const Divider(height: 25),
                            _buildLocationRow(
                              currentRoute != null && currentRoute.isNotEmpty
                                  ? currentRoute['NOMBRE_RUTA']
                                  : "Selecciona abajo...",
                              isHint:
                                  currentRoute == null || currentRoute.isEmpty,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. PANEL INFERIOR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Iniciar Turno",
                    style: TextStyle(
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(color: yellowAccent),
                    )
                  else ...[
                    Text(
                      "Selecciona la ruta que cubrirás hoy:",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreyBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedRouteId,
                          isExpanded: true,
                          hint: Text(
                            "Toca para elegir ruta...",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: darkBlue,
                          ),
                          items: _availableRoutes
                              .map(
                                (ruta) => DropdownMenuItem<int>(
                                  value: ruta['ID_RUTA'],
                                  child: Text(
                                    ruta['NOMBRE_RUTA'],
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isTripActive
                              ? null
                              : (nuevoValor) {
                                  setState(() => _selectedRouteId = nuevoValor);
                                  if (nuevoValor != null)
                                    _trazarRutaEnMapa(nuevoValor);
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            (_isSaving ||
                                (_selectedRouteId == null && !_isTripActive))
                            ? null
                            : _toggleViaje,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTripActive
                              ? Colors.redAccent
                              : yellowAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isTripActive
                                    ? "TERMINAR VIAJE"
                                    : "COMENZAR VIAJE",
                                style: TextStyle(
                                  color: _isTripActive
                                      ? Colors.white
                                      : (_selectedRouteId == null
                                            ? Colors.grey
                                            : darkBlue),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        selectedItemColor: darkBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String text, {bool isHint = false}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isHint ? Colors.blue : Colors.black87,
      ),
    );
  }
}
