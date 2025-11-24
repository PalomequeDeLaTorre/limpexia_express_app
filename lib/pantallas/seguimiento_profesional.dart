import 'package:flutter/material.dart';
import 'package:limpexia_express_app/pantallas/pantalla_chat.dart';
import '../servicios/solicitud_service.dart';

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

  String _estadoActual = 'por_salir'; // Estado inicial por defecto

  @override
  void initState() {
    super.initState();
    // Inicia escuchando el estado real por si se cierra la app y se vuelve a abrir
    _estadoActual = widget.solicitudData['progreso'] ?? 'por_salir';
  }

  // Función para avanzar al siguiente paso
  void _avanzarPaso() async {
    int indexActual = _pasosCodigo.indexOf(_estadoActual);
    
    // Si todavía quedan pasos
    if (indexActual < _pasosCodigo.length - 1) {
      String siguientePaso = _pasosCodigo[indexActual + 1];
      
      await _solicitudService.actualizarProgreso(widget.solicitudId, siguientePaso);
      
      setState(() {
        _estadoActual = siguientePaso;
      });
    } 
  }

  void _finalizarTrabajo() async {
    // Para confirmar y finalizar el servicio con posibilidad de obtener un monto para funtura funcionalidad
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Finalizar servicio?"),
        content: const Text("Confirma que has terminado la limpieza y recibido el pago."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              // Finalizamos en Firebase
              await _solicitudService.finalizarServicio(widget.solicitudId, 0.0);
              if (mounted) {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Regresa al Dashboard
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Servicio completado con éxito!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Finalizar Servicio", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int indexActual = _pasosCodigo.indexOf(_estadoActual);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Servicio en Curso"),
        backgroundColor: const Color(0xFF064E7D),
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
          // INFO DEL CLIENTE
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.solicitudData['clienteNombre'] ?? "Cliente",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text("Limpieza solicitada", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                // Botón de Chat
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaChat(solicitudId: widget.solicitudId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble, color: Color(0xFF064E7D), size: 30),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // LÍNEA DE TIEMPO 
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
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isCurrent 
                              ? Border.all(color: const Color(0xFF064E7D), width: 3) 
                              : null,
                          ),
                          child: isCompleted 
                            ? const Icon(Icons.check, size: 18, color: Colors.white) 
                            : null,
                        ),
                        if (index < _pasosTexto.length - 1)
                          Container(
                            width: 3,
                            height: 50,
                            color: index < indexActual ? Colors.green : Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _pasosTexto[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // BOTÓN DE ACCIÓN PRINCIPAL
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: indexActual < _pasosCodigo.length - 1
                ? ElevatedButton(
                    onPressed: _avanzarPaso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E7D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Siguiente paso: ${_pasosTexto[indexActual + 1]}",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _finalizarTrabajo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "FINALIZAR SERVICIO",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}