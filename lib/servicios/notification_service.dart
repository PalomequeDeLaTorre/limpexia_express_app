import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // -------------------------
  //  Inicializa Notificaciones
  // -------------------------
  Future<void> initNotifications() async {
    // Permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso concedido por el usuario');

      // Token nuevo
      String? token = await _firebaseMessaging.getToken();
      print("Mi Token de Notificación: $token");

      // Guardar
      _guardarToken(token);

      // Actualización automática cuando cambia
      FirebaseMessaging.instance.onTokenRefresh.listen(_guardarToken);
    } else {
      print('Permiso denegado');
    }

    // Inicializar notificaciones locales
    _initLocalNotifications();

    // Recibir NOTIFICACIONES en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');

      _mostrarNotificacionLocal(
        message.notification?.title,
        message.notification?.body,
      );
    });

    // Cuando el usuario toca la notificación y abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("El usuario abrió la app desde una notificación");
    });
  }

  // ----------------------------------
  //  NOTIFICACIONES LOCALES (ANDROID)
  // ----------------------------------
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings ios = DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);

    await _local.initialize(settings);
  }

  void _mostrarNotificacionLocal(String? titulo, String? cuerpo) {
    if (titulo == null && cuerpo == null) return;

    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      cuerpo,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'limpexia_channel',
          'Notificaciones Limpexia',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // -------------------------
  //  Guarda Token en Firebase
  // -------------------------
  Future<void> _guardarToken(String? token) async {
    if (token == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _dbRef.child('usuarios').child(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  // -----------------------------------------------
  // MÉTODO PARA ENVIAR NOTIFICACIONES A OTROS USUARIOS
  // -----------------------------------------------
  Future<void> enviarNotificacionAUsuario({
    required String userIdDestino,
    required String titulo,
    required String cuerpo,
  }) async {
    final snap =
        await _dbRef.child("usuarios/$userIdDestino/fcmToken").get();

    if (!snap.exists) {
      print("❌ Este usuario no tiene token");
      return;
    }

    final token = snap.value.toString();

    await FirebaseMessaging.instance.sendMessage(
      to: token,
      data: {"title": titulo, "body": cuerpo},
    );

    print("✔ Notificación enviada a $userIdDestino");
  }
}



/*

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

*/