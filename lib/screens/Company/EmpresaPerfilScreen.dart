import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Entities/UpdateEmpresaDto.dart';
import 'package:conectaflutter/Services/EmpresaService.dart';

class EmpresaPerfilScreen extends StatefulWidget {
  final EmpresaDto empresa;
  final ValueChanged<EmpresaDto> onSave;

  const EmpresaPerfilScreen({
    super.key,
    required this.empresa,
    required this.onSave,
  });

  @override
  State<EmpresaPerfilScreen> createState() => _EmpresaPerfilScreenState();
}

class _EmpresaPerfilScreenState extends State<EmpresaPerfilScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _direccionController;
  late TextEditingController _logoUrlController;

  final _formKey = GlobalKey<FormState>();
  final EmpresaService _empresaService = EmpresaService();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.empresa.nombre);
    _descripcionController =
        TextEditingController(text: widget.empresa.descripcion ?? "");
    _direccionController =
        TextEditingController(text: widget.empresa.direccion ?? "");
    _logoUrlController =
        TextEditingController(text: widget.empresa.logoURL ?? "");
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updateDto = UpdateEmpresaDto(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty
          ? null
          : _direccionController.text.trim(),
      logoURL: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
    );

    final ok = await _empresaService.updateEmpresa(widget.empresa.id, updateDto);

    setState(() => _isSaving = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo actualizar la empresa. Intentalo de nuevo."),
        ),
      );
      return;
    }

    // Construimos un EmpresaDto actualizado en base a lo que se guardó
    final updatedEmpresa = EmpresaDto(
      id: widget.empresa.id,
      nombre: updateDto.nombre,
      descripcion: updateDto.descripcion,
      direccion: updateDto.direccion,
      logoURL: updateDto.logoURL,
      email: widget.empresa.email, // email se mantiene igual
      token: widget.empresa.token,
    );

    // Devolvemos al home
    widget.onSave(updatedEmpresa);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos actualizados correctamente.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.empresa.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil de la empresa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Datos de la empresa",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Email solo lectura (no lo maneja UpdateEmpresaDto)
              Text(
                "Email (no editable desde aquí):",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "El nombre es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _logoUrlController,
                decoration: const InputDecoration(
                  labelText: "Logo URL (opcional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? "Guardando..." : "Guardar cambios"),
                  onPressed: _isSaving ? null : _guardarCambios,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
