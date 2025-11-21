class RegisterVoluntarioDto {
  final String nombre;
  final String apellido;
  final String email;
  final String password;

  RegisterVoluntarioDto({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "apellido": apellido,
      "email": email,
      "password": password,
    };
  }

  factory RegisterVoluntarioDto.fromJson(Map<String, dynamic> json) {
    return RegisterVoluntarioDto(
      nombre: json["nombre"] ?? "",
      apellido: json["apellido"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
    );
  }
}
