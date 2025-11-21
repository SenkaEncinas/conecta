class UpdateUsuarioDto {
  final String nombre;
  final String apellido;
  final String? curriculumSocial;
  final String? fotoPerfilURL;

  UpdateUsuarioDto({
    required this.nombre,
    required this.apellido,
    this.curriculumSocial,
    this.fotoPerfilURL,
  });

  factory UpdateUsuarioDto.fromJson(Map<String, dynamic> json) {
    return UpdateUsuarioDto(
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      curriculumSocial: json['curriculumSocial'],
      fotoPerfilURL: json['fotoPerfilURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'curriculumSocial': curriculumSocial,
      'fotoPerfilURL': fotoPerfilURL,
    };
  }
}
