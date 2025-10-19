import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servicios/firebase_service.dart';
import '../modelos/usuario.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Usuario? _usuario;
  bool _cargando = false;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  bool get estaAutenticado => _usuario != null;

  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String tipo,
    String? profesion,
  }) async {
    try {
      _cargando = true;
      notifyListeners();

      final user = await _firebaseService.registrar(email, password);
      if (user != null) {
        final nuevoUsuario = Usuario(
          id: user.uid,
          nombre: nombre,
          email: email,
          telefono: telefono,
          tipo: tipo,
          profesion: profesion,
          fechaRegistro: DateTime.now(),
        );
        
        await _firebaseService.crearUsuario(nuevoUsuario);
        _usuario = nuevoUsuario;
        
        _cargando = false;
        notifyListeners();
        return true;
      }
      
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> iniciarSesion(String email, String password) async {
    try {
      _cargando = true;
      notifyListeners();

      final user = await _firebaseService.iniciarSesion(email, password);
      if (user != null) {
        _usuario = await _firebaseService.obtenerUsuario(user.uid);
        _cargando = false;
        notifyListeners();
        return true;
      }
      
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _firebaseService.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }
}