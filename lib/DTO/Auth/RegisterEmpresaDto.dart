class RegisterEmpresaDto {
  final String nombre;
  final String email;
  final String password;
  final String? direccion;
  final String? descripcion;

  RegisterEmpresaDto({
    required this.nombre,
    required this.email,
    required this.password,
    this.direccion,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "email": email,
      "password": password,
      "direccion": direccion,
      "descripcion": descripcion,
    };
  }

  factory RegisterEmpresaDto.fromJson(Map<String, dynamic> json) {
    return RegisterEmpresaDto(
      nombre: json["nombre"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      direccion: json["direccion"],
      descripcion: json["descripcion"],
    );
  }
}
