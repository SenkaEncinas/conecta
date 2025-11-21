class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  // Para enviar este DTO como JSON al backend
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  // Para recibir este DTO desde el backend (si fuera necesario)
  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
