import 'Postulacion.dart';
import 'Certificado.dart';

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String passwordHash;
  final String tipoUsuario;
  final DateTime fechaRegistro;
  final String? fotoPerfilURL;
  final String? curriculumSocial;
  final List<Postulacion>? postulaciones;
  final List<Certificado>? certificados;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.passwordHash,
    required this.tipoUsuario,
    DateTime? fechaRegistro,
    this.fotoPerfilURL,
    this.curriculumSocial,
    this.postulaciones,
    this.certificados,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      tipoUsuario: json['tipoUsuario'] ?? '',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
      fotoPerfilURL: json['fotoPerfilURL'],
      curriculumSocial: json['curriculumSocial'],
      postulaciones: json['postulaciones'] != null
          ? (json['postulaciones'] as List)
                .map((p) => Postulacion.fromJson(p))
                .toList()
          : null,
      certificados: json['certificados'] != null
          ? (json['certificados'] as List)
                .map((c) => Certificado.fromJson(c))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'passwordHash': passwordHash,
      'tipoUsuario': tipoUsuario,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fotoPerfilURL': fotoPerfilURL,
      'curriculumSocial': curriculumSocial,
      'postulaciones': postulaciones?.map((p) => p.toJson()).toList(),
      'certificados': certificados?.map((c) => c.toJson()).toList(),
    };
  }
}
