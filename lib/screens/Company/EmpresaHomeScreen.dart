import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/screens/Company/CrearActividadScreen.dart';
import 'package:conectaflutter/screens/Company/MisActividadesEmpresaScreen.dart';
import 'package:conectaflutter/screens/Company/PostulacionesActividadScreen.dart';
import 'package:conectaflutter/screens/Company/EmpresaPerfilScreen.dart';

class EmpresaHomeScreen extends StatefulWidget {
  final EmpresaDto empresa;
  const EmpresaHomeScreen({super.key, required this.empresa});

  @override
  State<EmpresaHomeScreen> createState() => _EmpresaHomeScreenState();
}

class _EmpresaHomeScreenState extends State<EmpresaHomeScreen> {
  late EmpresaDto _empresa;

  @override
  void initState() {
    super.initState();
    _empresa = widget.empresa;
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmpresaPerfilScreen(
          empresa: _empresa,
          onSave: (empresaActualizada) {
            setState(() {
              _empresa = empresaActualizada;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLogoAvatar() {
    final logo = _empresa.logoURL;
    final hasLogo = logo != null && logo.trim().isNotEmpty;

    if (!hasLogo) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFF6A1B9A),
        child: Icon(Icons.business, color: Colors.white, size: 30),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(logo!),
      onBackgroundImageError: (_, __) {
        print("❌ Error cargando logo de empresa");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple.shade600;
    final secondaryColor = Colors.deepPurple.shade100;
    final String nombre = _empresa.nombre.isNotEmpty
        ? _empresa.nombre
        : "Empresa";

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("Inicio Empresa"),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _abrirPerfil,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de datos de la empresa
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildLogoAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _empresa.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if ((_empresa.descripcion ?? "").isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              _empresa.descripcion ?? "",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                          if ((_empresa.direccion ?? "").isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _empresa.direccion ?? "",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: _abrirPerfil,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Hola, $nombre 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Gestioná tus actividades y postulaciones.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Botón Crear Actividad
            _buildButton(
              icon: Icons.add,
              label: "Crear actividad",
              color: primaryColor,
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CrearActividadScreen(empresaId: _empresa.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Botón Mis Actividades
            _buildButton(
              icon: Icons.list_alt,
              label: "Mis actividades",
              color: Colors.white,
              textColor: primaryColor,
              border: BorderSide(color: primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MisActividadesEmpresaScreen(empresaId: _empresa.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Botón Postulaciones
            _buildButton(
              icon: Icons.people,
              label: "Postulaciones",
              color: Colors.white,
              textColor: primaryColor,
              border: BorderSide(color: primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostulacionesActividadScreen(actividadId: _empresa.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    BorderSide? border,
    required VoidCallback onTap,
  }) {
    final bool outlined = border != null;
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              icon: Icon(icon, color: textColor),
              label: Text(label, style: TextStyle(color: textColor)),
              style: OutlinedButton.styleFrom(
                side: border,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
            )
          : ElevatedButton.icon(
              icon: Icon(icon, color: textColor),
              label: Text(label, style: TextStyle(color: textColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
            ),
    );
  }
}
