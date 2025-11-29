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
      backgroundColor: const Color(0xFF064E7D),

      // ⭐ ÍCONO DE CHAT ARRIBA CON FONDO BLANCO
      appBar: AppBar(
        backgroundColor: const Color(0xFF064E7D),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Tu Servicio",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
           IconButton(
            padding: const EdgeInsets.only(right: 12),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaChat(solicitudId: widget.solicitudId),
                ),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),

      body: StreamBuilder<DatabaseEvent>(
        stream: _solicitudService.streamSolicitud(widget.solicitudId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          String estado = data['estado'] ?? 'pendiente';
          String progresoActual = data['progreso'] ?? 'por_salir';

          if (estado == 'finalizado') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ModalRoute.of(context)?.isCurrent ?? false) {
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
              _buildHeaderProfesional(),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "Estado del Servicio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------
  //          ESTILO PREMIUM
  // ---------------------------------------
  Widget _buildStepItem(
    String titulo,
    String pasoCodigo,
    String progresoActual,
    {bool isFirst = false, bool isLast = false}
  ) {
    int ordenActual = _pasosOrden[progresoActual] ?? 0;
    int ordenEstePaso = _pasosOrden[pasoCodigo] ?? 99;

    bool isActive = ordenActual >= ordenEstePaso;
    bool isCurrent = ordenActual == ordenEstePaso;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (!isFirst)
                Container(
                  height: 28,
                  width: 3,
                  color: isActive ? Colors.green : Colors.white.withOpacity(0.4),
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.green
                      : (isActive ? Colors.green : Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.check : Icons.circle,
                  color: Colors.black,
                  size: 14,
                ),
              ),
              if (!isLast)
                Container(
                  height: 28,
                  width: 3,
                  color: isActive ? Colors.green : Colors.white.withOpacity(0.4),
                ),
            ],
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? Colors.green : Colors.white.withOpacity(0.4),
                  width: 1.3,
                ),
              ),
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderProfesional() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF064E7D),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Profesional Asignado",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Llegará pronto",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
