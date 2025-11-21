import 'dart:convert';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateUsuarioDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  final String baseUrl =
      'https://app-251117192144.azurewebsites.net/api/usuarios';

  // Token público para headers
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Token privado para guardar internamente (opcional)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // --- OBTENER USUARIO POR ID ---
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

  // --- ACTUALIZAR USUARIO ---
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

  // --- ELIMINAR USUARIO ---
  Future<bool> deleteUsuario(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }
}
