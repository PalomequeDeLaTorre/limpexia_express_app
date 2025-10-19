import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/usuario.dart';
import '../modelos/servicio.dart';
import '../modelos/reserva.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticación
  Future<User?> registrar(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  User? obtenerUsuarioActual() {
    return _auth.currentUser;
  }

  // Usuarios
  Future<void> crearUsuario(Usuario usuario) async {
    await _firestore.collection('usuarios').doc(usuario.id).set(usuario.toJson());
  }

  Future<Usuario?> obtenerUsuario(String id) async {
    final doc = await _firestore.collection('usuarios').doc(id).get();
    if (doc.exists) {
      return Usuario.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Servicios
  Future<String> crearServicio(Servicio servicio) async {
    final doc = await _firestore.collection('servicios').add(servicio.toJson());
    return doc.id;
  }

  Future<List<Servicio>> obtenerServicios() async {
    final query = await _firestore.collection('servicios').get();
    return query.docs.map((doc) => 
      Servicio.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
  }

  Future<List<Servicio>> obtenerServiciosPorCategoria(String categoria) async {
    final query = await _firestore
        .collection('servicios')
        .where('categoria', isEqualTo: categoria)
        .get();
    return query.docs.map((doc) => 
      Servicio.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
  }

  // Reservas
  Future<String> crearReserva(Reserva reserva) async {
    final doc = await _firestore.collection('reservas').add(reserva.toJson());
    return doc.id;
  }

  Future<List<Reserva>> obtenerReservasCliente(String clienteId) async {
    final query = await _firestore
        .collection('reservas')
        .where('clienteId', isEqualTo: clienteId)
        .get();
    return query.docs.map((doc) => 
      Reserva.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
  }

  Future<List<Reserva>> obtenerReservasProfesional(String profesionalId) async {
    final query = await _firestore
        .collection('reservas')
        .where('profesionalId', isEqualTo: profesionalId)
        .get();
    return query.docs.map((doc) => 
      Reserva.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
  }

  Future<void> actualizarEstadoReserva(String reservaId, String estado) async {
    await _firestore.collection('reservas').doc(reservaId).update({
      'estado': estado,
    });
  }
}