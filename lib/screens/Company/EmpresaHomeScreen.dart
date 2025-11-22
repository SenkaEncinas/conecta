import 'package:conectaflutter/screens/Company/PostulacionesActividadScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/DTO/Core/EmpresaDto.dart';
import 'package:conectaflutter/screens/Company/MisActividadesEmpresaScreen.dart';
import 'package:conectaflutter/screens/Company/CrearActividadScreen.dart';

class EmpresaHomeScreen extends StatelessWidget {
  final EmpresaDto empresa;
  const EmpresaHomeScreen({super.key, required this.empresa});

  @override
  Widget build(BuildContext context) {
    final nombre = (empresa.nombre ?? "").isNotEmpty ? empresa.nombre! : "Empresa";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio Empresa"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $nombre 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Gestioná tus actividades y postulaciones.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Crear actividad
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Crear actividad"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CrearActividadScreen(empresaId: empresa.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Mis actividades
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text("Mis actividades"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MisActividadesEmpresaScreen(empresaId: empresa.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Postulaciones (pendiente)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Postulaciones"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostulacionesActividadScreen(actividadId: empresa.id),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            const Text(
              "📝 TODO: Agregar listado de postulaciones por actividad cuando esté el GET.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
