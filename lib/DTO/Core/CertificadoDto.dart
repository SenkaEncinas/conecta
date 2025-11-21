class CertificadoDto {
  final int id;
  final String nombreVoluntario;
  final String nombreEmpresa;
  final String nombreActividad;
  final int horasCertificadas;
  final DateTime fechaEmision;
  final String urlCertificadoPDF;

  CertificadoDto({
    required this.id,
    required this.nombreVoluntario,
    required this.nombreEmpresa,
    required this.nombreActividad,
    required this.horasCertificadas,
    required this.fechaEmision,
    required this.urlCertificadoPDF,
  });

  factory CertificadoDto.fromJson(Map<String, dynamic> json) {
    return CertificadoDto(
      id: json["id"] ?? 0,
      nombreVoluntario: json["nombreVoluntario"] ?? "",
      nombreEmpresa: json["nombreEmpresa"] ?? "",
      nombreActividad: json["nombreActividad"] ?? "",
      horasCertificadas: json["horasCertificadas"] ?? 0,
      fechaEmision: DateTime.parse(json["fechaEmision"]),
      urlCertificadoPDF: json["urlCertificadoPDF"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombreVoluntario": nombreVoluntario,
      "nombreEmpresa": nombreEmpresa,
      "nombreActividad": nombreActividad,
      "horasCertificadas": horasCertificadas,
      "fechaEmision": fechaEmision.toIso8601String(),
      "urlCertificadoPDF": urlCertificadoPDF,
    };
  }
}
