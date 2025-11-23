import 'package:conectaflutter/services/PostulacionesController.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';

class ActividadDetalleScreen extends StatefulWidget {
  final ActividadDto actividad;

  const ActividadDetalleScreen({super.key, required this.actividad});

  @override
  State<ActividadDetalleScreen> createState() => _ActividadDetalleScreenState();
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

    final ok = await _postulacionService.postularAActividad(
      widget.actividad.id,
    );

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
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(a.nombreActividad),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.nombreActividad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Empresa: ${a.nombreEmpresa}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (a.descripcion != null && a.descripcion!.isNotEmpty)
                    Text(
                      a.descripcion!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  const SizedBox(height: 20),
                  // Información extra
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _infoChip(
                        Icons.calendar_today,
                        "Inicio: ${_formatFecha(a.fechaInicio)}",
                      ),
                      _infoChip(
                        Icons.calendar_today_outlined,
                        "Fin: ${_formatFecha(a.fechaFin)}",
                      ),
                      _infoChip(Icons.group, "Cupos: ${a.cupos}"),
                      _infoChip(Icons.info_outline, "Estado: ${a.estado}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Mensaje de resultado
            if (_msg != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _msg!.contains("✅")
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _msg!,
                  style: TextStyle(
                    color: _msg!.contains("✅")
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Botón de postulación
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _postularme,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? "Enviando..." : "Postularme",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Recordatorio
            const Text(
              "📝 Recuerda que la empresa debe aprobar tu postulación.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar un chip con icono + texto
  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
