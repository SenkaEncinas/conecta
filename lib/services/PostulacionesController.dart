import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostulacionService {
  final String baseUrl =
      'https://app-251117192144.azurewebsites.net/api/postulaciones';

  // Token público para usar en headers
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Token privado para guardar internamente (opcional)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // --- POSTULAR A UNA ACTIVIDAD ---
  Future<bool> postular(int actividadId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(
        'https://app-251117192144.azurewebsites.net/api/actividades/$actividadId/postular',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  // --- APROBAR POSTULACION ---
  Future<bool> aprobarPostulacion(int postulacionId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/$postulacionId/aprobar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  // --- RECHAZAR POSTULACION ---
  Future<bool> rechazarPostulacion(int postulacionId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/$postulacionId/rechazar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  // --- FINALIZAR POSTULACION ---
  Future<bool> finalizarPostulacion(
    int postulacionId,
    int horasCompletadas,
  ) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/$postulacionId/finalizar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(horasCompletadas),
    );

    return response.statusCode == 200;
  }
}
