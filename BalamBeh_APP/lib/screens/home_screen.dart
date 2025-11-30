import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  // 1. Agregamos la variable para recibir el nombre
  final String userName;

  // 2. Exigimos el nombre en el constructor
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowAccent = const Color(0xFFF4D35E);
  final Color lightGreyBg = const Color(0xFFF5F5F5);

  // Índice para controlar la barra de navegación inferior
  int _selectedIndex = 0;

  // Función para cambiar de pestaña en la barra inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí iría la lógica para cambiar de pantalla (ej. ir a Historial)
      // Por ahora solo cambia el icono seleccionado visualmente.
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      // --- CUERPO PRINCIPAL ---
      body: SafeArea(
        child: Column(
          children: [
            // 1. CABECERA Y BARRA DE BÚSQUEDA
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                // Sombra suave abajo para separar la cabecera del mapa
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
                            widget.userName, // Nombre del usuario
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900, // Extra Bold
                              color: darkBlue,
                            ),
                          ),
                        ],
                      ),
                      // Icono de Perfil (Círculo con inicial o foto)
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: lightGreyBg,
                        child: Icon(Icons.person, color: darkBlue, size: 30),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Barra de Búsqueda "¿A dónde vas?"
                  GestureDetector(
                    onTap: () {
                      // Acción futura: Abrir pantalla de búsqueda de destino
                      print("Abrir búsqueda");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreyBg,
                        borderRadius: BorderRadius.circular(30), // Cápsula
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ), // Borde sutil
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: darkBlue, size: 28),
                          const SizedBox(width: 15),
                          Text(
                            "¿A dónde vas?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. MAPA DE FONDO (Simulado)
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200], // Color gris simulando el mapa
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
              offset: const Offset(0, -5), // Sombra hacia arriba
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation:
              0, // Quitamos la elevación por defecto para usar nuestra sombra
          selectedItemColor: darkBlue, // Color del icono activo
          unselectedItemColor: Colors.grey[400], // Color de los inactivos
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType
              .fixed, // Para que quepan bien 3 o más iconos
          currentIndex: _selectedIndex, // Controla cuál está activo
          onTap: _onItemTapped, // Función al tocar
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
