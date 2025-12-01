import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  // CAMBIA ESTO por tu IP local si usas celular físico (ej. 192.168.1.50)
  // Si usas emulador Android, deja 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // 1. Obtener la lista de rutas desde la Base de Datos
  static Future<List<Map<String, dynamic>>> getRoutes() async {
    final url = Uri.parse('$baseUrl/rutas');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Tu API devuelve: { "success": true, "data": [...] }
        if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print("Error obteniendo rutas: $e");
      return [];
    }
  }

  // 2. Iniciar el viaje (Insertar en VIAJES_ACTIVOS)
  static Future<Map<String, dynamic>> startTrip(
    int idConductor,
    int idRuta,
  ) async {
    final url = Uri.parse('$baseUrl/viajes/iniciar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_conductor': idConductor, 'id_ruta': idRuta}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Error desconocido',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 3. Terminar el viaje
  static Future<Map<String, dynamic>> endTrip(int idConductor) async {
    final url = Uri.parse('$baseUrl/viajes/terminar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_conductor': idConductor}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Error desconocido',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 5. Obtener lista de coordenadas para dibujar la línea
  static Future<List<Map<String, dynamic>>> getRoutePoints(int idRuta) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutas/puntos/$idRuta'),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['data'],
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
