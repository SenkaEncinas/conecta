class GenerarCertificadoDto {
  final int usuarioId;
  final int actividadId;
  final int horasCertificadas;

  GenerarCertificadoDto({
    required this.usuarioId,
    required this.actividadId,
    required this.horasCertificadas,
  });

  Map<String, dynamic> toJson() {
    return {
      "usuarioId": usuarioId,
      "actividadId": actividadId,
      "horasCertificadas": horasCertificadas,
    };
  }
}
