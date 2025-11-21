import 'dart:convert';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CertificadoService {
  final String baseUrl =
      'https://app-251117192144.azurewebsites.net/api/certificados';

  // Token público para obtenerlo desde otros servicios o headers
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Token privado para guardar internamente
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // --- GENERAR CERTIFICADO ---
  Future<CertificadoDto?> generarCertificado(CertificadoDto dto) async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/generar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return CertificadoDto.fromJson(jsonDecode(response.body));
    } else {
      print(
        'Error al generar certificado: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }

  // --- OBTENER TODOS LOS CERTIFICADOS ---
  Future<List<CertificadoDto>> getCertificados() async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CertificadoDto.fromJson(json)).toList();
    } else {
      print(
        'Error al obtener certificados: ${response.statusCode} ${response.body}',
      );
      return [];
    }
  }
}
