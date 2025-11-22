import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/ActividadService.dart';
import 'package:conectaflutter/DTO/Core/ActividadDto.dart';
import 'package:conectaflutter/screens/User/ActividadDetalleScreen.dart';

class ActividadesListScreen extends StatefulWidget {
  const ActividadesListScreen({super.key});

  @override
  State<ActividadesListScreen> createState() => _ActividadesListScreenState();
}

class _ActividadesListScreenState extends State<ActividadesListScreen> {
  final ActividadService _actividadService = ActividadService();
  late Future<List<ActividadDto>> _futureActividades;

  @override
  void initState() {
    super.initState();
    _futureActividades = _actividadService.getActividades();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureActividades = _actividadService.getActividades();
    });
  }

  String _formatFecha(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final y = fecha.year.toString();
    return "$d/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actividades disponibles"),
      ),
      body: FutureBuilder<List<ActividadDto>>(
        future: _futureActividades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final actividades = snapshot.data ?? [];

          if (actividades.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text("No hay actividades por ahora")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final a = actividades[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(a.nombreActividad),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Empresa: ${a.nombreEmpresa}"),
                        if (a.descripcion != null &&
                            a.descripcion!.isNotEmpty)
                          Text(
                            a.descripcion!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text("Inicio: ${_formatFecha(a.fechaInicio)}"),
                        Text("Fin: ${_formatFecha(a.fechaFin)}"),
                        Text("Cupos: ${a.cupos} • Estado: ${a.estado}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ActividadDetalleScreen(actividad: a),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
