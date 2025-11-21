import 'Postulacion.dart';

class Actividad {
  final int id;
  final int empresaId;
  final String nombreActividad;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int cupos;
  final bool estado;
  final List<Postulacion>? postulaciones;

  Actividad({
    required this.id,
    required this.empresaId,
    required this.nombreActividad,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.cupos,
    this.estado = true,
    this.postulaciones,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'] ?? 0,
      empresaId: json['empresaId'] ?? 0,
      nombreActividad: json['nombreActividad'] ?? '',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      cupos: json['cupos'] ?? 0,
      estado: json['estado'] ?? true,
      postulaciones: json['postulaciones'] != null
          ? (json['postulaciones'] as List)
                .map((p) => Postulacion.fromJson(p))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'nombreActividad': nombreActividad,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'cupos': cupos,
      'estado': estado,
      'postulaciones': postulaciones?.map((p) => p.toJson()).toList(),
    };
  }
}
