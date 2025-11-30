import 'package:flutter/material.dart';
import 'dart:io'; // Necesario para manejar el archivo de la imagen
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes
import 'package:balanbeh_transporte/services/auth_service.dart';

class RegisterDriverStep3Screen extends StatefulWidget {
  final Map<String, dynamic> receivedData;

  const RegisterDriverStep3Screen({super.key, required this.receivedData});

  @override
  State<RegisterDriverStep3Screen> createState() =>
      _RegisterDriverStep3ScreenState();
}

class _RegisterDriverStep3ScreenState extends State<RegisterDriverStep3Screen> {
  // --- PALETA DE COLORES ---
  final Color darkBlue = const Color(0xFF0D3B66);
  final Color yellowBorder = const Color(0xFFF4D35E);
  final Color lightGreyFill = const Color(0xFFF5F5F5);

  // Controladores
  final TextEditingController _marcaModeloController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  // Variable para guardar la foto de la tarjeta de circulación
  File? _tarjetaCirculacionImage;
  final ImagePicker _picker = ImagePicker();

  // Función para seleccionar imagen de la galería
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Puedes cambiar a ImageSource.camera
        maxWidth: 800, // Reducir tamaño para que no pese tanto
      );
      if (pickedFile != null) {
        setState(() {
          _tarjetaCirculacionImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Manejar error si no se puede abrir la galería
      print("Error al seleccionar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo seleccionar la imagen')),
      );
    }
  }

  void _finishRegister() async {
    if (_marcaModeloController.text.isEmpty ||
        _anioController.text.isEmpty ||
        _tipoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faltan datos del vehículo")),
      );
      return;
    }

    // Armamos el paquete final
    final finalData = Map<String, dynamic>.from(widget.receivedData);
    finalData['vehiculo'] = _marcaModeloController.text.trim();
    finalData['año_vehiculo'] = _anioController.text.trim();
    finalData['tipo_vehiculo'] = _tipoController.text.trim();
    // Por ahora mandamos null porque el backend espera string/url, no bytes de imagen aun
    finalData['tarjeta_circulacion_url'] = null;

    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Llamada al servidor
    final result = await AuthService.registerConductor(finalData);

    if (context.mounted) Navigator.pop(context); // Quitar loading

    if (result['success']) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Registro Exitoso!"),
            backgroundColor: Colors.green,
          ),
        );
        // Volver al inicio (Login)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
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
                      "Datos del vehículo",
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

              // --- 3. FORMULARIO ---

              // Campo Marca y Modelo
              _buildCustomInput(
                hintText: "Marca y Modelo (Ej. Nissan Versa)",
                controller: _marcaModeloController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),

              // Campo Año
              _buildCustomInput(
                hintText: "Año del vehículo",
                controller: _anioController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Campo Tipo de Vehículo
              _buildCustomInput(
                hintText: "Tipo de vehículo (Sedán, SUV...)",
                controller: _tipoController,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 25),

              // --- SELECTOR DE TARJETA DE CIRCULACIÓN (IMAGEN) ---
              Text(
                "Tarjeta de circulación",
                style: TextStyle(color: darkBlue, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage, // Al tocar, abre la galería
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightGreyFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: yellowBorder, width: 1.0),
                  ),
                  child: _tarjetaCirculacionImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _tarjetaCirculacionImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: darkBlue, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Toca para subir una foto",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // --- 4. BOTÓN FINALIZAR REGISTRO ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _finishRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Finalizar registro",
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
                      '/loginDriver',
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

  // Widget Input Personalizado (Mismo de siempre)
  Widget _buildCustomInput({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
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
