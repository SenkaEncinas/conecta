import 'package:flutter/material.dart';
import 'package:conectaflutter/screens/User/ActividadListScreen.dart';
import 'package:conectaflutter/screens/User/MisCertificadosScreen.dart';
import 'package:conectaflutter/screens/User/VoluntarioProfileScreen.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class VoluntarioHomeScreen extends StatelessWidget {
  final UsuarioDto usuario;
  const VoluntarioHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombre = usuario.nombre.isNotEmpty ? usuario.nombre : "Voluntario";
    final apellido = usuario.apellido;
    final foto = usuario.fotoPerfilURL;
    final curriculum = usuario.curriculumSocial;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------
            // HEADER CON PERFIL
            // -------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (foto != null && foto.isNotEmpty)
                        ? NetworkImage(foto)
                        : null,
                    child: (foto == null || foto.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$nombre $apellido",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          usuario.email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tipo: ${usuario.tipoUsuario}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------------
                    // CURRICULUM SOCIAL
                    // -------------------------------
                    if (curriculum != null && curriculum.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Curriculum Social",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(curriculum),
                          ],
                        ),
                      ),

                    // -------------------------------
                    // ACCIONES DEL VOLUNTARIO (GRID)
                    // -------------------------------
                    const Text(
                      "Acciones rápidas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildCardAction(
                          context,
                          label: "Ver actividades",
                          icon: Icons.volunteer_activism,
                          color: Colors.blue.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActividadesListScreen(),
                            ),
                          ),
                        ),
                        _buildCardAction(
                          context,
                          label: "Mis certificados",
                          icon: Icons.picture_as_pdf,
                          color: Colors.green.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MisCertificadosScreen(usuarioId: usuario.id),
                            ),
                          ),
                        ),
                        _buildCardAction(
                          context,
                          label: "Mi perfil",
                          icon: Icons.person,
                          color: Colors.orange.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoluntarioProfileScreen(
                                usuarioId: usuario.id,
                              ),
                            ),
                          ),
                        ),
                        _buildCardAction(
                          context,
                          label: "Salir",
                          icon: Icons.logout,
                          color: Colors.red.shade600,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
