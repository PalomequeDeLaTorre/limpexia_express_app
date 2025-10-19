class Servicio {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final double precio;
  final String profesionalId;
  final String profesionalNombre;
  final double? calificacion;
  final DateTime fechaCreacion;

  Servicio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.precio,
    required this.profesionalId,
    required this.profesionalNombre,
    this.calificacion,
    required this.fechaCreacion,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: json['precio']?.toDouble() ?? 0.0,
      profesionalId: json['profesionalId'] ?? '',
      profesionalNombre: json['profesionalNombre'] ?? '',
      calificacion: json['calificacion']?.toDouble(),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'profesionalId': profesionalId,
      'profesionalNombre': profesionalNombre,
      'calificacion': calificacion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}