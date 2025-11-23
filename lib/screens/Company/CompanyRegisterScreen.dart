import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/AuthService.dart';
import 'package:conectaflutter/DTO/Auth/RegisterEmpresaDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dto = RegisterEmpresaDto(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );

      final EmpresaDto? empresa = await _authService.registerEmpresa(dto);

      if (empresa != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro empresa exitoso")),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = "No se pudo registrar la empresa. Revisá los datos.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error inesperado: $e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple.shade600;
    final secondaryColor = Colors.deepPurple.shade50;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("Registro Empresa"),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Crear cuenta empresa",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  _buildTextField(
                    controller: _nombreController,
                    label: "Nombre de la empresa",
                    icon: Icons.business,
                    validatorMsg: "Ingresá el nombre",
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: "Correo de contacto",
                    icon: Icons.email,
                    validatorMsg: "Ingresá el correo",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // Contraseña
                  _buildTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    icon: Icons.lock,
                    validatorMsg: "Ingresá una contraseña",
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  // Dirección (opcional)
                  _buildTextField(
                    controller: _direccionController,
                    label: "Dirección (opcional)",
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 12),

                  // Descripción (opcional)
                  _buildTextField(
                    controller: _descripcionController,
                    label: "Descripción (opcional)",
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Error
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Botón registrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Registrar empresa",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMsg,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validatorMsg != null
          ? (v) => v == null || v.isEmpty ? validatorMsg : null
          : null,
    );
  }
}
