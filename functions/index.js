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

    // 3. Crear payload
    const payload = {
      notification: {
        title: titulo,
        body: cuerpo,
        sound: "default",
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        // En v2, los parámetros de la ruta están en event.params
        solicitudId: event.params.solicitudId, 
        ruta: "dashboard_profesional"
      },
    };

    // 4. Enviar
    return admin.messaging().sendToTopic(tema, payload)
        .then((response) => {
          console.log("Notificación enviada:", response);
        })
        .catch((error) => {
          console.log("Error:", error);
        });
  }
);