import 'dart:convert';

import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';
import 'package:conectaflutter/DTO/Core/PostulacionDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateUsuarioDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  final String baseUrl =
      'https://app-251122032447.azurewebsites.net/api/usuarios';

  // ============================
  // TOKEN
  // ============================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ============================
  // GET: api/usuarios/{id}
  // (ya lo tenías)
  // ============================
  Future<UsuarioDto?> getUsuario(int id) async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UsuarioDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // ============================
  // PUT: api/usuarios/{id}
  // (ya lo tenías)
  // ============================
  Future<bool> updateUsuario(int id, UpdateUsuarioDto dto) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  // ============================
  // DELETE: api/usuarios/{id}
  // (ya lo tenías)
  // ============================
  Future<bool> deleteUsuario(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // ============================
  // GET: api/usuarios/{id}/certificados
  // (GetCertificados del controller)
  // ============================
  Future<List<CertificadoDto>> getCertificadosByUsuario(int id) async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/$id/certificados'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => CertificadoDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // 404 o cualquier otro → devolvemos lista vacía
      return [];
    }
  }

  // ============================
  // GET: api/usuarios/{id}/postulaciones
  // (GetPostulaciones del controller)
  // ============================
  Future<List<PostulacionDto>> getPostulacionesByUsuario(int id) async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/$id/postulaciones'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => PostulacionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // 404 o cualquier otro → devolvemos lista vacía
      return [];
    }
  }
}
