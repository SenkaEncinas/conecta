class UpdateActividadDto {
  final String nombreActividad;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int cupos;
  final bool estado;

  UpdateActividadDto({
    required this.nombreActividad,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.cupos,
    required this.estado,
  });

  factory UpdateActividadDto.fromJson(Map<String, dynamic> json) {
    return UpdateActividadDto(
      nombreActividad: json['nombreActividad'] ?? '',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      cupos: json['cupos'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreActividad': nombreActividad,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'cupos': cupos,
      'estado': estado,
    };
  }
}
