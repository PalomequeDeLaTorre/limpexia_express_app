class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String tipo; // 'cliente' o 'profesional'
  final String? profesion;
  final double? calificacion;
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.tipo,
    this.profesion,
    this.calificacion,
    required this.fechaRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      tipo: json['tipo'] ?? 'cliente',
      profesion: json['profesion'],
      calificacion: json['calificacion']?.toDouble(),
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'tipo': tipo,
      'profesion': profesion,
      'calificacion': calificacion,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}