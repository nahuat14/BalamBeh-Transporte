import 'package:flutter/material.dart';
import 'dart:async'; // Necesario para el temporizador

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Temporizador: Espera 3 segundos y va al Login
    Timer(const Duration(seconds: 3), () {
      // OJO: Aquí intentará ir a '/login'.
      // Si aún no tienes la pantalla de Login creada, esto dará error al ejecutarse.
      // Por ahora, solo queremos ver el Splash.
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset(
              'assets/images/logo.png',
              width: size.width * 0.5, // 50% del ancho de pantalla
            ),

            const SizedBox(height: 20),

            // TEXTO
            Text(
              "BalamBeh",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 40),

            // INDICADOR DE CARGA
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
