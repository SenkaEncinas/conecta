class EmpresaDto {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? logoURL;
  final String email;
  final String? token;

  EmpresaDto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.logoURL,
    required this.email,
    this.token,
  });

  factory EmpresaDto.fromJson(Map<String, dynamic> json) {
    return EmpresaDto(
      id: json["id"] ?? 0,
      nombre: json["nombre"] ?? "",
      descripcion: json["descripcion"],
      direccion: json["direccion"],
      logoURL: json["logoURL"],
      email: json["email"] ?? "",
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre": nombre,
      "descripcion": descripcion,
      "direccion": direccion,
      "logoURL": logoURL,
      "email": email,
      "token": token,
    };
  }
}
