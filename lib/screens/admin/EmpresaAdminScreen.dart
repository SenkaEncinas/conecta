import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/EmpresaService.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';

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
                    leading: const Icon(Icons.business),
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
                        // TODO: botón editar empresa con updateEmpresa
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
