import 'package:conectaflutter/screens/admin/AdminHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/AuthService.dart';
import 'package:conectaflutter/DTO/Auth/LoginDto.dart';
import 'package:conectaflutter/DTO/Core/UsuarioDto.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/screens/User/VoluntarioHomeScreen.dart';
import 'package:conectaflutter/screens/User/UserRegisterScreen.dart';

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

      if (result is UsuarioDto) {
        final tipo = result.tipoUsuario?.toLowerCase();

        if (tipo == "admin") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bienvenido Administrador")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomeScreen(admin: result)),
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

      if (result is EmpresaDto) {
        setState(() {
          _errorMessage =
              "Esta cuenta pertenece a una empresa. Usá el login de empresa.";
        });
        return;
      }

      setState(() => _errorMessage = "Correo o contraseña incorrectos.");
    } catch (e) {
      setState(() {
        if (e.toString().contains("SocketException")) {
          _errorMessage = "No hay conexión a internet.";
        } else if (e.toString().contains("500")) {
          _errorMessage = "Servidor no disponible. Intente más tarde.";
        } else {
          _errorMessage = "Error inesperado: $e";
        }
      });
    } finally {
      setState(() => _isLoading = false);
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
    final primary = const Color(0xFF1A73E8);

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Fondo degradado elegante
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

          // 🔙 BOTÓN VOLVER
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
                      Icon(Icons.person_pin_circle, size: 90, color: primary),
                      const SizedBox(height: 18),

                      const Text(
                        "Ingreso de Usuario / Admin",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3B52),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // EMAIL INPUT
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

                      // PASSWORD INPUT
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

                      const SizedBox(height: 22),

                      // ERROR
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // BOTÓN LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  "Ingresar",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🧾 ¿NO TENÉS CUENTA?
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserRegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "¿No tenés cuenta? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: "Registrate",
                                style: TextStyle(
                                  color: Color(0xFF1A73E8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
