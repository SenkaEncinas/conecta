import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/UsuarioService.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class VoluntarioProfileScreen extends StatelessWidget {
  final int? usuarioId;
  final UsuarioService _usuarioService = UsuarioService();

  VoluntarioProfileScreen({super.key, required this.usuarioId});

  Future<UsuarioDto?> _getUsuarioSafe() async {
    if (usuarioId == null) {
      // TODO: obtener usuarioId desde el token o prefs
      return null;
    }
    return _usuarioService.getUsuario(usuarioId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: FutureBuilder<UsuarioDto?>(
        future: _getUsuarioSafe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final u = snapshot.data;
          if (u == null) {
            return const Center(
              child: Text(
                "No se pudo cargar el perfil.\n\n📝 TODO: asegurar usuarioId válido",
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${u.nombre ?? ''} ${u.apellido ?? ''}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (u.email != null) Text("📧 Email: ${u.email}"),
                const SizedBox(height: 6),

                if (u.curriculumSocial != null)
                  Text("📝 Curriculum social: ${u.curriculumSocial}"),

                const Spacer(),

                const Text(
                  "📝 TODO: habilitar edición con updateUsuario si corresponde al rol voluntario.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
