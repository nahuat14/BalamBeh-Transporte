import 'package:flutter/material.dart';
import 'package:balanbeh_transporte/screens/register_driver_step2_screen.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void _goToStep2() {
    String nombre = _nameController.text.trim();
    String user = _userController.text.trim();
    String pass = _passController.text.trim();
    String confirm = _confirmPassController.text.trim();

    // 1. Validaciones
    if (nombre.isEmpty || user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña es muy corta (mín. 6)")),
      );
      return;
    }

    // 2. Empaquetar Datos
    final step1Data = {'nombre': nombre, 'username': user, 'contraseña': pass};

    // 3. Ir al Paso 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterDriverStep2Screen(receivedData: step1Data),
      ),
    );
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
              // --- 1. CABECERA ---
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.location_on, color: darkBlue, size: 40),
                  ),
                  const SizedBox(width: 10),
                  // En la imagen dice "BalamBeh-Conductores"
                  Expanded(
                    // Usamos Expanded para evitar desbordamiento si el texto es largo
                    child: Text(
                      "BalamBeh-Conductores",
                      style: TextStyle(
                        fontSize: 18, // Un poco más chico para que quepa
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.04),

              // --- 2. TÍTULOS ---
              Center(
                child: Column(
                  children: [
                    Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Datos personales", // Cambio respecto al registro de usuario
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

              // --- 4. BOTÓN SIGUIENTE PASO ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _goToStep2,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Siguiente paso",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 5. FOOTER (Regresar al login) ---
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Regresa atrás
                  },
                  child: Text(
                    "regresar al login",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Input (Cápsula)
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
