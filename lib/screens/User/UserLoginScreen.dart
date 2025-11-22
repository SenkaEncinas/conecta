import 'package:conectaflutter/screens/admin/AdminHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/AuthService.dart';
import 'package:conectaflutter/DTO/Auth/LoginDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/screens/User/VoluntarioHomeScreen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
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

      // ---------------------------
      //   USUARIO (Admin o Voluntario)
      // ---------------------------
      if (result is UsuarioDto) {
        final tipo = result.tipoUsuario?.toLowerCase();

        if (tipo == "admin") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bienvenido Administrador")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomeScreen(admin: result),
            ),
          );
          return;
        }

        if (tipo == "voluntario") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login voluntario exitoso")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VoluntarioHomeScreen(usuario: result),
            ),
          );
          return;
        }

        setState(() => _errorMessage = "Tipo de usuario no reconocido.");
        return;
      }

      // ---------------------------
      //   EMPRESA
      // ---------------------------
      if (result is EmpresaDto) {
        setState(() {
          _errorMessage =
              "Esta cuenta corresponde a una empresa. Usá el login de empresa.";
        });
        return;
      }

      setState(() {
        _errorMessage = "Credenciales incorrectas o error en servidor.";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Usuario / Admin"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingresá tu correo";
                  }
                  if (!value.contains("@")) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingresá tu contraseña";
                  }
                  if (value.length < 4) {
                    return "Contraseña muy corta";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Ingresar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
