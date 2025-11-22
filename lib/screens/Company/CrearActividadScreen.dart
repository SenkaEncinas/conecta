import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/Services/ActividadService.dart';

class CrearActividadScreen extends StatefulWidget {
  final int? empresaId;

  const CrearActividadScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<CrearActividadScreen> createState() => _CrearActividadScreenState();
}

class _CrearActividadScreenState extends State<CrearActividadScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreActividadController =
      TextEditingController();
  final TextEditingController _descripcionController =
      TextEditingController();
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
            content: Text("La fecha fin no puede ser antes que la de inicio")),
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
      // Usamos EXACTAMENTE tu ActividadDto
      final actividad = ActividadDto(
        id: 0, // el backend luego devolverá el id real
        empresaId: widget.empresaId!,
        nombreEmpresa: "", // el backend puede rellenar esto
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
        // devolvemos true para que la pantalla anterior sepa que refresque
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("No se pudo crear la actividad. Revisa el servidor.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear actividad: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Actividad")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Empresa ID: ${widget.empresaId ?? 'sin id'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nombreActividadController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la actividad",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Ingresa el nombre de la actividad";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: "Descripción (opcional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cuposController,
                decoration: const InputDecoration(
                  labelText: "Cupos",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Ingresa la cantidad de cupos";
                  }
                  if (int.tryParse(v) == null) {
                    return "Debe ser un número";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _fechaInicio == null
                      ? "Seleccionar fecha de inicio"
                      : "Fecha inicio: ${_formatFecha(_fechaInicio!)}",
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _seleccionarFechaInicio,
              ),
              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _fechaFin == null
                      ? "Seleccionar fecha de fin"
                      : "Fecha fin: ${_formatFecha(_fechaFin!)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFechaFin,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _crearActividad,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Crear actividad"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
