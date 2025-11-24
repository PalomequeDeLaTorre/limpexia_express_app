import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:limpexia_express_app/pantallas/pantalla_calificacion.dart';
import 'package:limpexia_express_app/pantallas/pantalla_chat.dart';
import '../servicios/solicitud_service.dart';

class SeguimientoCliente extends StatefulWidget {
  final String solicitudId;

  const SeguimientoCliente({Key? key, required this.solicitudId}) : super(key: key);

  @override
  State<SeguimientoCliente> createState() => _SeguimientoClienteState();
}

class _SeguimientoClienteState extends State<SeguimientoCliente> {
  final SolicitudService _solicitudService = SolicitudService();

  // Mapeo de los códigos de progreso a textos y orden para la UI
  final Map<String, int> _pasosOrden = {
    'por_salir': 1,
    'en_camino': 2,
    'por_llegar': 3,
    'afuera': 4,
    'completado': 5
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tu Servicio"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _solicitudService.streamSolicitud(widget.solicitudId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Obtener los datos en tiempo real
          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          String estado = data['estado'] ?? 'pendiente';
          String progresoActual = data['progreso'] ?? 'por_salir';

          if (estado == 'finalizado') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Evita navegar múltiples veces si ya estamos yendo
              if (ModalRoute.of(context)?.isCurrent ?? false) {
                
                // Obtener el ID del profesional de la data
                String profId = data['profesionalId'] ?? '';

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaCalificacion(
                      solicitudId: widget.solicitudId,
                      profesionalId: profId,
                    ),
                  ),
                );
              }
            });
          }

          return Column(
            children: [
              // Encabezado con datos del profesional
              _buildHeaderProfesional(),

              const Divider(),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "Estado del Servicio",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildStepItem("El profesional ha aceptado", "por_salir", progresoActual, isFirst: true),
                    _buildStepItem("Tu profesional va en camino", "en_camino", progresoActual),
                    _buildStepItem("Está por llegar a tu ubicación", "por_llegar", progresoActual),
                    _buildStepItem("¡Ha llegado! Servicio en curso", "afuera", progresoActual),
                    _buildStepItem("Servicio finalizado", "completado", progresoActual, isLast: true),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaChat(solicitudId: widget.solicitudId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text("Chat con el Profesional")
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String titulo, String pasoCodigo, String progresoActual, {bool isFirst = false, bool isLast = false}) {
    int ordenActual = _pasosOrden[progresoActual] ?? 0;
    int ordenEstePaso = _pasosOrden[pasoCodigo] ?? 99;
    
    bool isActive = ordenActual >= ordenEstePaso;
    bool isCurrent = ordenActual == ordenEstePaso;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 30,
                color: isActive ? Colors.green : Colors.grey[300],
              ),
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isActive ? Colors.green : Colors.grey,
              size: 30,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isActive && !isCurrent ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              titulo,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHeaderProfesional() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Profesional Asignado", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Llegará pronto", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}