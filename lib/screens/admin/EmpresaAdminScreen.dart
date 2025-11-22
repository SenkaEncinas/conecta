import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/EmpresaService.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateEmpresaDto.dart';

class EmpresasAdminScreen extends StatefulWidget {
  const EmpresasAdminScreen({super.key});

  @override
  State<EmpresasAdminScreen> createState() => _EmpresasAdminScreenState();
}

class _EmpresasAdminScreenState extends State<EmpresasAdminScreen> {
  final EmpresaService _empresaService = EmpresaService();
  late Future<List<EmpresaDto>> _futureEmpresas;

  @override
  void initState() {
    super.initState();
    _futureEmpresas = _empresaService.getEmpresas();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureEmpresas = _empresaService.getEmpresas();
    });
  }

  Future<void> _eliminarEmpresa(EmpresaDto empresa) async {
    if (empresa.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar empresa"),
        content: Text("¿Seguro que querés eliminar a '${empresa.nombre}'?"),
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

    final ok = await _empresaService.deleteEmpresa(empresa.id!);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Empresa eliminada correctamente.")),
      );
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo eliminar la empresa."),
        ),
      );
    }
  }

  Future<void> _editarEmpresa(EmpresaDto empresa) async {
    if (empresa.id == null) return;

    final parentContext = context;

    final nombreController =
        TextEditingController(text: empresa.nombre ?? '');
    final descripcionController =
        TextEditingController(text: empresa.descripcion ?? '');
    final direccionController =
        TextEditingController(text: empresa.direccion ?? '');
    final logoUrlController =
        TextEditingController(text: empresa.logoURL ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Editar empresa"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    hintText: "Nombre de la empresa",
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: "Dirección",
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: logoUrlController,
                  decoration: const InputDecoration(
                    labelText: "Logo URL",
                    hintText: "https://...",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("El nombre no puede estar vacío."),
                    ),
                  );
                  return;
                }

                final descripcion = descripcionController.text.trim();
                final direccion = direccionController.text.trim();
                final logo = logoUrlController.text.trim();

                final dto = UpdateEmpresaDto(
                  nombre: nombre,
                  descripcion:
                      descripcion.isEmpty ? null : descripcion,
                  direccion: direccion.isEmpty ? null : direccion,
                  logoURL: logo.isEmpty ? null : logo,
                );

                final ok = await _empresaService.updateEmpresa(
                  empresa.id!,
                  dto,
                );

                if (ok) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Empresa actualizada correctamente."),
                    ),
                  );
                  Navigator.pop(dialogContext, true);
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("No se pudo actualizar la empresa."),
                    ),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _refresh();
    }
  }

  Widget _buildLogo(EmpresaDto e) {
  final url = e.logoURL;

  // Si no hay URL → ícono default
  if (url == null || url.isEmpty) {
    return const CircleAvatar(
      radius: 22,
      child: Icon(Icons.business),
    );
  }

  return CircleAvatar(
    radius: 22,
    backgroundColor: Colors.grey.shade200,
    child: ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: 44,
        height: 44,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 28, color: Colors.grey);
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Empresas registradas"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<EmpresaDto>>(
        future: _futureEmpresas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final empresas = snapshot.data ?? [];

          if (empresas.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text("No hay empresas registradas")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: empresas.length,
              itemBuilder: (context, index) {
                final e = empresas[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: _buildLogo(e),
                    title: Text(e.nombre ?? "Sin nombre"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (e.email != null) Text("Email: ${e.email}"),
                        if (e.direccion != null)
                          Text("Dirección: ${e.direccion}"),
                        if (e.descripcion != null &&
                            e.descripcion!.isNotEmpty)
                          Text(
                            e.descripcion!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarEmpresa(e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarEmpresa(e),
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
