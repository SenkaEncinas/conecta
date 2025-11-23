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

  final Color primaryColor = Colors.blue;
  final Color secondaryColor = Colors.blue.shade50;

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
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final ok = await _empresaService.deleteEmpresa(empresa.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Empresa eliminada correctamente."
              : "No se pudo eliminar la empresa.",
        ),
      ),
    );
    if (ok) _refresh();
  }

  Future<void> _editarEmpresa(EmpresaDto empresa) async {
    if (empresa.id == null) return;

    final parentContext = context;

    final nombreController = TextEditingController(text: empresa.nombre ?? '');
    final descripcionController = TextEditingController(
      text: empresa.descripcion ?? '',
    );
    final direccionController = TextEditingController(
      text: empresa.direccion ?? '',
    );
    final logoUrlController = TextEditingController(
      text: empresa.logoURL ?? '',
    );

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
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: "Dirección"),
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

                final dto = UpdateEmpresaDto(
                  nombre: nombre,
                  descripcion: descripcionController.text.trim().isEmpty
                      ? null
                      : descripcionController.text.trim(),
                  direccion: direccionController.text.trim().isEmpty
                      ? null
                      : direccionController.text.trim(),
                  logoURL: logoUrlController.text.trim().isEmpty
                      ? null
                      : logoUrlController.text.trim(),
                );

                final ok = await _empresaService.updateEmpresa(
                  empresa.id!,
                  dto,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? "Empresa actualizada correctamente."
                          : "No se pudo actualizar la empresa.",
                    ),
                  ),
                );

                if (ok) Navigator.pop(dialogContext, true);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (result == true) _refresh();
  }

  Widget _buildLogo(EmpresaDto e) {
    final url = e.logoURL;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: primaryColor,
        child: const Icon(Icons.business, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
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
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Empresas registradas"),
        centerTitle: true,
        elevation: 4,
      ),
      body: FutureBuilder<List<EmpresaDto>>(
        future: _futureEmpresas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final empresas = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: empresas.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 250),
                      Center(child: Text("No hay empresas registradas")),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: empresas.length,
                    itemBuilder: (context, index) {
                      final e = empresas[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          leading: _buildLogo(e),
                          title: Text(
                            e.nombre ?? "Sin nombre",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (e.email != null)
                                Text(
                                  "Email: ${e.email}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              if (e.direccion != null)
                                Text(
                                  "Dirección: ${e.direccion}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              if (e.descripcion != null &&
                                  e.descripcion!.isNotEmpty)
                                Text(
                                  e.descripcion!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editarEmpresa(e),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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
