import 'package:flutter/material.dart';
import 'package:conectaflutter/Services/CertificadoService.dart';
import 'package:conectaflutter/DTO/Core/CertificadoDto.dart';
import 'package:url_launcher/url_launcher.dart';

class MisCertificadosScreen extends StatefulWidget {
  final int? usuarioId;

  const MisCertificadosScreen({super.key, required this.usuarioId});

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
    final id = widget.usuarioId;
    if (id == null) {
      debugPrint("⚠ MisCertificadosScreen: usuarioId es null");
      return [];
    }

    try {
      final certificados = await _certificadoService.getCertificadosByUsuario(
        id,
      );
      debugPrint("🚀 Certificados obtenidos: ${certificados.length}");
      return certificados;
    } catch (e, st) {
      debugPrint("❌ Error obteniendo certificados: $e\n$st");
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
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Mis Certificados"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
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
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: certificados.length,
            itemBuilder: (context, index) {
              final c = certificados[index];

              return GestureDetector(
                onTap: () => _abrirPDF(c.urlCertificadoPDF),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.nombreActividad.isNotEmpty
                                  ? c.nombreActividad
                                  : "Certificado #${c.id}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (c.nombreEmpresa.isNotEmpty)
                              Text(
                                "Empresa: ${c.nombreEmpresa}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              "Horas: ${c.horasCertificadas} • Fecha: ${_formatFecha(c.fechaEmision)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _abrirPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No se pudo abrir el PDF")));
    }
  }
}
