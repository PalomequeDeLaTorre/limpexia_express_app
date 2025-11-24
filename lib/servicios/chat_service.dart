import 'package:firebase_database/firebase_database.dart';

class ChatService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Enviar mensaje
  Future<void> enviarMensaje(String solicitudId, String texto, String miUid) async {
    if (texto.trim().isEmpty) return;

    try {
      // Crear un nuevo nodo con ID automático dentro de la solicitud
      await _dbRef.child('mensajes').child(solicitudId).push().set({
        'remitenteId': miUid,
        'texto': texto.trim(),
        'timestamp': ServerValue.timestamp, // Marca de tiempo del servidor
      });
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }

  // Escuchar mensajes
  Stream<DatabaseEvent> streamMensajes(String solicitudId) {
    // Ordenar por timestamp para verlos cronológicamente
    return _dbRef
        .child('mensajes')
        .child(solicitudId)
        .orderByChild('timestamp')
        .onValue;
  }
}