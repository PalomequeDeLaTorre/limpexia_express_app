import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UsuarioService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cambiar estado Disponible/No Disponible
  Future<void> cambiarDisponibilidad(bool estaDisponible) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Actualiza solo el campo 'disponible' dentro del nodo del usuario
      await _dbRef.child('usuarios/${user.uid}').update({
        'disponible': estaDisponible,
      });
    }
  }

  // Escucha el estado del usuario en tiempo real
  Stream<DatabaseEvent> get streamUsuario {
    String? uid = _auth.currentUser?.uid;
    return _dbRef.child('usuarios/$uid').onValue;
  }
}