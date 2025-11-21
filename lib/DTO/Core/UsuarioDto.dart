class UsuarioDto {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? fotoPerfilURL;
  final String? curriculumSocial;
  final String tipoUsuario;
  final String? token;

  UsuarioDto({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.fotoPerfilURL,
    this.curriculumSocial,
    required this.tipoUsuario,
    this.token,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json["id"] ?? 0,
      nombre: json["nombre"] ?? "",
      apellido: json["apellido"] ?? "",
      email: json["email"] ?? "",
      fotoPerfilURL: json["fotoPerfilURL"],
      curriculumSocial: json["curriculumSocial"],
      tipoUsuario: json["tipoUsuario"] ?? "",
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre": nombre,
      "apellido": apellido,
      "email": email,
      "fotoPerfilURL": fotoPerfilURL,
      "curriculumSocial": curriculumSocial,
      "tipoUsuario": tipoUsuario,
      "token": token,
    };
  }
}
