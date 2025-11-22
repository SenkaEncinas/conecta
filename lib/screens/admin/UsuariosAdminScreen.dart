import 'dart:convert';

import 'package:conectaflutter/DTO/Entities/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/UsuarioService.dart';
// 👇 importa el archivo donde está tu clase Usuario
// (si el path es distinto, solo cambia esta línea)
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart'; 

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuariosAdminScreen extends StatefulWidget {
  const UsuariosAdminScreen({super.key});

  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen> {
  final UsuarioService _usuarioService = UsuarioService();
  late Future<List<Usuario>> _futureUsuarios;

  final String _baseUrl =
      'https://app-251122032447.azurewebsites.net/api/usuarios';

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _fetchUsuarios();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Trae TODOS los usuarios para el admin
  Future<List<Usuario>> _fetchUsuarios() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Token no encontrado");
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        "Error al obtener usuarios: ${response.statusCode} ${response.body}",
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureUsuarios = _fetchUsuarios();
    });
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    // 👇 en tu modelo id es int (no null), así que no hace falta chequear null
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar usuario"),
        content: Text(
          "¿Seguro que querés eliminar a '${usuario.nombre} ${usuario.apellido}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // 🔥 acá usamos tu service tal cual está
    final ok = await _usuarioService.deleteUsuario(usuario.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario eliminado correctamente.")),
      );
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo eliminar el usuario."),
        ),
      );
    }
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios (Admin)"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text("No hay usuarios registrados")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("${u.nombre} ${u.apellido}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${u.email}"),
                        Text("Tipo: ${u.tipoUsuario}"),
                        Text("Registrado: ${_formatFecha(u.fechaRegistro)}"),
                        if (u.curriculumSocial != null &&
                            u.curriculumSocial!.isNotEmpty)
                          Text(
                            "CV social: ${u.curriculumSocial}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TODO: botón editar usuario -> usar UpdateUsuarioDto
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarUsuario(u),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
