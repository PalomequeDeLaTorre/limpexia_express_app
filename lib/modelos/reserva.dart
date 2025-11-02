class Reserva {
  final String id;
  final String servicioId;
  final String clienteId;
  final String profesionalId;
  final DateTime fechaReserva;
  final String estado; 
  final double precio;
  final String? notas;
  final DateTime fechaCreacion;

  Reserva({
    required this.id,
    required this.servicioId,
    required this.clienteId,
    required this.profesionalId,
    required this.fechaReserva,
    required this.estado,
    required this.precio,
    this.notas,
    required this.fechaCreacion,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? '',
      servicioId: json['servicioId'] ?? '',
      clienteId: json['clienteId'] ?? '',
      profesionalId: json['profesionalId'] ?? '',
      fechaReserva: DateTime.parse(json['fechaReserva']),
      estado: json['estado'] ?? 'pendiente',
      precio: json['precio']?.toDouble() ?? 0.0,
      notas: json['notas'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicioId': servicioId,
      'clienteId': clienteId,
      'profesionalId': profesionalId,
      'fechaReserva': fechaReserva.toIso8601String(),
      'estado': estado,
      'precio': precio,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}