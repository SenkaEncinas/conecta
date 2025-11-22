import 'package:conectaflutter/screens/HomeSelectorScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ConectaApp());
}

class ConectaApp extends StatelessWidget {
  const ConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conecta',
      debugShowCheckedModeBanner: false,
      home: const HomeSelectorScreen(),
    );
  }
}
