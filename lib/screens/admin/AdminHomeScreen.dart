import 'package:conectaflutter/screens/admin/EmpresaAdminScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class AdminHomeScreen extends StatelessWidget {
  final UsuarioDto admin;
  const AdminHomeScreen({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    final nombre = (admin.nombre ?? "").isNotEmpty ? admin.nombre! : "Admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
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
              "Gestioná empresas, actividades y usuarios.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Gestionar empresas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.business),
                label: const Text("Empresas"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmpresasAdminScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // TODO futuros
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: const Text("Actividades (TODO)"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📝 TODO: Pantalla de gestión de actividades"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Usuarios (TODO)"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📝 TODO: Pantalla de gestión de usuarios"),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            const Text(
              "📝 TODO: Agregar más módulos al panel admin (reportes, auditoría, etc.).",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
