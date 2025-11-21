class ActividadDto {
  final int id;
  final int empresaId;
  final String nombreEmpresa;
  final String nombreActividad;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int cupos;
  final String estado;

  ActividadDto({
    required this.id,
    required this.empresaId,
    required this.nombreEmpresa,
    required this.nombreActividad,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.cupos,
    required this.estado,
  });

  factory ActividadDto.fromJson(Map<String, dynamic> json) {
    return ActividadDto(
      id: json["id"] ?? 0,
      empresaId: json["empresaId"] ?? 0,
      nombreEmpresa: json["nombreEmpresa"] ?? "",
      nombreActividad: json["nombreActividad"] ?? "",
      descripcion: json["descripcion"],
      fechaInicio: DateTime.parse(json["fechaInicio"]),
      fechaFin: DateTime.parse(json["fechaFin"]),
      cupos: json["cupos"] ?? 0,
      estado: json["estado"] ?? "Disponible",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "empresaId": empresaId,
      "nombreEmpresa": nombreEmpresa,
      "nombreActividad": nombreActividad,
      "descripcion": descripcion,
      "fechaInicio": fechaInicio.toIso8601String(),
      "fechaFin": fechaFin.toIso8601String(),
      "cupos": cupos,
      "estado": estado,
    };
  }
}
