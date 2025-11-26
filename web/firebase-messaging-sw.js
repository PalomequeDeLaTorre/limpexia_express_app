// web/firebase-messaging-sw.js

importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB9Q5FHGP6GzASXeF_AtwsqbJoK54JKogk",
  authDomain: "limpexia-1c584.firebaseapp.com",
  databaseURL: "https://limpexia-1c584-default-rtdb.firebaseio.com",
  projectId: "limpexia-1c584",
  storageBucket: "limpexia-1c584.firebasestorage.app",
  messagingSenderId: "460133570608",
  appId: "1:460133570608:web:2f92352e4cff3e4b5035f5",
  measurementId: "G-YRX91NKXPT"
});

// Inicializamos el servicio de mensajería en segundo plano
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Mensaje en segundo plano:', payload);
  // Aquí puedes personalizar cómo se ve la notificación
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Icono de la app
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});