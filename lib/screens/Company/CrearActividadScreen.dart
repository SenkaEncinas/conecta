import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/Services/ActividadService.dart';

class CrearActividadScreen extends StatefulWidget {
  final int? empresaId;
  const CrearActividadScreen({super.key, required this.empresaId});

  @override
  State<CrearActividadScreen> createState() => _CrearActividadScreenState();
}

class _CrearActividadScreenState extends State<CrearActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreActividadController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _cuposController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _loading = false;
  final ActividadService _actividadService = ActividadService();

  @override
  void dispose() {
    _nombreActividadController.dispose();
    _descripcionController.dispose();
    _cuposController.dispose();
    super.dispose();
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  Future<void> _seleccionarFechaInicio() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio!)) {
          _fechaFin = _fechaInicio;
        }
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final baseDate = _fechaInicio ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: baseDate,
      firstDate: baseDate,
      lastDate: DateTime(baseDate.year + 3),
    );

    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
    }
  }

  Future<void> _crearActividad() async {
    if (widget.empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: empresaId no válido")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona fecha de inicio y fin")),
      );
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La fecha fin no puede ser antes que la de inicio"),
        ),
      );
      return;
    }

    final cupos = int.tryParse(_cuposController.text);
    if (cupos == null || cupos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un número de cupos válido")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final actividad = ActividadDto(
        id: 0,
        empresaId: widget.empresaId!,
        nombreEmpresa: "",
        nombreActividad: _nombreActividadController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        cupos: cupos,
        estado: "Disponible",
      );

      final creada = await _actividadService.createActividad(
        widget.empresaId!,
        actividad,
      );

      if (creada != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Actividad creada exitosamente")),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo crear la actividad. Revisa el servidor."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al crear actividad: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple.shade600;
    final secondaryColor = Colors.deepPurple.shade50;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("Crear Actividad"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Empresa ID: ${widget.empresaId ?? 'sin id'}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nombreActividadController,
                label: "Nombre de la actividad",
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Ingresa el nombre"
                    : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descripcionController,
                label: "Descripción (opcional)",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _cuposController,
                label: "Cupos",
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return "Ingresa la cantidad de cupos";
                  if (int.tryParse(v) == null) return "Debe ser un número";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildDateSelector(
                label: _fechaInicio == null
                    ? "Seleccionar fecha de inicio"
                    : "Fecha inicio: ${_formatFecha(_fechaInicio!)}",
                onTap: _seleccionarFechaInicio,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 8),
              _buildDateSelector(
                label: _fechaFin == null
                    ? "Seleccionar fecha de fin"
                    : "Fecha fin: ${_formatFecha(_fechaFin!)}",
                onTap: _seleccionarFechaFin,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _crearActividad,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Crear actividad",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(label),
      trailing: Icon(Icons.calendar_month, color: primaryColor),
      onTap: onTap,
    );
  }
}
