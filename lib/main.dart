import 'package:flutter/material.dart';
import 'screens/LoginScreen.dart'; // Ajusta la ruta según tu proyecto

void main() {
  runApp(const ConectaApp());
}

class ConectaApp extends StatelessWidget {
  const ConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conecta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
