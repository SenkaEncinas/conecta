import 'dart:convert';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateEmpresaDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaService {
  final String baseUrl =
      'https://app-251121223250.azurewebsites.net/api/empresas';

  // Token público para headers
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Token privado para guardar internamente
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // --- OBTENER TODAS LAS EMPRESAS ---
  Future<List<EmpresaDto>> getEmpresas() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => EmpresaDto.fromJson(json)).toList();
    }
    return [];
  }

  // --- OBTENER EMPRESA POR ID ---
  Future<EmpresaDto?> getEmpresa(int id) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.statusCode == 200) {
      return EmpresaDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- ACTUALIZAR EMPRESA ---
  Future<bool> updateEmpresa(int id, UpdateEmpresaDto dto) async {
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

  // --- ELIMINAR EMPRESA ---
  Future<bool> deleteEmpresa(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }
}
