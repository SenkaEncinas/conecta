import 'package:conectaflutter/screens/User/ActividadListScreen.dart';
import 'package:conectaflutter/screens/User/MisCertificadosScreen.dart';
import 'package:conectaflutter/screens/User/VoluntarioProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class VoluntarioHomeScreen extends StatelessWidget {
  final UsuarioDto usuario;
  const VoluntarioHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombre = (usuario.nombre ?? "").isNotEmpty ? usuario.nombre! : "Voluntario";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio Voluntario"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $nombre 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "¿Qué te gustaría hacer hoy?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Actividades
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.volunteer_activism),
                label: const Text("Ver actividades disponibles"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActividadesListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Certificados
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Mis certificados"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MisCertificadosScreen(usuarioId: usuario.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Perfil
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text("Mi perfil"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoluntarioProfileScreen(usuarioId: usuario.id),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            const Text(
              "📝 TODO: Agregar accesos a Mis Postulaciones cuando esté el endpoint.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
