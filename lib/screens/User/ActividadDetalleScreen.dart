import 'package:conectaflutter/services/PostulacionesController.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';

class ActividadDetalleScreen extends StatefulWidget {
  final ActividadDto actividad;

  const ActividadDetalleScreen({super.key, required this.actividad});

  @override
  State<ActividadDetalleScreen> createState() =>
      _ActividadDetalleScreenState();
}

class _ActividadDetalleScreenState extends State<ActividadDetalleScreen> {
  final PostulacionService _postulacionService = PostulacionService();
  bool _isLoading = false;
  String? _msg;

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  Future<void> _postularme() async {
    setState(() {
      _isLoading = true;
      _msg = null;
    });

    final ok =
        await _postulacionService.postularAActividad(widget.actividad.id); // 👈 service nuevo

    setState(() {
      _isLoading = false;
      _msg = ok
          ? "✅ Postulación enviada con éxito"
          : "❌ No se pudo postular. Puede que ya estés postulado o hubo un error.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.actividad;

    return Scaffold(
      appBar: AppBar(title: Text(a.nombreActividad)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.nombreActividad,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Empresa: ${a.nombreEmpresa}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 14),

            if (a.descripcion != null && a.descripcion!.isNotEmpty)
              Text(a.descripcion!, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 14),

            Text("📅 Inicio: ${_formatFecha(a.fechaInicio)}"),
            Text("📅 Fin: ${_formatFecha(a.fechaFin)}"),
            Text("👥 Cupos: ${a.cupos}"),
            Text("📌 Estado: ${a.estado}"),

            const Spacer(),

            if (_msg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _msg!,
                  style: TextStyle(
                    color: _msg!.contains("✅") ? Colors.green : Colors.red,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _postularme,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Postularme"),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "📝 Recuerda que la empresa debe aprobar tu postulación.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
