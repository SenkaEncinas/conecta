class UpdateEmpresaDto {
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? logoURL;

  UpdateEmpresaDto({
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.logoURL,
  });

  factory UpdateEmpresaDto.fromJson(Map<String, dynamic> json) {
    return UpdateEmpresaDto(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      direccion: json['direccion'],
      logoURL: json['logoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'logoURL': logoURL,
    };
  }
}
