import 'package:conectaflutter/screens/admin/EmpresaAdminScreen.dart';
import 'package:conectaflutter/screens/admin/ActividadAdminScreen.dart';
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

    // Colores específicos para admin
    final primaryColor = Colors.blue.shade900;
    final secondaryColor = Colors.blue.shade100;

    return Scaffold(
      backgroundColor: secondaryColor.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Panel de Administración"),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              color: primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola, $nombre 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Gestioná empresas, actividades y usuarios.",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botones grandes con diseño moderno
            _buildAdminButton(
              context,
              icon: Icons.business,
              label: "Empresas",
              color: primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmpresasAdminScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildAdminButton(
              context,
              icon: Icons.event,
              label: "Actividades",
              color: primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActividadesAdminScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
