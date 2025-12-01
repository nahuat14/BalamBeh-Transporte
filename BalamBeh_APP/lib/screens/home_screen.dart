import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import '../services/passenger_service.dart';
import '../services/request_service.dart';
import '../services/route_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowAccent = const Color(0xFFF4D35E);
  final Color lightGreyBg = const Color(0xFFF5F5F5);

  // --- VARIABLES DEL MAPA ---
  final Completer<GoogleMapController> _mapController = Completer();
  final String googleApiKey = "AIzaSyDFbZFR8SkoaVnXWIW7pEERmLU8zjhIXt8";

  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(20.2045, -89.2835), // Tekax
    zoom: 14.5,
  );

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  int _selectedIndex = 0;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  // --- VARIABLES PARA LA INTERFAZ ---
  bool _showRouteInfoPanel = false;
  String _routeName = "";
  String _passengerDestination = "";

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- FUNCIÓN STOP ---
  void _stopRouteTracking() {
    setState(() {
      _showRouteInfoPanel = false;
      _polylines.clear();
      _markers.clear();
      _searchController.clear();
      _routeName = "";
      _passengerDestination = "";
    });
    // Regresamos el padding del mapa a 0
    _mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(_posicionInicial),
      );
    });
  }

  // --- DIBUJAR RUTA ---
  void _trazarRutaDelViaje(int idRuta) async {
    final puntosBD = await RouteService.getRoutePoints(idRuta);
    if (puntosBD.isEmpty) return;

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
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      if (i < puntosBD.length - 1) {
        var puntoSiguiente = puntosBD[i + 1];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: googleApiKey,
          request: PolylineRequest(
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

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            coordenadasCarretera.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          coordenadasCarretera.add(posActual);
          coordenadasCarretera.add(
            LatLng(puntoSiguiente['LATITUD'], puntoSiguiente['LONGITUD']),
          );
        }
      }
    }

    Polyline rutaLinea = Polyline(
      polylineId: const PolylineId("ruta_asignada"),
      points: coordenadasCarretera,
      color: Colors.blueAccent,
      width: 5,
    );

    setState(() {
      _polylines = {rutaLinea};
      _markers = nuevosMarcadores;
    });

    if (coordenadasCarretera.isNotEmpty) {
      final controller = await _mapController.future;
      LatLngBounds bounds = _calcularLimites(coordenadasCarretera);
      // Ajustamos el zoom con padding extra abajo para que el panel no tape la ruta
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

  void _searchRoute(String query) async {
    FocusScope.of(context).unfocus();
    if (query.isEmpty) return;

    setState(() {
      _passengerDestination = query;
      _isLoading = true;
    });

    final List<Map<String, dynamic>> resultados =
        await PassengerService.buscarVans(query);

    setState(() => _isLoading = false);

    if (resultados.isNotEmpty) {
      _showResultDialog(resultados);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No hay conductores activos en '$query' ahora."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _iniciarProcesoDeSolicitud(
    int idViaje,
    int idRuta,
    String routeName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final int? idSolicitud = await RequestService.createRequest(
      idViaje,
      1,
      widget.userName,
    );

    Navigator.pop(context);

    if (idSolicitud != null) {
      _mostrarDialogoEspera(idSolicitud, idRuta, routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al enviar solicitud"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoEspera(int idSolicitud, int idRuta, String routeName) {
    Timer? timerEspera;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        timerEspera = Timer.periodic(const Duration(seconds: 3), (timer) async {
          String estado = await RequestService.checkStatus(idSolicitud);

          if (estado == 'ACEPTADO') {
            timer.cancel();
            Navigator.pop(dialogContext);
            _mostrarExito();

            setState(() {
              _showRouteInfoPanel = true;
              _routeName = routeName;
            });
            _trazarRutaDelViaje(idRuta);
          } else if (estado == 'RECHAZADO') {
            timer.cancel();
            Navigator.pop(dialogContext);
            _mostrarRechazo();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Esperando confirmación...",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  timerEspera?.cancel();
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => timerEspera?.cancel());
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text("¡Solicitud Aceptada!"),
        content: const Text("El conductor ha confirmado tu lugar."),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
            child: const Text(
              "Ver Mapa",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarRechazo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Solicitud rechazada."),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showResultDialog(List<Map<String, dynamic>> vans) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Transporte encontrado",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Estas unidades pasan por tu zona:",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vans.length,
                    itemBuilder: (context, index) {
                      return _buildVanItem(vans[index]);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVanItem(Map<String, dynamic> van) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightGreyBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  van['NOMBRE_RUTA'] ?? "Ruta",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Conductor: ${van['CONDUCTOR']}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _iniciarProcesoDeSolicitud(
                        van['ID_VIAJE'],
                        van['ID_RUTA'] ?? 1,
                        van['NOMBRE_RUTA'] ?? "Ruta",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Solicitar",
                      style: TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE PANELES ---

  // 1. Barra de Búsqueda (Arriba)
  Widget _buildSearchPanel() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola,",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
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
            const SizedBox(height: 15),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "¿A dónde vas?",
                filled: true,
                fillColor: lightGreyBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: darkBlue),
                suffixIcon: _isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onSubmitted: (val) => _searchRoute(val.trim()),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Panel de Ruta (Abajo)
  Widget _buildRouteInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "INFORMACION DE LA RUTA",
            style: TextStyle(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _routeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Parada: $_passengerDestination",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _stopRouteTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(
                        Icons.stop_circle_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "STOP",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAPA (FONDO)
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _posicionInicial,
            polylines: _polylines,
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // AQUÍ ESTÁ EL TRUCO: Padding abajo si el panel está activo
            padding: EdgeInsets.only(
              bottom: _showRouteInfoPanel
                  ? 200
                  : 0, // Sube el mapa cuando sale el panel
              top: _showRouteInfoPanel
                  ? 0
                  : 180, // Baja el mapa si está la barra de búsqueda
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),

          // 2. PANEL DE BÚSQUEDA (ARRIBA) - Solo si NO estamos en ruta
          if (!_showRouteInfoPanel)
            Positioned(top: 0, left: 0, right: 0, child: _buildSearchPanel()),

          // 3. PANEL DE RUTA (ABAJO) - Solo si ESTAMOS en ruta
          if (_showRouteInfoPanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildRouteInfoPanel(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: darkBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
