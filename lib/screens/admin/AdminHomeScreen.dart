import 'package:conectaflutter/screens/admin/EmpresaAdminScreen.dart';
import 'package:conectaflutter/screens/admin/ActividadAdminScreen.dart';
import 'package:conectaflutter/screens/admin/UsuariosAdminScreen.dart';
// futuros:
// import 'package:conectaflutter/screens/admin/PostulacionesAdminScreen.dart';
// import 'package:conectaflutter/screens/admin/CertificadosAdminScreen.dart';

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

            // Empresas
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

            // Actividades
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event),
                label: const Text("Actividades"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActividadesAdminScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Usuarios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Usuarios"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsuariosAdminScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // FUTURO: Postulaciones
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.assignment_ind),
                label: const Text("Postulaciones (TODO)"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📝 TODO: Panel de postulaciones"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // FUTURO: Certificados / Horas
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.workspace_premium),
                label: const Text("Certificados / Horas (TODO)"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("📝 TODO: Auditoría de certificados y horas"),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            const Text(
              "📝 TODO: Agregar reportes (usuarios activos, horas totales, etc.).",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
