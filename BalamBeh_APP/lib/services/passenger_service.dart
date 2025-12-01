import 'dart:convert';
import 'package:http/http.dart' as http;

class PassengerService {
  // Ajusta la IP (10.0.2.2 para emulador, tu IP local para físico)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static Future<List<Map<String, dynamic>>> buscarVans(String pueblo) async {
    final url = Uri.parse('$baseUrl/viajes/buscar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pueblo': pueblo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Devolvemos la lista de vans encontradas
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return []; // Si no hay resultados o falla, devuelve lista vacía
    } catch (e) {
      print("Error buscando vans: $e");
      return [];
    }
  }
}
