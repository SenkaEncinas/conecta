import 'Usuario.dart';
import 'Empresa.dart';
import 'Actividad.dart';

class Certificado {
  final int id;
  final int usuarioId;
  final Usuario? usuario;
  final int empresaId;
  final Empresa? empresa;
  final int actividadId;
  final Actividad? actividad;
  final int horasCertificadas;
  final DateTime fechaEmision;
  final String urlCertificadoPDF;

  Certificado({
    required this.id,
    required this.usuarioId,
    this.usuario,
    required this.empresaId,
    this.empresa,
    required this.actividadId,
    this.actividad,
    required this.horasCertificadas,
    required this.fechaEmision,
    required this.urlCertificadoPDF,
  });

  factory Certificado.fromJson(Map<String, dynamic> json) {
    return Certificado(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      usuario: json['usuario'] != null
          ? Usuario.fromJson(json['usuario'])
          : null,
      empresaId: json['empresaId'] ?? 0,
      empresa: json['empresa'] != null
          ? Empresa.fromJson(json['empresa'])
          : null,
      actividadId: json['actividadId'] ?? 0,
      actividad: json['actividad'] != null
          ? Actividad.fromJson(json['actividad'])
          : null,
      horasCertificadas: json['horasCertificadas'] ?? 0,
      fechaEmision: json['fechaEmision'] != null
          ? DateTime.parse(json['fechaEmision'])
          : DateTime.now(),
      urlCertificadoPDF: json['urlCertificadoPDF'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuario': usuario?.toJson(),
      'empresaId': empresaId,
      'empresa': empresa?.toJson(),
      'actividadId': actividadId,
      'actividad': actividad?.toJson(),
      'horasCertificadas': horasCertificadas,
      'fechaEmision': fechaEmision.toIso8601String(),
      'urlCertificadoPDF': urlCertificadoPDF,
    };
  }
}
