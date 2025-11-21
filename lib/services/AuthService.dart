import 'dart:convert';
import 'package:conectaflutter/DTO/Auth/LoginDto.dart';
import 'package:conectaflutter/DTO/Auth/RegisterEmpresaDto.dart';
import 'package:conectaflutter/DTO/Auth/RegisterVoluntarioDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'https://app-251117192144.azurewebsites.net/api/auth';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // --- REGISTRO VOLUNTARIO ---
  Future<UsuarioDto?> registerVoluntario(RegisterVoluntarioDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/voluntario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final usuario = UsuarioDto.fromJson(jsonDecode(response.body));
      await _saveToken(usuario.token!);
      return usuario;
    } else {
      print(
        'Error al registrar voluntario: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }

  // --- REGISTRO EMPRESA ---
  Future<EmpresaDto?> registerEmpresa(RegisterEmpresaDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/empresa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final empresa = EmpresaDto.fromJson(jsonDecode(response.body));
      await _saveToken(empresa.token!);
      return empresa;
    } else {
      print(
        'Error al registrar empresa: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }

  // --- LOGIN ---
  Future<dynamic> login(LoginDto dto, String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['tipoUsuario'] != null) {
        // Es usuario voluntario/admin
        final usuario = UsuarioDto.fromJson(data);
        await _saveToken(usuario.token!);
        return usuario;
      } else if (data['nombre'] != null) {
        // Es empresa
        final empresa = EmpresaDto.fromJson(data);
        await _saveToken(empresa.token!);
        return empresa;
      }
    } else {
      print('Error en login: ${response.statusCode} ${response.body}');
    }
    return null;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
