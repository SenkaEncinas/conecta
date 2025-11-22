import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/CertificadoService.dart';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';

class MisCertificadosScreen extends StatefulWidget {
  final int? usuarioId;

  const MisCertificadosScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<MisCertificadosScreen> createState() => _MisCertificadosScreenState();
}

class _MisCertificadosScreenState extends State<MisCertificadosScreen> {
  final CertificadoService _certificadoService = CertificadoService();
  late Future<List<CertificadoDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _getCertificadosUsuarioSafe();
  }

  Future<List<CertificadoDto>> _getCertificadosUsuarioSafe() async {
    // Si por algún motivo llega null, no rompemos la app:
    final id = widget.usuarioId;
    if (id == null) {
      debugPrint("⚠ MisCertificadosScreen: usuarioId es null");
      // Podrías lanzar una excepción para que se vea en pantalla:
      // throw Exception("Usuario no válido");
      return [];
    }

    try {
      // ✅ Llamada real al service
      return await _certificadoService.getCertificadosByUsuario(id);
    } catch (e, st) {
      debugPrint("❌ Error obteniendo certificados: $e\n$st");
      // Deja que el FutureBuilder muestre el error:
      throw Exception("No se pudieron cargar los certificados");
    }
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
      appBar: AppBar(title: const Text("Mis Certificados")),
      body: FutureBuilder<List<CertificadoDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Ocurrió un error al cargar tus certificados.\n\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final certificados = snapshot.data ?? [];

          if (certificados.isEmpty) {
            return const Center(
              child: Text(
                "Aún no tienes certificados.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: certificados.length,
            itemBuilder: (context, index) {
              final c = certificados[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(
                    c.nombreActividad.isNotEmpty
                        ? c.nombreActividad
                        : "Certificado #${c.id}",
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.nombreEmpresa.isNotEmpty)
                        Text("Empresa: ${c.nombreEmpresa}"),
                      Text("Horas certificadas: ${c.horasCertificadas}"),
                      Text("Fecha emisión: ${_formatFecha(c.fechaEmision)}"),
                    ],
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // TODO: abrir PDF con c.urlCertificadoPDF usando url_launcher o similar
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
