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

  final primaryColor = Colors.deepPurple.shade600;
  final secondaryColor = Colors.deepPurple.shade50;

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
        content: Text("¿Seguro que querés eliminar '${a.nombreActividad}'?"),
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

    final ok = await _actividadService.deleteActividad(a.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Actividad eliminada.")));
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo eliminar la actividad.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("Mis actividades"),
        backgroundColor: primaryColor,
      ),
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
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      "No tenés actividades aún.",
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      a.nombreActividad,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Inicio: ${_formatFecha(a.fechaInicio)}"),
                          Text("Fin: ${_formatFecha(a.fechaFin)}"),
                          Text("Cupos: ${a.cupos} • Estado: ${a.estado}"),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade400),
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
