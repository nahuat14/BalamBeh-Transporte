import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  // Mantenemos la variable userName que ya tenías
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

  int _selectedIndex = 0;

  // Controlador para leer lo que escribe el usuario
  final TextEditingController _searchController = TextEditingController();

  // --- 1. DATOS SIMULADOS DE RUTAS ---
  final List<Map<String, dynamic>> availableRoutes = [
    {
      "destino": "Oxkutzcab",
      "origen": "Peto",
      "asientos": 10,
      "nombre_ruta": "Peto-Oxkutzcab",
    },
    {
      "destino": "Merida",
      "origen": "Peto",
      "asientos": 8,
      "nombre_ruta": "Peto-Merida",
    },
    {
      "destino": "Tekax",
      "origen": "Peto",
      "asientos": 12,
      "nombre_ruta": "Peto-Tekax",
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 2. LÓGICA DE BÚSQUEDA ---
  void _searchRoute(String query) {
    // Quitamos el foco (cierra el teclado)
    FocusScope.of(context).unfocus();

    if (query.isEmpty) return;

    // Buscamos en la lista si el destino coincide
    final Map<String, dynamic> foundRoute = availableRoutes.firstWhere(
      (route) =>
          route['destino'].toString().toLowerCase() == query.toLowerCase(),
      orElse: () => {},
    );

    if (foundRoute.isNotEmpty) {
      _showResultCard(foundRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se encontraron rutas hacia '$query'"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- 3. MOSTRAR TARJETA DE RESULTADO ---
  void _showResultCard(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TARJETA BLANCA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Título Naranja
                    Text(
                      "Transporte encontrado",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COLUMNA IZQUIERDA
                        Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              route['nombre_ruta'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),

                        // COLUMNA DERECHA
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parada
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Arial',
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Parada : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: route['destino']),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Asientos
                              const Text(
                                "Asientos disponibles:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${route['asientos']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // BOTÓN SOLICITAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Solicitud enviada al conductor!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Solicitar lugar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // 1. CABECERA Y BARRA DE BÚSQUEDA INTEGRADA
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w400, // Light
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900, // Extra Bold
                              color: darkBlue,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: lightGreyBg,
                        child: Icon(Icons.person, color: darkBlue, size: 30),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // CAMBIO PRINCIPAL: TextField directo en lugar de GestureDetector
                  Container(
                    decoration: BoxDecoration(
                      color: lightGreyBg,
                      borderRadius: BorderRadius.circular(30), // Cápsula
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textInputAction: TextInputAction
                          .search, // Muestra botón "Buscar" en teclado
                      decoration: InputDecoration(
                        hintText: "¿A dónde vas?",
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: darkBlue,
                          size: 28,
                        ),
                        border: InputBorder
                            .none, // Quitamos borde del input para usar el del Container
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: (value) {
                        // Se ejecuta al presionar Enter/Buscar en el teclado
                        _searchRoute(value.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. MAPA DE FONDO (Simulado)
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Mapa de Google Maps aquí",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: darkBlue,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
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
      ),
    );
  }
}
