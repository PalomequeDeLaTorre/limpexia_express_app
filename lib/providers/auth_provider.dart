import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseDatabase get _database => FirebaseDatabase.instance;

  bool cargando = false;
  String? errorMensaje;
  String? userRole;

  // Campos añadidos;
  String? _nombreUsuario;
  String? _profesion;
  String? _fotoPerfilUrl;

  // Getters públicos;
  String? get nombreUsuario => _nombreUsuario;
  String? get profesion => _profesion;
  String? get fotoPerfilUrl => _fotoPerfilUrl;

 // Iniciar sesión;
  Future<bool> iniciarSesion(String email, String password) async {
    try {
      cargando = true;
      errorMensaje = null;
      userRole = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("No se pudo obtener el usuario.");

      // Obtener datos desde Realtime Database;
      final userRef = _database.ref('usuarios/${user.uid}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        userRole = data['rol'] as String?;
        _nombreUsuario = data['nombre'] as String?;
        _profesion = data['profesion'] as String?;
        _fotoPerfilUrl = data['fotoPerfilUrl'] as String?;
      } else {
        throw Exception('Datos de usuario no encontrados en la base de datos.');
      }

      cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      cargando = false;
      errorMensaje = _obtenerMensajeDeError(e);
      notifyListeners();
      return false;
    }
  }

  // Registrar usuario;
  Future<bool> registrarUsuario(
    String email,
    String password,
    String nombre,
    String telefono,
    String rol,
    String? profesion,
  ) async {
    try {
      cargando = true;
      errorMensaje = null;
      userRole = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("No se pudo crear el usuario.");

      // Datos a guardar;
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'nombre': nombre,
        'telefono': telefono,
        'rol': rol,
        'profesion': profesion ?? '',
        'fotoPerfilUrl': '', 
      };

      // Guardar en RTDB;
      final userRef = _database.ref('usuarios/${user.uid}');
      await userRef.set(userData);

      userRole = rol;
      _nombreUsuario = nombre;
      _profesion = profesion ?? '';
      _fotoPerfilUrl = '';

      cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      cargando = false;
      errorMensaje = _obtenerMensajeDeError(e);
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión;
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    userRole = null;
    _nombreUsuario = null;
    _profesion = null;
    _fotoPerfilUrl = null;
    notifyListeners();
  }

  // Actualizar foto de perfil;
  Future<void> actualizarFotoPerfil(String url) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _database.ref('usuarios/$uid/fotoPerfilUrl').set(url);
    _fotoPerfilUrl = url;
    notifyListeners();
  }

  // Mensajes de error;
  String _obtenerMensajeDeError(dynamic error) {
    final mensaje = error.toString();

    if (mensaje.contains('user-not-found')) return "No existe una cuenta con este correo.";
    if (mensaje.contains('wrong-password')) return "Contraseña incorrecta.";
    if (mensaje.contains('invalid-email')) return "Correo no válido.";
    if (mensaje.contains('email-already-in-use')) return "Este correo ya está registrado.";
    if (mensaje.contains('weak-password')) return "La contraseña es muy débil (mínimo 6 caracteres).";
    if (mensaje.contains('Datos de usuario')) return "No pudimos encontrar tus datos.";

    return "Ocurrió un error inesperado. Intenta de nuevo.";
  }
}
