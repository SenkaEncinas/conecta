class GenerarCertificadoDto {
  final int usuarioId;
  final int actividadId;
  final int horasCertificadas;

  GenerarCertificadoDto({
    required this.usuarioId,
    required this.actividadId,
    required this.horasCertificadas,
  });

  // ---- PARA ENVIAR AL BACKEND ----
  Map<String, dynamic> toJson() {
    return {
      "usuarioId": usuarioId,
      "actividadId": actividadId,
      "horasCertificadas": horasCertificadas,
    };
  }

  // ---- FACTORY opcional por si necesitas reconstruir ----
  factory GenerarCertificadoDto.fromJson(Map<String, dynamic> json) {
    return GenerarCertificadoDto(
      usuarioId: json["usuarioId"],
      actividadId: json["actividadId"],
      horasCertificadas: json["horasCertificadas"],
    );
  }
}
