import 'Actividad.dart';
import 'Certificado.dart';

class Empresa {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? logoURL;
  final String email;
  final String passwordHash;
  final List<Actividad>? actividades;
  final List<Certificado>? certificados;

  Empresa({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.logoURL,
    required this.email,
    required this.passwordHash,
    this.actividades,
    this.certificados,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      direccion: json['direccion'],
      logoURL: json['logoURL'],
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      actividades: json['actividades'] != null
          ? (json['actividades'] as List)
                .map((a) => Actividad.fromJson(a))
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
      'descripcion': descripcion,
      'direccion': direccion,
      'logoURL': logoURL,
      'email': email,
      'passwordHash': passwordHash,
      'actividades': actividades?.map((a) => a.toJson()).toList(),
      'certificados': certificados?.map((c) => c.toJson()).toList(),
    };
  }
}
