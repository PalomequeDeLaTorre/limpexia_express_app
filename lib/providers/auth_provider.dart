import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // CAMBIA ESTO: Usar getters en lugar de instancias directas
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseDatabase get _database => FirebaseDatabase.instance;

  bool cargando = false;
  String? errorMensaje;
  String? userRole;

  Future<bool> iniciarSesion(String email, String password) async {
    try {
      cargando = true;
      errorMensaje = null;
      userRole = null;
      notifyListeners();

      // VERIFICAR que Firebase esté listo
      if (_auth.app.name.isEmpty) {
        throw Exception("Firebase no está inicializado");
      }

      // Iniciar sesión en Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("No se pudo obtener el usuario después de iniciar sesión.");
      }

      // Obtener el rol desde Realtime Database
      final userRef = _database.ref('usuarios/${user.uid}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        userRole = data['rol'] as String?;

        if (userRole == null) {
          throw Exception('El rol del usuario no está definido en la base de datos.');
        }
      } else {
        throw Exception('No se encontraron datos de usuario en la base de datos.');
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

      // VERIFICAR que Firebase esté listo
      if (_auth.app.name.isEmpty) {
        throw Exception("Firebase no está inicializado");
      }

      // Crear el usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("No se pudo crear el usuario.");
      }

      // Preparar los datos para Realtime Database
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'nombre': nombre,
        'telefono': telefono,
        'rol': rol,
      };

      if (rol == 'profesional' && profesion != null && profesion.isNotEmpty) {
        userData['profesion'] = profesion;
      }

      // guardar los datos en Realtime Database
      final userRef = _database.ref('usuarios/${user.uid}');
      await userRef.set(userData);

      userRole = rol;
      cargando = false;
      notifyListeners();
      return true;

    } catch (e) {
      cargando = false;
      if (e is FirebaseAuthException) {
        print('Código de error: ${e.code}');
        print('Mensaje de error: ${e.message}');
      } else {
        print('Error genérico: $e');
      }
      errorMensaje = _obtenerMensajeDeError(e);
      notifyListeners();
      return false;
    }
  }

  // --- MÉTODO PARA CERRAR SESIÓN ---
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    userRole = null;
    notifyListeners();
  }

  String _obtenerMensajeDeError(dynamic error) {
    String mensaje = error.toString();
    
    // Errores de Login
    if (mensaje.contains('user-not-found')) return "No existe una cuenta con este correo.";
    if (mensaje.contains('wrong-password')) return "Contraseña incorrecta.";
    if (mensaje.contains('invalid-email')) return "Correo no válido.";

    // Errores de Registro
    if (mensaje.contains('email-already-in-use')) return "Este correo ya está registrado.";
    if (mensaje.contains('weak-password')) return "La contraseña es muy débil (mínimo 6 caracteres).";
    
    // Errores de RTDB
    if (mensaje.contains('Rol no definido')) return "Tu cuenta no tiene un rol asignado.";
    if (mensaje.contains('Datos de usuario no encontrados')) return "No pudimos encontrar tus datos de perfil.";
    
    // Error genérico
    return "Ocurrió un error inesperado. Intenta de nuevo.";
  }
}