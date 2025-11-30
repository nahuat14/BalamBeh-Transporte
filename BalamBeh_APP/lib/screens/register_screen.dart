import 'package:flutter/material.dart';
import 'package:balanbeh_transporte/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);
  final Color linkColor = const Color(0xFFEAA900);

  // Controladores para los 4 campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void _handleRegister() async {
    final nombre = _nameController.text.trim();
    final username = _userController.text.trim();
    final password = _passController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    // 1. Validaciones Locales
    if (nombre.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      _showMessage("Por favor completa todos los campos", Colors.orange);
      return;
    }

    if (password != confirmPass) {
      _showMessage("Las contraseñas no coinciden", Colors.red);
      return;
    }

    if (password.length < 6) {
      _showMessage(
        "La contraseña debe tener al menos 6 caracteres",
        Colors.orange,
      );
      return;
    }

    // 2. Mostrar Carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 3. Llamar al Backend
    final result = await AuthService.registerClient(nombre, username, password);

    // Cerrar carga
    if (context.mounted) Navigator.of(context).pop();

    // 4. Manejar Respuesta
    if (result['success']) {
      if (context.mounted) {
        _showMessage("¡Cuenta creada! Inicia sesión ahora.", Colors.green);
        // Esperar un poquito para que el usuario lea el mensaje
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          // Volver al Login para que ingresen sus credenciales
          Navigator.pop(context);
        }
      }
    } else {
      if (context.mounted) {
        _showMessage(result['message'] ?? "Error en el registro", Colors.red);
      }
    }
  }

  // Método auxiliar para mostrar Snackbars
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
              // --- 1. CABECERA (Igual al login) ---
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.location_on, color: darkBlue, size: 40),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "BalamBeh",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.04,
              ), // Espacio un poco menor para que quepa todo
              // --- 2. TÍTULOS ---
              Center(
                child: Column(
                  children: [
                    Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900, // Extra Bold
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Complete los campos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300, // Light
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- 3. FORMULARIO (4 Campos) ---
              _buildCustomInput(
                hintText: "Nombre completo",
                controller: _nameController,
                obscureText: false,
              ),
              const SizedBox(height: 15),

              _buildCustomInput(
                hintText: "Usuario",
                controller: _userController,
                obscureText: false,
              ),
              const SizedBox(height: 15),

              _buildCustomInput(
                hintText: "Crear contraseña",
                controller: _passController,
                obscureText: true,
              ),
              const SizedBox(height: 15),

              _buildCustomInput(
                hintText: "Confirmar contraseña",
                controller: _confirmPassController,
                obscureText: true,
              ),

              const SizedBox(height: 40),

              // --- 4. BOTÓN CREAR CUENTA ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleRegister,

                  //{
                  //Navigator.pushReplacementNamed(context, '/home');
                  //},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Cápsula
                    ),
                  ),
                  child: const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 5. FOOTER ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿Eres conductor? ",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/registerDriver');
                      },
                      child: Text(
                        "Crear cuenta aquí",
                        style: TextStyle(
                          fontSize: 13,
                          color: linkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón extra para volver al login si se equivocaron
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Vuelve atrás (al Login)
                  },
                  child: Text(
                    "Volver al inicio de sesión",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // El mismo widget de input estilo cápsula
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
}
