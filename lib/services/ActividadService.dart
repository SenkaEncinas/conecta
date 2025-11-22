import 'dart:convert';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/DTO/Core/PostulacionDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateActividadDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActividadService {
  // Base del API (misma que ya usas en otros services)
  final String _baseApiUrl =
      'https://app-251122032447.azurewebsites.net/api';

  String get _actividadesUrl => '$_baseApiUrl/actividades';
  String get _empresasUrl => '$_baseApiUrl/empresas';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // =========================================================================
  // 1. POST /api/empresas/{id}/actividades  (CREAR ACTIVIDAD)
  //    C#:
  //    [HttpPost("/api/empresas/{id}/actividades")]
  // =========================================================================
  Future<ActividadDto?> createActividad(int empresaId, ActividadDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final uri = Uri.parse('$_empresasUrl/$empresaId/actividades');

    // El backend solo usa: NombreActividad, Descripcion, FechaInicio, FechaFin, Cupos
    final body = {
      'nombreActividad': dto.nombreActividad,
      'descripcion': dto.descripcion,
      'fechaInicio': dto.fechaInicio.toIso8601String(),
      'fechaFin': dto.fechaFin.toIso8601String(),
      'cupos': dto.cupos,
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ActividadDto.fromJson(json);
    } else {
      print(
          'Error createActividad: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  // =========================================================================
  // 2. GET /api/actividades  (LISTAR TODAS)
  // =========================================================================
  Future<List<ActividadDto>> getActividades() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(_actividadesUrl),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => ActividadDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      print('Error getActividades: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  // =========================================================================
  // 3. GET /api/actividades/{id}  (DETALLE - getActividad)
  // =========================================================================
  Future<ActividadDto?> getActividad(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$_actividadesUrl/$id'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ActividadDto.fromJson(json);
    } else if (response.statusCode == 404) {
      // Actividad no encontrada
      return null;
    } else {
      print('Error getActividad: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  // =========================================================================
  // 4. PUT /api/actividades/{id}  (ACTUALIZAR)
  //    El backend recibe UpdateActividadDto
  // =========================================================================
  Future<bool> updateActividad(int id, UpdateActividadDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_actividadesUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      print('Error updateActividad: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // =========================================================================
  // 5. DELETE /api/actividades/{id}  (ELIMINAR)
  // =========================================================================
  Future<bool> deleteActividad(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_actividadesUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      print('Error deleteActividad: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // =========================================================================
  // 6. GET /api/actividades/{id}/postulaciones
  //    (VER POSTULACIONES POR ACTIVIDAD - Empresas/Admin)
  // =========================================================================
  Future<List<PostulacionDto>> getPostulacionesPorActividad(
      int actividadId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_actividadesUrl/$actividadId/postulaciones'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => PostulacionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      // "No hay postulaciones para esta actividad."
      return [];
    } else {
      print(
          'Error getPostulacionesPorActividad: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
    // =========================================================================
  // EXTRA: Obtener actividades de una empresa específica (filtrando en frontend)
  // =========================================================================
  Future<List<ActividadDto>> getActividadesDeEmpresa(int empresaId) async {
    // Reutilizamos el método que ya llama al backend
    final todas = await getActividades();

    // Filtramos en frontend por empresaId
    return todas.where((a) => a.empresaId == empresaId).toList();
  }

}
