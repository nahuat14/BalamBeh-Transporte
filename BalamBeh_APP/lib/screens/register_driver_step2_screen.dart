import 'package:flutter/material.dart';

class RegisterDriverStep2Screen extends StatefulWidget {
  const RegisterDriverStep2Screen({super.key});

  @override
  State<RegisterDriverStep2Screen> createState() =>
      _RegisterDriverStep2ScreenState();
}

class _RegisterDriverStep2ScreenState extends State<RegisterDriverStep2Screen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);

  // Controladores
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Función para mostrar el calendario
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Por defecto hace 18 años
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      // Personalizamos el color del calendario para que combine con la app
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: darkBlue, // Cabecera azul
              onPrimary: Colors.white,
              onSurface: darkBlue, // Texto números
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkBlue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formateamos la fecha como DD/MM/AAAA
        _ageController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
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
                  Expanded(
                    child: Text(
                      "BalamBeh-Conductores",
                      style: TextStyle(
                        fontSize: 18,
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
                      "Datos personales",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- 3. FORMULARIO ---

              // Campo Edad (Con Calendario)
              _buildCustomInput(
                hintText: "Edad (Fecha de nacimiento)",
                controller: _ageController,
                isReadOnly: true, // No se puede escribir, solo seleccionar
                onTap: () => _selectDate(context),
                suffixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 15),

              // Campo Localidad
              _buildCustomInput(
                hintText: "Localidad",
                controller: _locationController,
              ),
              const SizedBox(height: 15),

              // Campo RFC
              _buildCustomInput(
                hintText: "RFC",
                controller: _rfcController,
                textCapitalization:
                    TextCapitalization.characters, // Mayúsculas automático
              ),
              const SizedBox(height: 15),

              // Campo Teléfono
              _buildCustomInput(
                hintText: "Numero de telefono",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 40),

              // --- 4. BOTÓN SIGUIENTE PASO ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí iría la lógica para el siguiente paso (vehículo) o finalizar
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/registerDriverStep3',
                      (route) => false,
                    );
                  },
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

              // --- 5. FOOTER ---
              Center(
                child: TextButton(
                  onPressed: () {
                    // Regresar al login
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text(
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

  // Widget Input Personalizado
  Widget _buildCustomInput({
    required String hintText,
    required TextEditingController controller,
    bool isReadOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
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
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: darkBlue.withOpacity(0.5))
            : null,
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
