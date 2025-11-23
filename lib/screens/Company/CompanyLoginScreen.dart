import 'package:conectaflutter/screens/Company/CompanyRegisterScreen.dart';
import 'package:conectaflutter/screens/Company/EmpresaHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/AuthService.dart';
import 'package:conectaflutter/DTO/Auth/LoginDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dto = LoginDto(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final result = await _authService.login(dto, "");

      if (!mounted) return;

      if (result is EmpresaDto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login empresa exitoso")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmpresaHomeScreen(empresa: result)),
        );
        return;
      }

      if (result is UsuarioDto) {
        setState(() {
          _errorMessage =
              "Esta cuenta corresponde a un voluntario/admin. Usá login de voluntario.";
        });
        return;
      }

      setState(() {
        _errorMessage = "Credenciales incorrectas o error en el servidor.";
      });
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple.shade600;
    final secondaryColor = Colors.deepPurple.shade100;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo o icono grande
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business_center,
                  size: 50,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login Empresa",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Correo de empresa",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.business, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Ingresá tu correo";
                          if (!value.contains("@")) return "Correo inválido";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.lock, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Ingresá tu contraseña";
                          if (value.length < 4) return "Contraseña muy corta";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Error
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            _isLoading ? "Ingresando..." : "Ingresar",
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                          ),
                          onPressed: _isLoading ? null : _login,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Botones extra: Volver / Registrarse
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Volver"),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CompanyRegisterScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.app_registration),
                            label: const Text("Registrarte"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
