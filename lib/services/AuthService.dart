import 'dart:convert';
import 'package:conectaflutter/DTO/Auth/LoginDto.dart';
import 'package:conectaflutter/DTO/Auth/RegisterEmpresaDto.dart';
import 'package:conectaflutter/DTO/Auth/RegisterVoluntarioDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'https://app-251121223250.azurewebsites.net/api/auth';

  // guardar token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // obtener token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // registro voluntario
  Future<UsuarioDto?> registerVoluntario(RegisterVoluntarioDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/voluntario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final usuario = UsuarioDto.fromJson(jsonDecode(response.body));
      if (usuario.token != null) {
        await saveToken(usuario.token!);
      }
      return usuario;
    } else {
      print("ERROR registerVoluntario => ${response.statusCode}: ${response.body}");
      return null;
    }
  }

  // registro empresa
  Future<EmpresaDto?> registerEmpresa(RegisterEmpresaDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/empresa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final empresa = EmpresaDto.fromJson(jsonDecode(response.body));
      if (empresa.token != null) {
        await saveToken(empresa.token!);
      }
      return empresa;
    } else {
      print("ERROR registerEmpresa => ${response.statusCode}: ${response.body}");
      return null;
    }
  }

  // login (voluntario/admin o empresa)
  Future<dynamic> login(LoginDto dto, [String? extra]) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ prints para confirmar qué llega
      print("LOGIN RAW => ${response.body}");
      print("LOGIN tipoUsuario => ${data['tipoUsuario']}");

      // ✅ EXACTAMENTE igual a tu backend
      if (data['tipoUsuario'] != null) {
        final usuario = UsuarioDto.fromJson(data);
        if (usuario.token != null) {
          await saveToken(usuario.token!);
        }
        return usuario;
      } else {
        final empresa = EmpresaDto.fromJson(data);
        if (empresa.token != null) {
          await saveToken(empresa.token!);
        }
        return empresa;
      }
    } else {
      print("ERROR login => ${response.statusCode}: ${response.body}");
      return null;
    }
  }
}
