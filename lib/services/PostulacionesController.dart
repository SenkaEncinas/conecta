import 'dart:convert';
import 'package:conectaflutter/DTO/Core/PostulacionDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostulacionService {
  final String _baseUrl = 'https://app-251121223250.azurewebsites.net/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // -------------------------------------------------------
  // POST /api/actividades/{id}/postular
  // (Solo Voluntario, userId sale del token en el backend)
  // -------------------------------------------------------
  Future<bool> postularAActividad(int actividadId) async {
    final token = await _getToken();
    if (token == null) return false;

    final uri = Uri.parse('$_baseUrl/actividades/$actividadId/postular');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // backend devuelve un mensaje tipo "Postulación realizada con éxito."
      return true;
    } else {
      print(
          'Error postularAActividad: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // -------------------------------------------------------
  // PUT /api/postulaciones/{id}/aprobar
  // (Empresa, Admin)
  // -------------------------------------------------------
  Future<bool> aprobarPostulacion(int postulacionId) async {
    final token = await _getToken();
    if (token == null) return false;

    final uri =
        Uri.parse('$_baseUrl/postulaciones/$postulacionId/aprobar');

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // No body, el backend no lo usa
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
          'Error aprobarPostulacion: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // -------------------------------------------------------
  // PUT /api/postulaciones/{id}/rechazar
  // (Empresa, Admin)
  // -------------------------------------------------------
  Future<bool> rechazarPostulacion(int postulacionId) async {
    final token = await _getToken();
    if (token == null) return false;

    final uri =
        Uri.parse('$_baseUrl/postulaciones/$postulacionId/rechazar');

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
          'Error rechazarPostulacion: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // -------------------------------------------------------
  // PUT /api/postulaciones/{id}/finalizar
  // Body: int horasCompletadas (JSON)
  // (Empresa, Admin)
  // -------------------------------------------------------
  Future<bool> finalizarPostulacion(
      int postulacionId, int horasCompletadas) async {
    final token = await _getToken();
    if (token == null) return false;

    final uri =
        Uri.parse('$_baseUrl/postulaciones/$postulacionId/finalizar');

    // OJO: el backend espera [FromBody] int horasCompletadas,
    // así que mandamos el int directo como JSON, no como objeto.
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(horasCompletadas),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
          'Error finalizarPostulacion: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // -------------------------------------------------------
  // GET /api/postulaciones   (Solo Admin)
  // -------------------------------------------------------
  Future<List<PostulacionDto>> getAllPostulaciones() async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse('$_baseUrl/postulaciones');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PostulacionDto.fromJson(e)).toList();
    } else {
      print(
          'Error getAllPostulaciones: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
