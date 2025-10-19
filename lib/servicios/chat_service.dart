import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String id;
  final String texto;
  final String emisorId;
  final DateTime fecha;

  Mensaje({
    required this.id,
    required this.texto,
    required this.emisorId,
    required this.fecha,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] ?? '',
      texto: json['texto'] ?? '',
      emisorId: json['emisorId'] ?? '',
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'texto': texto,
      'emisorId': emisorId,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Mensaje>> obtenerMensajes(String reservaId) {
    return _firestore
        .collection('chats')
        .doc(reservaId)
        .collection('mensajes')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mensaje.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> enviarMensaje({
    required String reservaId,
    required String texto,
    required String emisorId,
  }) async {
    final mensaje = Mensaje(
      id: '',
      texto: texto,
      emisorId: emisorId,
      fecha: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(reservaId)
        .collection('mensajes')
        .add(mensaje.toJson());
  }
}