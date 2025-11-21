import 'dart:convert';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateActividadDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActividadService {
  final String _baseUrl = 'https://app-251117192144.azurewebsites.net/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- CREAR ACTIVIDAD ---
  Future<ActividadDto?> crearActividad(int empresaId, ActividadDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/empresas/$empresaId/actividades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return ActividadDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- ACTUALIZAR ACTIVIDAD ---
  Future<bool> actualizarActividad(int id, UpdateActividadDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/actividades/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  // --- ELIMINAR ACTIVIDAD ---
  Future<bool> eliminarActividad(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/actividades/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // --- OBTENER TODAS LAS ACTIVIDADES ---
  Future<List<ActividadDto>> getActividades() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/actividades'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ActividadDto.fromJson(json)).toList();
    }

    return [];
  }
}
