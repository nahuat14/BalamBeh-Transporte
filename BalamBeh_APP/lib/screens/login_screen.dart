import 'package:flutter/material.dart';
import 'package:balanbeh_transporte/services/auth_service.dart'; // Tu ruta de servicio
import 'home_screen.dart'; // <--- 1. IMPORTANTE: Importamos el Home

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- 1. PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);
  final Color linkColor = const Color(0xFFEAA900);

  // Nota: Usamos emailController para capturar el "usuario"
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Función para manejar el login
  void _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validación básica
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor llena todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 3. Llamada al Servicio
    final result = await AuthService.loginClient(username, password);

    // Cerrar el indicador de carga
    if (context.mounted) Navigator.of(context).pop();

    // 4. Procesar respuesta
    if (result['success']) {
      if (context.mounted) {
        // --- AQUÍ CAPTURAMOS EL NOMBRE DEL CLIENTE ---
        // El backend nos manda: {'success': true, 'data': {'nombre': 'Juan', ...}}
        final data = result['data'];
        // Si por alguna razón el nombre viene vacío, ponemos "Cliente" por defecto
        final String nombreCliente = data['nombre'] ?? "Cliente";

        // --- NAVEGAMOS AL HOME ENVIANDO EL NOMBRE ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // Le pasamos el nombre a la pantalla Home
            builder: (context) => HomeScreen(userName: nombreCliente),
          ),
        );
      }
    } else {
      // ERROR: Mostrar mensaje
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Error desconocido"),
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 45,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.location_on, color: darkBlue, size: 45);
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "BalamBeh",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: darkBlue,
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
                controller: _emailController,
                obscureText: false,
              ),

              const SizedBox(height: 25),

              _buildCustomInput(
                hintText: "Contraseña",
                controller: _passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 60),

              // --- BOTÓN LOGIN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleLogin, // <--- Llamada a la función
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
                    _buildFooterLink(
                      question: "¿Eres conductor? ",
                      action: "Inicia sesión aquí",
                      onTap: () {
                        Navigator.pushNamed(context, '/loginDriver');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildFooterLink(
                      question: "¿No tienes cuenta? ",
                      action: "Regístrate",
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
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
    return Container(
      decoration: BoxDecoration(
        color: lightGreyFill,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink({
    required String question,
    required String action,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: question,
          style: TextStyle(color: darkBlue, fontSize: 16),
          children: [
            TextSpan(
              text: action,
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
