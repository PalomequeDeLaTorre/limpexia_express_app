/**
 * Importaciones modernas (v2)
 */
const { onValueCreated } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");

admin.initializeApp();

// Usamos onValueCreated en lugar de functions.database.ref
exports.enviarNotificacionServicio = onValueCreated(
  "/solicitudes/{solicitudId}",
  (event) => {
    // 1. En la versión v2, el 'snapshot' viene dentro de 'event.data'
    const snapshot = event.data;
    
    if (!snapshot.exists()) {
        return null;
    }

    const solicitud = snapshot.val();
    const tipoServicio = solicitud.tipo; 
    const nombreCliente = solicitud.clienteNombre || "Un cliente";

    console.log("Nueva solicitud detectada (v2):", tipoServicio);

    // 2. Definir mensaje
    let tema = "";
    let titulo = "";
    let cuerpo = "";

    if (tipoServicio === "Casa") {
      tema = "profesionales_casa";
      titulo = "🧹 Nueva solicitud de Casa";
      cuerpo = `${nombreCliente} necesita servicio de limpieza.`;
    } else if (tipoServicio === "Auto") {
      tema = "profesionales_auto";
      titulo = "🚗 Nueva solicitud de Auto";
      cuerpo = `${nombreCliente} necesita lavado de auto.`;
    } else {
      return null;
    }

    const message = {
      notification: {
        title: titulo,
        body: cuerpo,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        solicitudId: event.params.solicitudId,
        ruta: "dashboard_profesional"
      },
      topic: tema // <--- El tema se define aquí ahora
    };

    console.log(`Enviando mensaje al tema: ${tema}`);

    // Usamos .send() en lugar de .sendToTopic()
    return admin.messaging().send(message)
        .then((response) => {
          console.log("✅ ÉXITO: Notificación enviada. Message ID:", response);
        })
        .catch((error) => {
          console.log("❌ ERROR CRÍTICO al enviar FCM:", error);
        });
  }
);