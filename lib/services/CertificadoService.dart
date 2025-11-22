import 'dart:convert';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';
import 'package:conectaflutter/DTO/Core/GenerarCertificadoDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CertificadoService {
  final String baseUrl =
      'https://app-251122032447.azurewebsites.net/api/certificados';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // -------------------------------------------------------
  // POST /api/certificados/generar  (Empresa o Admin)
  // Usa GenerarCertificadoDto como entrada
  // y devuelve un CertificadoDto creado por el backend
  // -------------------------------------------------------
  Future<CertificadoDto?> generarCertificado(
      GenerarCertificadoDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/generar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return CertificadoDto.fromJson(json);
    } else {
      print(
          'Error generarCertificado: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  // -------------------------------------------------------
  // GET /api/certificados   (lista todos - Admin)
  // -------------------------------------------------------
  Future<List<CertificadoDto>> getCertificados() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CertificadoDto.fromJson(e)).toList();
    } else {
      print(
          "Error getCertificados: ${response.statusCode} - ${response.body}");
      return [];
    }
  }

  // -------------------------------------------------------
  // GET /api/certificados/usuario/{id}
  // -------------------------------------------------------
  Future<List<CertificadoDto>> getCertificadosByUsuario(
      int usuarioId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/usuario/$usuarioId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CertificadoDto.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      // No hay certificados para el usuario
      return [];
    } else {
      print(
          "Error getCertificadosByUsuario: ${response.statusCode} - ${response.body}");
      return [];
    }
  }
}
