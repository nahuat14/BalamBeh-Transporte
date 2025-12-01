import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestService {
  // Ajusta la IP si usas celular físico
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // --- 1. PASAJERO: SOLICITAR (MODIFICADO) ---
  // Ahora devuelve el ID de la solicitud (int?) para poder rastrearla
  static Future<int?> createRequest(
    int idViaje,
    int idCliente,
    String nombreCliente,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitudes/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_viaje': idViaje,
          'id_cliente': idCliente,
          'nombre_cliente': nombreCliente,
        }),
      );

      final data = jsonDecode(response.body);

      // Si fue exitoso, el backend nos manda el "id_solicitud"
      if (data['success'] == true) {
        return data['id_solicitud'];
      }
      return null;
    } catch (e) {
      print("Error creando solicitud: $e");
      return null;
    }
  }

  // --- 2. PASAJERO: VERIFICAR ESTADO (NUEVO) ---
  // Pregunta si la solicitud sigue PENDIENTE, fue ACEPTADA o RECHAZADA
  static Future<String> checkStatus(int idSolicitud) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/solicitudes/estado/$idSolicitud'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['estado'] ?? 'PENDIENTE';
      }
      return 'ERROR';
    } catch (e) {
      return 'ERROR';
    }
  }

  // --- 3. CONDUCTOR: CHECAR PENDIENTES ---
  static Future<List<dynamic>> checkPendingRequests(int idConductor) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conductor/checar_solicitudes/$idConductor'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 4. CONDUCTOR: RESPONDER ---
  static Future<bool> respondRequest(int idSolicitud, String accion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conductor/responder_solicitud'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_solicitud': idSolicitud, 'accion': accion}),
      );
      return jsonDecode(response.body)['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
