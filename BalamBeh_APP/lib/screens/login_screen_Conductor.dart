import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// 1. IMPORTA LA PANTALLA CORRECTA
import 'driver_home_screen.dart';

class LoginScreen_Conductor extends StatefulWidget {
  const LoginScreen_Conductor({super.key});

  @override
  State<LoginScreen_Conductor> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen_Conductor> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);
  final Color linkColor = const Color(0xFFEAA900);

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LÓGICA DE LOGIN ---
  // --- LÓGICA DE LOGIN ---
  void _handleLogin() async {
    final username = _userController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validaciones básicas
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena todos los campos")),
      );
      return;
    }

    // 2. Mostrar círculo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 3. LLAMADA AL SERVIDOR (AuthService)
    final result = await AuthService.loginConductor(username, password);

    // Cerrar el círculo de carga (Checkeamos mounted por seguridad)
    if (context.mounted) Navigator.of(context).pop();

    // 4. Verificar resultado
    if (result['success']) {
      if (context.mounted) {
        // --- AQUÍ CAPTURAMOS LOS DATOS DE PYTHON ---
        final data = result['data'];

        // A. OBTENEMOS EL ID (Con seguridad por si viene como String o Int)
        // Esto evita errores si el backend manda "5" en vez de 5
        final int idConductor = int.parse(data['id_conductor'].toString());

        // B. OBTENEMOS EL NOMBRE (EL FIX DEL ERROR ROJO)
        // Si data['nombre'] es null, usamos "Conductor" por defecto
        final String nombreConductor =
            data['nombre']?.toString() ?? "Conductor";

        // 5. NAVEGAR PASANDO LOS DATOS
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverHomeScreen(
              conductorId: idConductor, // <--- Dato vital para registrar viajes
              conductorNombre: nombreConductor, // <--- Dato para el saludo
            ),
          ),
        );
      }
    } else {
      // Si falló (contraseña mal o error de conexión)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Error al iniciar sesión"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA ---
              Row(
                children: [
                  // Icono o Logo
                  Icon(Icons.directions_bus, color: darkBlue, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "BalamBeh Conductores",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.06),

              // --- TÍTULOS ---
              Center(
                child: Column(
                  children: [
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Inicia sesión",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- INPUTS ---
              _buildCustomInput(
                hintText: "Usuario",
                controller: _userController,
                obscureText: false,
              ),

              const SizedBox(height: 25),

              _buildCustomInput(
                hintText: "Contraseña",
                controller: _passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 60),

              // --- BOTÓN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  // AQUÍ EL CAMBIO IMPORTANTE: Usamos _handleLogin
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- FOOTER ---
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildFooterLink(
                      question: "¿No tienes cuenta? ",
                      action: "Regístrate",
                      onTap: () {
                        // Asegúrate que esta ruta exista en tu main.dart
                        Navigator.pushNamed(context, '/registerDriver');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: darkBlue, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: lightGreyFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: yellowBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: darkBlue, width: 2.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildFooterLink({
    required String question,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              fontSize: 13,
              color: linkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
