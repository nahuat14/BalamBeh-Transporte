import 'package:flutter/material.dart';

// 1. IMPORTAMOS TUS PANTALLAS
// Asegúrate de que el archivo se llame 'splash_screen.dart' en la carpeta screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_screen_Conductor.dart';
import 'screens/register_screen.dart';

import 'screens/register_driver_screen.dart';
import 'screens/home_screen.dart';

import 'screens/driver_home_screen.dart';

void main() {
  runApp(const MiAppTransporte());
}

class MiAppTransporte extends StatelessWidget {
  const MiAppTransporte({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BalamBeh',
      debugShowCheckedModeBanner: false,

      // TEMA GLOBAL (Colores)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B66), // Azul BalamBeh
          primary: const Color(0xFF0D3B66),
          secondary: const Color(0xFFF4D35E), // Amarillo BalamBeh
          // CORRECCIÓN: 'background' estaba obsoleto, ahora se usa 'surface'
          surface: Colors.white,
        ),
      ),

      // 2. RUTA INICIAL
      // La app arranca aquí.
      initialRoute: '/splash',

      // 3. TABLA DE RUTAS
      routes: {
        // CORRECCIÓN: Nos aseguramos de llamar a la CLASE "SplashScreen" (con S mayúscula)
        '/splash': (context) => const SplashScreen(),

        '/login': (context) => const LoginScreen(),

        '/loginDriver': (context) => const LoginScreen_Conductor(),

        '/register': (context) => const RegisterScreen(),

        '/registerDriver': (context) => const RegisterDriverScreen(),

        //'/homeDriver': (context) => const DriverHomeScreen(),

        //'/home': (context) => const HomeScreen(),
      },
    );
  }
}
