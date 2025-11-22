import 'package:conectaflutter/services/PostulacionesController.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/Services/CertificadoService.dart';
import 'package:conectaflutter/DTO/Core/PostulacionDto.dart';
import 'package:conectaflutter/DTO/Core/GenerarCertificadoDto.dart';

class PostulacionesActividadScreen extends StatefulWidget {
  final int actividadId;
  final String? nombreActividad;

  const PostulacionesActividadScreen({
    super.key,
    required this.actividadId,
    this.nombreActividad,
  });

  @override
  State<PostulacionesActividadScreen> createState() =>
      _PostulacionesActividadScreenState();
}

class _PostulacionesActividadScreenState
    extends State<PostulacionesActividadScreen> {
  final ActividadService _actividadService = ActividadService();
  final PostulacionService _postulacionService = PostulacionService();
  final CertificadoService _certificadoService = CertificadoService();

  late Future<List<PostulacionDto>> _future;
  bool _accionEnProgreso = false;

  @override
  void initState() {
    super.initState();
    _future =
        _actividadService.getPostulacionesPorActividad(widget.actividadId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future =
          _actividadService.getPostulacionesPorActividad(widget.actividadId);
    });
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  IconData _iconForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aceptada':
        return Icons.check_circle;
      case 'rechazada':
      case 'denegada':
        return Icons.cancel;
      case 'pendiente':
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _colorForEstado(String estado, BuildContext context) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
      case 'denegada':
        return Colors.red;
      case 'pendiente':
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _aprobar(PostulacionDto p) async {
    setState(() => _accionEnProgreso = true);
    final ok = await _postulacionService.aprobarPostulacion(p.id);
    if (!mounted) return;
    setState(() => _accionEnProgreso = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Postulación #${p.id} aprobada"
              : "No se pudo aprobar la postulación",
        ),
      ),
    );
    if (ok) _refresh();
  }

  Future<void> _rechazar(PostulacionDto p) async {
    setState(() => _accionEnProgreso = true);
    final ok = await _postulacionService.rechazarPostulacion(p.id);
    if (!mounted) return;
    setState(() => _accionEnProgreso = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Postulación #${p.id} rechazada"
              : "No se pudo rechazar la postulación",
        ),
      ),
    );
    if (ok) _refresh();
  }

  Future<void> _finalizar(PostulacionDto p) async {
    // Primer diálogo: ingresar horas
    final controller = TextEditingController(
      text: p.horasCompletadas > 0 ? p.horasCompletadas.toString() : "",
    );

    final horas = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Finalizar postulación #${p.id}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Voluntario: ${p.nombreUsuario}\n"
                "Actividad: ${p.nombreActividad}\n\n"
                "Ingresa las horas completadas:",
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Horas completadas",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text("Guardar"),
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ingresa un número válido de horas"),
                    ),
                  );
                  return;
                }
                Navigator.pop<int>(context, value);
              },
            ),
          ],
        );
      },
    );

    if (horas == null) return;

    setState(() => _accionEnProgreso = true);

    // 1) Finalizar la postulación en el backend
    final okFinalizar =
        await _postulacionService.finalizarPostulacion(p.id, horas);

    if (!okFinalizar) {
      if (!mounted) return;
      setState(() => _accionEnProgreso = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No se pudo finalizar la postulación #${p.id}",
          ),
        ),
      );
      return;
    }

    // 2) Segundo diálogo: confirmar generación del certificado
    final generar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Generar certificado"),
          content: Text(
            "La postulación de ${p.nombreUsuario} fue finalizada con $horas horas.\n\n"
            "¿Quieres generar ahora su certificado?",
          ),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FilledButton(
              child: const Text("Sí, generar"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (generar != true) {
      if (!mounted) return;
      setState(() => _accionEnProgreso = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Postulación finalizada. Certificado no generado."),
        ),
      );
      _refresh();
      return;
    }

    // 3) Generar certificado usando el nuevo GenerarCertificadoDto
    final generarDto = GenerarCertificadoDto(
      usuarioId: p.usuarioId,
      actividadId: widget.actividadId,
      horasCertificadas: horas,
    );

    final certificado =
        await _certificadoService.generarCertificado(generarDto);

    if (!mounted) return;
    setState(() => _accionEnProgreso = false);

    if (certificado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Certificado generado para ${p.nombreUsuario}",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Se finalizó la postulación, pero no se pudo generar el certificado",
          ),
        ),
      );
    }

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final tituloBase = "Postulaciones";
    final titulo = widget.nombreActividad != null
        ? "$tituloBase - ${widget.nombreActividad}"
        : tituloBase;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          if (_accionEnProgreso)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PostulacionDto>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Ocurrió un error al cargar las postulaciones.\n\n${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            final postulaciones = snapshot.data ?? [];

            if (postulaciones.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      "No hay postulaciones para esta actividad.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: postulaciones.length,
              itemBuilder: (context, index) {
                final p = postulaciones[index];

                final estado = p.estado;
                final double progreso = p.horasAsignadas > 0
                    ? (p.horasCompletadas / p.horasAsignadas)
                        .clamp(0, 1)
                        .toDouble()
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      _iconForEstado(estado),
                      color: _colorForEstado(estado, context),
                      size: 32,
                    ),
                    title: Text(
                      p.nombreUsuario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 👇 SOLO cambié este bloque, lo demás está igual
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Actividad: ${p.nombreActividad}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            "Estado: $estado",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _colorForEstado(estado, context),
                            ),
                          ),
                          Text(
                            "Fecha postulación: ${_formatFecha(p.fechaPostulacion)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Horas: ${p.horasCompletadas}/${p.horasAsignadas}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progreso.isNaN ? 0.0 : progreso,
                            minHeight: 5,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "ID postulación: ${p.id}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "ID usuario: ${p.usuarioId}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'aprobar') {
                          _aprobar(p);
                        } else if (value == 'rechazar') {
                          _rechazar(p);
                        } else if (value == 'finalizar') {
                          _finalizar(p);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'aprobar',
                          child: Text('Aprobar'),
                        ),
                        PopupMenuItem(
                          value: 'rechazar',
                          child: Text('Rechazar'),
                        ),
                        PopupMenuItem(
                          value: 'finalizar',
                          child: Text('Finalizar (horas)'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
