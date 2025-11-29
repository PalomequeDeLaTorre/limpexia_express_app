import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SolicitudService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  
  // Crear solicitud con precio;
  Future<String> crearSolicitud({
    required String tipoServicio,
    required List<String> opcionesSeleccionadas,
    required double precioTotal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final ref = _db.child('solicitudes').push();
    
    final solicitudData = {
      'clienteId': user.uid,
      'clienteNombre': user.displayName ?? 'Usuario',
      'tipo': tipoServicio,
      'opciones': opcionesSeleccionadas,
      'precioTotal': precioTotal,
      'estado': 'pendiente',
      'timestamp': ServerValue.timestamp,
      'profesionalId': null,
      'profesionalNombre': null,
    };

    await ref.set(solicitudData);
    return ref.key!;
  }

  //Actualizar progreso de la solicitud ===
  Future<void> actualizarProgreso(String solicitudId, String nuevoEstado) async {
    await _db.child('solicitudes/$solicitudId').update({
      'estado': nuevoEstado, 
      'progreso': nuevoEstado, 
      'timestampActualizacion': ServerValue.timestamp,
    });
  }

  // Calificar servicio;
  Future<void> calificarServicio(
    String solicitudId, 
    String profesionalId, 
    double calificacion
  ) async {
    // Actualizar la solicitud con la calificación;
    await _db.child('solicitudes/$solicitudId').update({
      'calificacion': calificacion,
      'estado': 'cerrado', 
      'timestampCalificacion': ServerValue.timestamp,
    });

    // Actualizar la calificación promedio del profesional;
    await _actualizarCalificacionProfesional(profesionalId, calificacion);
  }

  // Actualizar calificación del profesional;
  Future<void> _actualizarCalificacionProfesional(
    String profesionalId, 
    double nuevaCalificacion
  ) async {
    final userRef = _db.child('usuarios/$profesionalId');
    
    // Obtener datos actuales del profesional;
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final double calificacionActual = (data['calificacion_promedio'] ?? 5.0).toDouble();
      final int cantidadResenas = data['cantidad_resenas'] ?? 0;

      // Calcular nueva calificación promedio;
      final double nuevaCalificacionPromedio = 
          (calificacionActual * cantidadResenas + nuevaCalificacion) / 
          (cantidadResenas + 1);

      // Actualizar en la base de datos;
      await userRef.update({
        'calificacion_promedio': nuevaCalificacionPromedio,
        'cantidad_resenas': cantidadResenas + 1,
      });
    }
  }

  // Finalizar servicio;
  Future<void> finalizarServicio(String solicitudId, double precioFinal) async {
    await _db.child('solicitudes/$solicitudId')
      .update({
        'estado': 'finalizado',
        'precioFinal': precioFinal,
        'timestampFinalizacion': ServerValue.timestamp,
      });
  }

  // Obtener historial del profesional;
  Stream<DatabaseEvent> streamHistorialProfesional(String profesionalId) {
    return _db.child('solicitudes')
      .orderByChild('profesionalId')
      .equalTo(profesionalId)
      .onValue;
  }

  Query get querySolicitudesPendientes => 
      _db.child('solicitudes').orderByChild('estado').equalTo('pendiente');

  Stream<DatabaseEvent> streamSolicitud(String solicitudId) =>
      _db.child('solicitudes/$solicitudId').onValue;

  Future<void> aceptarSolicitud(String solicitudId, String nombreProfesional) async {
    final user = FirebaseAuth.instance.currentUser;
    await _db.child('solicitudes/$solicitudId').update({
      'estado': 'aceptado',
      'profesionalId': user?.uid,
      'profesionalNombre': nombreProfesional,
    });
  }

  Future<void> cancelarSolicitud(String solicitudId) async {
    await _db.child('solicitudes/$solicitudId').update({
      'estado': 'cancelado',
    });
  }

  // Obtener datos de una solicitud;
  Future<Map<String, dynamic>?> obtenerSolicitud(String solicitudId) async {
    final snapshot = await _db.child('solicitudes/$solicitudId').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Verificar si servicio está finalizado;
  Future<bool> estaServicioFinalizado(String solicitudId) async {
    final snapshot = await _db.child('solicitudes/$solicitudId/estado').get();
    return snapshot.value == 'finalizado';
  }
}