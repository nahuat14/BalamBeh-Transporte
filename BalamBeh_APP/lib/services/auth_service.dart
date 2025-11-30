import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // IP ESPECIAL para Emulador Android (10.0.2.2).
  // Si usas celular físico, cambia esto por tu IP local (ej. 192.168.1.15)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ==========================================================
  //                      ZONA DE CLIENTES
  // ==========================================================

  // --- LOGIN CLIENTE ---
  static Future<Map<String, dynamic>> loginClient(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login/client');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombreuser': username, 'contraseña': password}),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- REGISTRO CLIENTE ---
  static Future<Map<String, dynamic>> registerClient(
    String nombre,
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register/client');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'nombreuser': username,
          'contraseña': password,
        }),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ==========================================================
  //                      ZONA DE CONDUCTORES
  // ==========================================================

  // --- LOGIN CONDUCTOR ---
  static Future<Map<String, dynamic>> loginConductor(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login/conductor');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'contraseña': password}),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- REGISTRO CONDUCTOR ---
  // Esta es la función específica que tu pantalla Step 3 está buscando
  static Future<Map<String, dynamic>> registerConductor(
    Map<String, dynamic> driverData,
  ) async {
    final url = Uri.parse('$baseUrl/register/conductor');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(driverData),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- Helper para procesar respuestas ---
  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Éxito',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al leer respuesta del servidor',
      };
    }
  }
}
