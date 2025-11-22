import 'package:conectaflutter/screens/User/UserLoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/screens/User/UserLoginScreen.dart';
import 'package:conectaflutter/screens/Company/CompanyLoginScreen.dart';
import 'package:conectaflutter/screens/User/UserRegisterScreen.dart';
import 'package:conectaflutter/screens/Company/CompanyRegisterScreen.dart';

class HomeSelectorScreen extends StatelessWidget {
  const HomeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conecta"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "¿Cómo querés ingresar?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Login Voluntario
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserLoginScreen()),
                );
              },
              child: const Text("Soy Voluntario"),
            ),

            const SizedBox(height: 20),

            // Login Empresa
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompanyLoginScreen()),
                );
              },
              child: const Text("Soy Empresa"),
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "¿Aún no tenés cuenta?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),


            // Registro Voluntario
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserRegisterScreen()),
                );
              },
              child: const Text("Registrarme como Voluntario"),
            ),

            const SizedBox(height: 10),

            // Registro Empresa
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompanyRegisterScreen()),
                );
              },
              child: const Text("Registrarme como Empresa"),
            ),
          ],
        ),
      ),
    );
  }
}
