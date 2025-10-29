/*import 'package:flutter/material.dart';
import '../servicios/firebase_service.dart';
import '../modelos/reserva.dart';
import '../modelos/servicio.dart';

class ReservaProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Reserva> _reservas = [];
  List<Servicio> _servicios = [];
  bool _cargando = false;

  List<Reserva> get reservas => _reservas;
  List<Servicio> get servicios => _servicios;
  bool get cargando => _cargando;

  Future<void> cargarServicios() async {
    _cargando = true;
    notifyListeners();

    _servicios = await _firebaseService.obtenerServicios();
    
    _cargando = false;
    notifyListeners();
  }

  Future<void> cargarServiciosPorCategoria(String categoria) async {
    _cargando = true;
    notifyListeners();

    _servicios = await _firebaseService.obtenerServiciosPorCategoria(categoria);
    
    _cargando = false;
    notifyListeners();
  }

  Future<bool> crearReserva(Reserva reserva) async {
    try {
      await _firebaseService.crearReserva(reserva);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> cargarReservasCliente(String clienteId) async {
    _cargando = true;
    notifyListeners();

    _reservas = await _firebaseService.obtenerReservasCliente(clienteId);
    
    _cargando = false;
    notifyListeners();
  }

  Future<void> cargarReservasProfesional(String profesionalId) async {
    _cargando = true;
    notifyListeners();

    _reservas = await _firebaseService.obtenerReservasProfesional(profesionalId);
    
    _cargando = false;
    notifyListeners();
  }

  Future<bool> actualizarEstado(String reservaId, String estado) async {
    try {
      await _firebaseService.actualizarEstadoReserva(reservaId, estado);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}

*/