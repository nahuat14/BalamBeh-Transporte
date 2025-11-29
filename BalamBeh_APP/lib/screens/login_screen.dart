import 'package:flutter/material.dart';

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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                      fontWeight: FontWeight.w900, // Extra grueso
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
                        // AQUÍ EL CAMBIO: Usamos w900 (Black) para que se vea bien gordo
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
                        letterSpacing:
                            -0.5, // Un poco más pegadito como Poppins
                      ),
                    ),
                    Text(
                      "Inicia sesion",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300, // Light
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

              // --- BOTÓN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesion",
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
                        Navigator.pushNamed(context, '/registerDriver');
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
