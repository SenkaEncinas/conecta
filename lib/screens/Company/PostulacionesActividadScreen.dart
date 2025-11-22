import 'package:conectaflutter/services/PostulacionesController.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/Services/CertificadoService.dart';
import 'package:conectaflutter/DTO/Core/PostulacionDto.dart';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';
import 'package:url_launcher/url_launcher.dart';  // Importamos url_launcher

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
    _future = _actividadService.getPostulacionesPorActividad(widget.actividadId);
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
        content: Text(ok
            ? "Postulación #${p.id} aprobada"
            : "No se pudo aprobar la postulación"),
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
        content: Text(ok
            ? "Postulación #${p.id} rechazada"
            : "No se pudo rechazar la postulación"),
      ),
    );
    if (ok) _refresh();
  }

  Future<void> _finalizar(PostulacionDto p) async {
    final controller = TextEditingController(
      text: p.horasCompletadas > 0 ? p.horasCompletadas.toString() : "",
    );

    final result = await showDialog<int>(
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
                if (value == null || value < 0) {
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

    if (result == null) return;

    setState(() => _accionEnProgreso = true);
    final ok =
        await _postulacionService.finalizarPostulacion(p.id, result);
    if (!mounted) return;
    setState(() => _accionEnProgreso = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? "Postulación #${p.id} finalizada con $result horas"
            : "No se pudo finalizar la postulación"),
      ),
    );

    if (ok) {
      // Generar el certificado después de finalizar la postulación
      await _generarCertificado(p, result);
    }

    if (ok) _refresh();
  }

  // Función para generar el certificado y abrir el PDF
  Future<void> _generarCertificado(PostulacionDto p, int horasCompletadas) async {
    final certificadoDto = CertificadoDto(
      id: 0,
      nombreVoluntario: p.nombreUsuario,
      nombreEmpresa: "",  // Aquí puedes agregar el nombre de la empresa
      nombreActividad: p.nombreActividad,
      horasCertificadas: horasCompletadas,
      fechaEmision: DateTime.now(),
      urlCertificadoPDF: "",  // Asumimos que el backend genera este URL
    );

    setState(() => _accionEnProgreso = true);
    final certificado = await _certificadoService.generarCertificado(certificadoDto);
    setState(() => _accionEnProgreso = false);

    if (certificado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Certificado generado para ${p.nombreUsuario}")),
      );
      // Abre el PDF del certificado si se generó
      _abrirPDF(certificado.urlCertificadoPDF);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo generar el certificado")),
      );
    }
  }

  // Función para abrir el PDF usando url_launcher
  Future<void> _abrirPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el PDF")),
      );
    }
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
                    ? (p.horasCompletadas / p.horasAsignadas).clamp(0, 1).toDouble()
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
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Actividad: ${p.nombreActividad}"),
                          Text("Estado: $estado"),
                          Text(
                            "Fecha postulación: ${_formatFecha(p.fechaPostulacion)}",
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Horas asignadas: ${p.horasAsignadas} | Completadas: ${p.horasCompletadas}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progreso.isNaN ? 0.0 : progreso,
                            minHeight: 5,
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
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'aprobar',
                          child: Text('Aprobar'),
                        ),
                        const PopupMenuItem(
                          value: 'rechazar',
                          child: Text('Rechazar'),
                        ),
                        const PopupMenuItem(
                          value: 'finalizar',
                          child: Text('Finalizar (horas)'),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Si quieres, aquí puedes abrir un detalle más grande.
                    },
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
