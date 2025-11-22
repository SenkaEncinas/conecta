import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateActividadDto.dart';

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

  Future<void> _editarActividad(ActividadDto actividad) async {
    final parentContext = context;

    final nombreController =
        TextEditingController(text: actividad.nombreActividad);
    final descripcionController =
        TextEditingController(text: actividad.descripcion ?? '');
    final cuposController =
        TextEditingController(text: actividad.cupos.toString());

    // estado en DTO es bool, pero en ActividadDto es String
    final estadoLower = actividad.estado.toLowerCase();
    bool estadoActiva =
        estadoLower == "disponible" || estadoLower == "activa";

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Editar actividad"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre actividad",
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
                  controller: cuposController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Cupos",
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Activa"),
                    const Spacer(),
                    Switch(
                      value: estadoActiva,
                      onChanged: (val) {
                        estadoActiva = val;
                        // necesario para que se actualice el switch
                        (dialogContext as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Estado actual: ${actividad.estado}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                final cuposStr = cuposController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("El nombre no puede estar vacío."),
                    ),
                  );
                  return;
                }

                final cupos = int.tryParse(cuposStr);
                if (cupos == null || cupos < 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Cupos inválidos."),
                    ),
                  );
                  return;
                }

                final dto = UpdateActividadDto(
                  nombreActividad: nombre,
                  descripcion: descripcionController.text.trim().isEmpty
                      ? null
                      : descripcionController.text.trim(),
                  // Por ahora NO cambiamos fechas desde el admin:
                  fechaInicio: actividad.fechaInicio,
                  fechaFin: actividad.fechaFin,
                  cupos: cupos,
                  estado: estadoActiva,
                );

                final ok = await _actividadService.updateActividad(
                  actividad.id,
                  dto,
                );

                if (ok) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Actividad actualizada correctamente."),
                    ),
                  );
                  Navigator.pop(dialogContext, true);
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text("No se pudo actualizar la actividad."),
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
                        Text("Empresa: ${a.nombreEmpresa}"),
                        Text(
                          "Del ${_formatFecha(a.fechaInicio)} "
                          "al ${_formatFecha(a.fechaFin)}",
                        ),
                        Text("Cupos: ${a.cupos}"),
                        Text(
                          "Estado: $estadoTexto",
                          style: TextStyle(
                            color: esActiva ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarActividad(a),
                        ),
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
