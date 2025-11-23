import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/Services/PostulacionesController.dart';
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

  final Color primaryColor = Colors.deepPurple.shade600;
  final Color secondaryColor = Colors.deepPurple.shade100;

  @override
  void initState() {
    super.initState();
    _future = _actividadService.getPostulacionesPorActividad(
      widget.actividadId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _actividadService.getPostulacionesPorActividad(
        widget.actividadId,
      );
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

  Color _colorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
      case 'denegada':
        return Colors.red;
      case 'pendiente':
      default:
        return primaryColor;
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
    final controller = TextEditingController(
      text: p.horasCompletadas > 0 ? p.horasCompletadas.toString() : "",
    );

    final horas = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Finalizar postulación #${p.id}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Voluntario: ${p.nombreUsuario}\nActividad: ${p.nombreActividad}\n\nIngresa las horas completadas:",
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null || value <= 0) return;
              Navigator.pop(context, value);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );

    if (horas == null) return;

    setState(() => _accionEnProgreso = true);
    final okFinalizar = await _postulacionService.finalizarPostulacion(
      p.id,
      horas,
    );

    if (!mounted) return;
    setState(() => _accionEnProgreso = false);

    if (!okFinalizar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo finalizar la postulación #${p.id}")),
      );
      return;
    }

    final generar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generar certificado"),
        content: Text(
          "La postulación de ${p.nombreUsuario} fue finalizada con $horas horas.\n\n¿Desea generar el certificado ahora?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, generar"),
          ),
        ],
      ),
    );

    if (generar != true) return;

    final generarDto = GenerarCertificadoDto(
      usuarioId: p.usuarioId,
      actividadId: widget.actividadId,
      horasCertificadas: horas,
    );

    final certificado = await _certificadoService.generarCertificado(
      generarDto,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          certificado != null
              ? "Certificado generado para ${p.nombreUsuario}"
              : "Postulación finalizada, pero no se pudo generar certificado",
        ),
      ),
    );

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.nombreActividad != null
        ? "Postulaciones - ${widget.nombreActividad}"
        : "Postulaciones";

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: primaryColor,
        actions: _accionEnProgreso
            ? const [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryColor,
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

            final Color primaryColor = Colors.deepPurple.shade600;
            final Color secondaryColor = Colors.deepPurple.shade100;

            // ...

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
                  color: secondaryColor.withOpacity(0.3), // esto está seguro
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _iconForEstado(estado),
                      color: _colorForEstado(estado),
                      size: 32,
                    ),
                    title: Text(
                      p.nombreUsuario,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                              color: _colorForEstado(estado),
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
                            value: progreso.isNaN ? 0 : progreso,
                            minHeight: 5,
                            color: primaryColor,
                            backgroundColor: primaryColor.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'aprobar') _aprobar(p);
                        if (value == 'rechazar') _rechazar(p);
                        if (value == 'finalizar') _finalizar(p);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'aprobar', child: Text('Aprobar')),
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
