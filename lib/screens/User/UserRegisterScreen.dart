import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/AuthService.dart';
import 'package:conectaflutter/DTO/Auth/RegisterVoluntarioDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      final dto = RegisterVoluntarioDto(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final UsuarioDto? usuario = await _authService.registerVoluntario(dto);

      if (usuario != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro voluntario exitoso")),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = "No se pudo registrar. Revisá los datos.";
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains("SocketException")) {
          _errorMessage = "No hay conexión a internet.";
        } else if (e.toString().contains("500")) {
          _errorMessage = "Error del servidor. Intenta más tarde.";
        } else {
          _errorMessage = "Error inesperado: $e";
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1A73E8);

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE6EDF6),
                  Color(0xFFDDE7F5),
                  Color(0xFFC7D7EE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔙 Botón volver
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.black87),
                  SizedBox(width: 6),
                  Text(
                    "Volver",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 480,
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(Icons.person_add_alt_1, size: 90, color: primary),
                      const SizedBox(height: 18),

                      const Text(
                        "Registro Voluntario",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3B52),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "Completá tus datos para crear una cuenta",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // NOMBRE
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: "Nombre",
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          prefixIcon: Icon(Icons.person, color: primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Ingresá tu nombre" : null,
                      ),

                      const SizedBox(height: 16),

                      // APELLIDO
                      TextFormField(
                        controller: _apellidoController,
                        decoration: InputDecoration(
                          labelText: "Apellido",
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Ingresá tu apellido"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // EMAIL
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Correo electrónico",
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Ingresá tu correo" : null,
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          prefixIcon: Icon(Icons.lock_outline, color: primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Ingresá una contraseña"
                            : null,
                      ),

                      const SizedBox(height: 22),

                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // BOTÓN REGISTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Registrarme",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      // ... después del botón REGISTRAR
                      const SizedBox(height: 20),

                      // TEXTO "Ya tenés cuenta?"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "¿Ya tenés cuenta? ",
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // o Navigator.push si quieres forzar ir a UserLoginScreen
                            },
                            child: Text(
                              "Ingresá aquí",
                              style: TextStyle(
                                fontSize: 15,
                                color: primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
