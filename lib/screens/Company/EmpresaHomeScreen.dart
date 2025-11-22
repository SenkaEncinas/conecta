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

  // NUEVO: Avatar que usa logoURL real
  Widget _buildLogoAvatar() {
    final logo = _empresa.logoURL;
    final hasLogo = logo != null && logo.trim().isNotEmpty;

    print("DEBUG logoURL recibido en Home = $logo");

    if (!hasLogo) {
      return const CircleAvatar(
        radius: 26,
        child: Icon(Icons.business),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 52,
        height: 52,
        child: Image.network(
          logo!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("❌ ERROR al cargar el logo: $error");
            return const CircleAvatar(
              radius: 26,
              child: Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _empresa.nombre.isNotEmpty ? _empresa.nombre : "Empresa";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio Empresa"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: "Perfil",
            onPressed: _abrirPerfil,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARD CON DATOS DE LA EMPRESA ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildLogoAvatar(), // aquí se muestra el logo real
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _empresa.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if ((_empresa.descripcion ?? "").isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(_empresa.descripcion ?? ""),
                          ],
                          if ((_empresa.direccion ?? "").isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(_empresa.direccion ?? ""),
                                ),
                              ],
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Editar"),
                              onPressed: _abrirPerfil,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // DEBUG VISUAL: Ver URL en pantalla
            const SizedBox(height: 8),
            Text(
              'logoURL: ${_empresa.logoURL}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Text(
              "Hola, $nombre 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Gestioná tus actividades y postulaciones.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Crear actividad
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Crear actividad"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CrearActividadScreen(empresaId: _empresa.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Mis actividades
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text("Mis actividades"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MisActividadesEmpresaScreen(empresaId: _empresa.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Postulaciones
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Postulaciones"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostulacionesActividadScreen(
                        actividadId: _empresa.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
