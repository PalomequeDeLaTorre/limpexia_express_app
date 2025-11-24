import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SolicitudService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. MODIFICADO: Ahora devuelve un Future<String> (el ID de la solicitud)
  Future<String> crearSolicitud({
    required String tipoServicio,
    required List<String> opcionesSeleccionadas,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    // Generamos la referencia
    DatabaseReference nuevaSolicitudRef = _dbRef.child('solicitudes').push();

    // Guardamos los datos
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

    // Devolvemos el ID generado (ej: "-Nxyz...")
    return nuevaSolicitudRef.key!;
  }

  // 2. NUEVO: Cancelar (Eliminar) solicitud
  Future<void> cancelarSolicitud(String solicitudId) async {
    await _dbRef.child('solicitudes/$solicitudId').remove();
  }

  // 3. NUEVO: Escuchar una solicitud específica
  Stream<DatabaseEvent> streamSolicitud(String solicitudId) {
    return _dbRef.child('solicitudes/$solicitudId').onValue;
  }

  //4. Obtener flujo de TODAS las solicitudes pendientes
  // Usamos una Query para filtrar solo las que tienen estado = 'pendiente'
  Query get querySolicitudesPendientes {
    return _dbRef.child('solicitudes').orderByChild('estado').equalTo('pendiente');
  }

  // 5. NUEVO: Aceptar una solicitud
  Future<void> aceptarSolicitud(String solicitudId, String nombreProfesional) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _dbRef.child('solicitudes/$solicitudId').update({
      'estado': 'aceptado', // Esto disparará la pantalla del cliente
      'profesionalId': user.uid,
      'profesionalNombre': nombreProfesional,
    });
  }

  // 6. NUEVO: Actualizar el progreso del servicio (Los 4 pasos)
  Future<void> actualizarProgreso(String solicitudId, String nuevoEstado) async {
    // Estados posibles: 'por_salir', 'en_camino', 'por_llegar', 'afuera', 'finalizado'
    await _dbRef.child('solicitudes/$solicitudId').update({
      'progreso': nuevoEstado,
    });
  }

  // 7. NUEVO: Finalizar el servicio
  Future<void> finalizarServicio(String solicitudId, double montoFinal) async {
    await _dbRef.child('solicitudes/$solicitudId').update({
      'estado': 'finalizado',
      'progreso': 'completado',
      'montoFinal': montoFinal, // Para el historial de pagos
    });
  }
}