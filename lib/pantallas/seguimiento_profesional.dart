import 'package:flutter/material.dart';
import 'package:limpexia_express_app/pantallas/pantalla_chat.dart';
import '../servicios/solicitud_service.dart';
import 'dart:async';

class SeguimientoProfesional extends StatefulWidget {
  final String solicitudId;
  final Map<String, dynamic> solicitudData;

  const SeguimientoProfesional({
    super.key,
    required this.solicitudId,
    required this.solicitudData,
  });

  @override
  State<SeguimientoProfesional> createState() => _SeguimientoProfesionalState();
}

class _SeguimientoProfesionalState extends State<SeguimientoProfesional> {
  final SolicitudService _solicitudService = SolicitudService();
  
  final List<String> _pasosCodigo = ['por_salir', 'en_camino', 'por_llegar', 'afuera'];
  final List<String> _pasosTexto = [
    'Estoy por salir',
    'Voy en camino',
    'Estoy por llegar',
    'Estoy afuera del domicilio'
  ];

  String _estadoActual = 'por_salir';
  StreamSubscription? _estadoSubscription;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.solicitudData['progreso'] ?? 'por_salir';
    _escucharCambiosEstado();
  }

  void _escucharCambiosEstado() {
    _estadoSubscription = _solicitudService.streamSolicitud(widget.solicitudId).listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        final nuevoEstado = data['progreso'] ?? 'por_salir';
        
        if (mounted && nuevoEstado != _estadoActual) {
          setState(() {
            _estadoActual = nuevoEstado;
          });
        }
      }
    });
  }

  void _avanzarPaso() async {
    int indexActual = _pasosCodigo.indexOf(_estadoActual);
    
    if (indexActual < _pasosCodigo.length - 1) {
      String siguientePaso = _pasosCodigo[indexActual + 1];
      await _solicitudService.actualizarProgreso(widget.solicitudId, siguientePaso);
    } 
  }

  void _finalizarTrabajo() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF064E7D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "¿Finalizar servicio?",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirma que has terminado la limpieza y recibido el pago.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              "Precio total: \$${widget.solicitudData['precioTotal']?.toStringAsFixed(2) ?? '0.00'} MXN",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              double precioTotal = (widget.solicitudData['precioTotal'] ?? 0).toDouble();
              
              await _solicitudService.finalizarServicio(widget.solicitudId, precioTotal);
              if (mounted) {
                Navigator.pop(context); 
                Navigator.pop(context); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Servicio completado con éxito!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Finalizar Servicio", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _estadoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int indexActual = _pasosCodigo.indexOf(_estadoActual);

    return Scaffold(
      backgroundColor: Color(0xFF064E7D),
      appBar: AppBar(
        title: const Text(
          "Servicio en Curso",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF064E7D),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Debes finalizar el servicio para salir.")),
          ),
        ),
      ),
      body: Column(
        children: [

          // --------------------------
          //   INFO DEL CLIENTE - UBER
          // --------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF064E7D),
              border: Border(
                bottom: BorderSide(color: Colors.white24),
              ),
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
                    child: Icon(Icons.person, color: Colors.black, size: 35),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.solicitudData['clienteNombre'] ?? "Cliente",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Limpieza solicitada",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Precio: \$${widget.solicitudData['precioTotal']?.toStringAsFixed(2) ?? '0.00'} MXN",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaChat(solicitudId: widget.solicitudId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
                )
              ],
            ),

            
          ),

          // --------------------------
          //      LÍNEA DE TIEMPO
          // --------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _pasosTexto.length,
              itemBuilder: (context, index) {
                bool isCompleted = index <= indexActual;
                bool isCurrent = index == indexActual;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.black)
                              : const Icon(Icons.circle, size: 10, color: Colors.black),
                        ),

                        if (index < _pasosTexto.length - 1)
                          Container(
                            width: 3,
                            height: 55,
                            color: isCompleted ? Colors.green : Colors.white24,
                          ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.white.withOpacity(0.15) : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent ? Colors.white : Colors.white30,
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          _pasosTexto[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --------------------------
          //      BOTÓN PRINCIPAL
          // --------------------------
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF064E7D),
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: indexActual < _pasosCodigo.length - 1
                ? ElevatedButton(
                    onPressed: _avanzarPaso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Siguiente paso: ${_pasosTexto[indexActual + 1]}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _finalizarTrabajo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "FINALIZAR SERVICIO",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
