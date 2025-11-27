import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  //Inicializa Notificaciones
  Future<void> initNotifications() async {
    // Pide permiso al usuario para recibir notificaciones
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso concedido por el usuario');
      
      // Obtiene el Token único del dispositivo
      String? token = await _firebaseMessaging.getToken();
      print("Mi Token de Notificación: $token");

      // Guarda este token en la base de datos del usuario actual
      _guardarToken(token);
    } else {
      print('Permiso denegado');
    }

    // Escucha mensajes cuando la app está abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');
    });
  }

  //Guarda Token en la Base de Datos
  Future<void> _guardarToken(String? token) async {
    if (token == null) return;
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Guarda el token dentro del nodo del usuario
      await _dbRef.child('usuarios').child(user.uid).update({
        'fcmToken': token, 
      });
    }
  }
}
