import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


// Servicio para manejar solicitudes
class SolicitudService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Crea nueva solicitud
  Future<String> crearSolicitud({
    required String tipoServicio,
    required List<String> opcionesSeleccionadas,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    DatabaseReference nuevaSolicitudRef = _dbRef.child('solicitudes').push();

    await nuevaSolicitudRef.set({
      'id': nuevaSolicitudRef.key,
      'clienteId': user.uid,
      'clienteNombre': user.displayName ?? "Cliente", 
      'tipo': tipoServicio,
      'opciones': opcionesSeleccionadas,
      'estado': 'pendiente', 
      'timestamp': ServerValue.timestamp,
      'profesionalId': "",
    });

    return nuevaSolicitudRef.key!;
  }

  // Cancelar solicitud
  Future<void> cancelarSolicitud(String solicitudId) async {
    await _dbRef.child('solicitudes/$solicitudId').remove();
  }

  //Escuchar una solicitud específica
  Stream<DatabaseEvent> streamSolicitud(String solicitudId) {
    return _dbRef.child('solicitudes/$solicitudId').onValue;
  }

  //Obtener flujo de todas las solicitudes pendientes
  Query get querySolicitudesPendientes {
    return _dbRef.child('solicitudes').orderByChild('estado').equalTo('pendiente');
  }

  // Aceptar una solicitud
  Future<void> aceptarSolicitud(String solicitudId, String nombreProfesional) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _dbRef.child('solicitudes/$solicitudId').update({
      'estado': 'aceptado',
      'profesionalId': user.uid,
      'profesionalNombre': nombreProfesional,
    });
  }

  // Actualiza el progreso del servicio Los 4 pasos
  Future<void> actualizarProgreso(String solicitudId, String nuevoEstado) async {
    await _dbRef.child('solicitudes/$solicitudId').update({
      'progreso': nuevoEstado,
    });
  }

  // Finaliza el servicio
  Future<void> finalizarServicio(String solicitudId, double montoFinal) async {
    await _dbRef.child('solicitudes/$solicitudId').update({
      'estado': 'finalizado',
      'progreso': 'completado',
      'montoFinal': montoFinal, // Para el historial de pagos
    });
  }

  Future<void> calificarServicio(String solicitudId, String profesionalId, double estrellas) async {
    // Guardar la calificación en la Solicitud
    await _dbRef.child('solicitudes').child(solicitudId).update({
      'calificacion': estrellas,
      'estado': 'cerrado', // Estado final
    });

    // Actualiza el promedio del profesional
    final profesionalRef = _dbRef.child('usuarios').child(profesionalId);
    
    await profesionalRef.runTransaction((Object? post) {
      if (post == null) {
        return Transaction.success(post);
      }
      
      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(post as Map);

      double promedioActual = (data['calificacion_promedio'] ?? 0.0).toDouble();
      int totalVotos = (data['cantidad_resenas'] ?? 0).toInt();

      double nuevoPromedio = ((promedioActual * totalVotos) + estrellas) / (totalVotos + 1);
      
      data['calificacion_promedio'] = nuevoPromedio;
      data['cantidad_resenas'] = totalVotos + 1;

      return Transaction.success(data);
    });
  }

  // Obtener historial de servicios del cliente
  Stream<DatabaseEvent> streamHistorialProfesional(String uidProfesional) {
    return _dbRef
        .child('solicitudes')
        .orderByChild('profesionalId')
        .equalTo(uidProfesional)
        .onValue;
  }
}