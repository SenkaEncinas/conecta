import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';

class ActividadesAdminScreen extends StatefulWidget {
  const ActividadesAdminScreen({super.key});

  @override
  State<ActividadesAdminScreen> createState() => _ActividadesAdminScreenState();
}

class _ActividadesAdminScreenState extends State<ActividadesAdminScreen> {
  final ActividadService _actividadService = ActividadService();
  late Future<List<ActividadDto>> _futureActividades;

  @override
  void initState() {
    super.initState();
    _futureActividades = _actividadService.getActividades();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureActividades = _actividadService.getActividades();
    });
  }

  Future<void> _eliminarActividad(ActividadDto actividad) async {
    // id es int (no nullable) en ActividadDto
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar actividad"),
        content: Text(
          "¿Seguro que querés eliminar '${actividad.nombreActividad}'?",
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

    final ok = await _actividadService.deleteActividad(actividad.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividad eliminada correctamente.")),
      );
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo eliminar la actividad."),
        ),
      );
    }
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actividades (Admin)"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ActividadDto>>(
        future: _futureActividades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final actividades = snapshot.data ?? [];

          if (actividades.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text("No hay actividades registradas")),
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

                // El estado viene como String (ej: "Disponible")
                final estadoTexto = a.estado;
                final estadoLower = estadoTexto.toLowerCase();
                final esActiva =
                    estadoLower == "disponible" || estadoLower == "activa";

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(a.nombreActividad),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Empresa dueña de la actividad
                        Text("Empresa: ${a.nombreEmpresa}"),
                        // Rango de fechas
                        Text(
                          "Del ${_formatFecha(a.fechaInicio)} "
                          "al ${_formatFecha(a.fechaFin)}",
                        ),
                        // Cupos
                        Text("Cupos: ${a.cupos}"),
                        // Estado (String) pero coloreado según valor
                        Text(
                          "Estado: $estadoTexto",
                          style: TextStyle(
                            color: esActiva ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Descripción opcional
                        if (a.descripcion != null &&
                            a.descripcion!.isNotEmpty)
                          Text(
                            a.descripcion!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TODO a futuro: botón editar (usa UpdateActividadDto)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarActividad(a),
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
