import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';

class MisActividadesEmpresaScreen extends StatefulWidget {
  final int? empresaId;
  const MisActividadesEmpresaScreen({super.key, required this.empresaId});

  @override
  State<MisActividadesEmpresaScreen> createState() =>
      _MisActividadesEmpresaScreenState();
}

class _MisActividadesEmpresaScreenState
    extends State<MisActividadesEmpresaScreen> {
  final ActividadService _actividadService = ActividadService();
  late Future<List<ActividadDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _actividadService.getActividadesDeEmpresa(widget.empresaId!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _actividadService.getActividadesDeEmpresa(widget.empresaId!);
    });
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  Future<void> _eliminarActividad(ActividadDto a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar actividad"),
        content: Text(
          "¿Seguro que querés eliminar '${a.nombreActividad}'?",
        ),
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

    final ok = await _actividadService.deleteActividad(a.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividad eliminada.")),
      );
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo eliminar la actividad."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis actividades")),
      body: FutureBuilder<List<ActividadDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final actividades = snapshot.data ?? [];

          if (actividades.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No tenés actividades aún.")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final a = actividades[index];

                return Card(
                  child: ListTile(
                    title: Text(a.nombreActividad),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Inicio: ${_formatFecha(a.fechaInicio)}"),
                        Text("Fin: ${_formatFecha(a.fechaFin)}"),
                        Text("Cupos: ${a.cupos} • Estado: ${a.estado}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarActividad(a),
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
