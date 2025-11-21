import 'Usuario.dart';
import 'Actividad.dart';

class Postulacion {
  final int id;
  final int usuarioId;
  final Usuario? usuario;
  final int actividadId;
  final Actividad? actividad;
  final String estado;
  final DateTime fechaPostulacion;
  final int horasAsignadas;
  final int horasCompletadas;

  Postulacion({
    required this.id,
    required this.usuarioId,
    this.usuario,
    required this.actividadId,
    this.actividad,
    this.estado = "Pendiente",
    DateTime? fechaPostulacion,
    this.horasAsignadas = 0,
    this.horasCompletadas = 0,
  }) : fechaPostulacion = fechaPostulacion ?? DateTime.now();

  factory Postulacion.fromJson(Map<String, dynamic> json) {
    return Postulacion(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      usuario: json['usuario'] != null
          ? Usuario.fromJson(json['usuario'])
          : null,
      actividadId: json['actividadId'] ?? 0,
      actividad: json['actividad'] != null
          ? Actividad.fromJson(json['actividad'])
          : null,
      estado: json['estado'] ?? "Pendiente",
      fechaPostulacion: json['fechaPostulacion'] != null
          ? DateTime.parse(json['fechaPostulacion'])
          : DateTime.now(),
      horasAsignadas: json['horasAsignadas'] ?? 0,
      horasCompletadas: json['horasCompletadas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuario': usuario?.toJson(),
      'actividadId': actividadId,
      'actividad': actividad?.toJson(),
      'estado': estado,
      'fechaPostulacion': fechaPostulacion.toIso8601String(),
      'horasAsignadas': horasAsignadas,
      'horasCompletadas': horasCompletadas,
    };
  }
}
