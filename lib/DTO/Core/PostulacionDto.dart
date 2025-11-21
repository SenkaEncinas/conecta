class PostulacionDto {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final int actividadId;
  final String nombreActividad;
  final String estado;
  final DateTime fechaPostulacion;
  final int horasAsignadas;
  final int horasCompletadas;

  PostulacionDto({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.actividadId,
    required this.nombreActividad,
    required this.estado,
    required this.fechaPostulacion,
    required this.horasAsignadas,
    required this.horasCompletadas,
  });

  factory PostulacionDto.fromJson(Map<String, dynamic> json) {
    return PostulacionDto(
      id: json["id"] ?? 0,
      usuarioId: json["usuarioId"] ?? 0,
      nombreUsuario: json["nombreUsuario"] ?? "",
      actividadId: json["actividadId"] ?? 0,
      nombreActividad: json["nombreActividad"] ?? "",
      estado: json["estado"] ?? "",
      fechaPostulacion: DateTime.parse(json["fechaPostulacion"]),
      horasAsignadas: json["horasAsignadas"] ?? 0,
      horasCompletadas: json["horasCompletadas"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "usuarioId": usuarioId,
      "nombreUsuario": nombreUsuario,
      "actividadId": actividadId,
      "nombreActividad": nombreActividad,
      "estado": estado,
      "fechaPostulacion": fechaPostulacion.toIso8601String(),
      "horasAsignadas": horasAsignadas,
      "horasCompletadas": horasCompletadas,
    };
  }
}
