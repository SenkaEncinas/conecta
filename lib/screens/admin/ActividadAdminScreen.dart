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

  final Color primaryColor = Colors.teal;
  final Color secondaryColor = Colors.teal.shade50;

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
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final ok = await _actividadService.deleteActividad(actividad.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Actividad eliminada correctamente."
              : "No se pudo eliminar la actividad.",
        ),
      ),
    );

    if (ok) await _refresh();
  }

  Future<void> _editarActividad(ActividadDto actividad) async {
    final parentContext = context;

    final nombreController = TextEditingController(
      text: actividad.nombreActividad,
    );
    final descripcionController = TextEditingController(
      text: actividad.descripcion ?? '',
    );
    final cuposController = TextEditingController(
      text: actividad.cupos.toString(),
    );

    bool estadoActiva =
        actividad.estado.toLowerCase() == "disponible" ||
        actividad.estado.toLowerCase() == "activa";

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
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cuposController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Cupos"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Activa"),
                    const Spacer(),
                    StatefulBuilder(
                      builder: (context, setStateSwitch) {
                        return Switch(
                          value: estadoActiva,
                          onChanged: (val) {
                            setStateSwitch(() => estadoActiva = val);
                          },
                        );
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
                    const SnackBar(content: Text("Cupos inválidos.")),
                  );
                  return;
                }

                final dto = UpdateActividadDto(
                  nombreActividad: nombre,
                  descripcion: descripcionController.text.trim().isEmpty
                      ? null
                      : descripcionController.text.trim(),
                  fechaInicio: actividad.fechaInicio,
                  fechaFin: actividad.fechaFin,
                  cupos: cupos,
                  estado: estadoActiva,
                );

                final ok = await _actividadService.updateActividad(
                  actividad.id,
                  dto,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? "Actividad actualizada correctamente."
                          : "No se pudo actualizar la actividad.",
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

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("Actividades (Admin)"),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
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

          return RefreshIndicator(
            onRefresh: _refresh,
            child: actividades.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 250),
                      Center(child: Text("No hay actividades registradas")),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: actividades.length,
                    itemBuilder: (context, index) {
                      final a = actividades[index];
                      final esActiva =
                          a.estado.toLowerCase() == "disponible" ||
                          a.estado.toLowerCase() == "activa";

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
                          leading: const Icon(Icons.event, color: Colors.teal),
                          title: Text(
                            a.nombreActividad,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Empresa: ${a.nombreEmpresa}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Del ${_formatFecha(a.fechaInicio)} al ${_formatFecha(a.fechaFin)}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Cupos: ${a.cupos}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Estado: ${a.estado}",
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
                                onPressed: () => _editarActividad(a),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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
