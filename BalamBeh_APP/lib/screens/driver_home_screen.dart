import 'package:flutter/material.dart';

// Clase simple para almacenar los datos de una ruta (Prototipo)
class RouteData {
  final String name;
  final int seats;

  RouteData({required this.name, required this.seats});
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowAccent = const Color(0xFFF4D35E);
  final Color lightGreyBg = const Color(0xFFF5F5F5);

  int _selectedIndex = 0;

  // --- ESTADO PARA EL MANEJO DE RUTAS ---
  bool _isCreatingRoute = false; // ¿Estamos en la pantalla de crear?
  bool _isSelectingRoute = false; // ¿Estamos en la pantalla de seleccionar?

  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  // Lista para almacenar las rutas creadas en memoria
  final List<RouteData> _createdRoutes = [];

  // Ruta seleccionada actualmente
  RouteData? _selectedRoute;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función para guardar una nueva ruta
  void _saveRoute() {
    if (_routeNameController.text.isNotEmpty &&
        _seatsController.text.isNotEmpty) {
      setState(() {
        // Agregamos la ruta a la lista
        _createdRoutes.add(
          RouteData(
            name: _routeNameController.text,
            seats: int.tryParse(_seatsController.text) ?? 0,
          ),
        );
        // Limpiamos los campos y volvemos a la vista normal
        _routeNameController.clear();
        _seatsController.clear();
        _isCreatingRoute = false;

        // Opcional: Mostrar un mensaje de éxito
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ruta creada con éxito')));
      });
    }
  }

  // Función para seleccionar una ruta de la lista
  void _selectRoute(RouteData route) {
    setState(() {
      _selectedRoute = route;
      _isSelectingRoute = false; // Volvemos a la vista normal
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // 1. MAPA DE FONDO (Simulado)
          Container(
            color: Colors.grey[200],
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                  Text(
                    "Mapa de Google Maps aquí",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),

          // 2. CABECERA FLOTANTE (Saludo y Ruta)
          SafeArea(
            child: Column(
              children: [
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saludo y Perfil
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
                                "Tester_User",
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

                      // Selector de Ruta (Muestra la ruta seleccionada o el default)
                      Row(
                        children: [
                          // Columna de Iconos
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

                          // Columna de Textos (Origen y Destino)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Si hay ruta seleccionada, mostramos "Ruta Activa", si no, "Tu ubicación"
                                _buildLocationRow(
                                  _selectedRoute != null
                                      ? "Ruta Activa:"
                                      : "Tu ubicación",
                                  isHint: _selectedRoute == null,
                                ),
                                const Divider(height: 25),
                                // Si hay ruta seleccionada, mostramos su nombre, si no, "Destino"
                                _buildLocationRow(
                                  _selectedRoute != null
                                      ? _selectedRoute!.name
                                      : "Destino",
                                  isHint: _selectedRoute == null,
                                ),
                              ],
                            ),
                          ),

                          // Columna de Acciones
                          Column(
                            children: [
                              Icon(Icons.more_horiz, color: Colors.grey),
                              const SizedBox(height: 20),
                              Icon(Icons.swap_vert, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                      // Mostrar asientos si hay ruta seleccionada
                      if (_selectedRoute != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 30),
                          child: Text(
                            "Capacidad: ${_selectedRoute!.seats} asientos",
                            style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. PANEL INFERIOR DINÁMICO
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              // Usamos AnimatedContainer para una transición suave
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              // Aquí cambiamos el contenido según el estado
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- ESTADO 1: CREANDO RUTA ---
                  if (_isCreatingRoute) ...[
                    Text(
                      "Crear Nueva Ruta",
                      style: TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRouteInput(
                      hintText: "Nombre de la ruta (Ej. Peto-Tekax)",
                      controller: _routeNameController,
                    ),
                    _buildRouteInput(
                      hintText: "Número de asientos",
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellowAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Guardar Ruta",
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => _isCreatingRoute = false,
                      ), // Botón cancelar
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    // --- ESTADO 2: SELECCIONANDO RUTA ---
                  ] else if (_isSelectingRoute) ...[
                    Text(
                      "Seleccionar Ruta",
                      style: TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_createdRoutes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          "No has creado ninguna ruta.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 250,
                        ), // Altura máxima para la lista
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _createdRoutes.length,
                          itemBuilder: (context, index) {
                            final route = _createdRoutes[index];
                            return Card(
                              elevation: 0,
                              color: lightGreyBg,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  route.name,
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text("${route.seats} asientos"),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: darkBlue,
                                ),
                                onTap: () =>
                                    _selectRoute(route), // Seleccionar al tocar
                              ),
                            );
                          },
                        ),
                      ),
                    TextButton(
                      onPressed: () => setState(
                        () => _isSelectingRoute = false,
                      ), // Botón cancelar
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    // --- ESTADO 3: VISTA NORMAL (BOTONES) ---
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          "Crear nueva\nRuta",
                          onTap: () => setState(() {
                            _isCreatingRoute = true;
                            _isSelectingRoute = false;
                          }),
                        ),
                        _buildActionButton(
                          "Seleccionar\nRuta",
                          onTap: () => setState(() {
                            _isSelectingRoute = true;
                            _isCreatingRoute = false;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Botón Ruta Rápida (Sin función por ahora)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Ruta Rapida",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

      // Barra de Navegación
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

  // --- WIDGETS AUXILIARES ---

  // Widget para las filas de texto en la cabecera
  Widget _buildLocationRow(String text, {bool isHint = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isHint ? Colors.blue : Colors.black87,
      ),
    );
  }

  // Widget para los botones circulares con acción
  Widget _buildActionButton(String label, {required VoidCallback onTap}) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: yellowAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add, color: darkBlue, size: 30),
          ),
        ),
      ],
    );
  }

  // Widget para los inputs del formulario de crear ruta
  Widget _buildRouteInput({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: darkBlue),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: lightGreyBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
