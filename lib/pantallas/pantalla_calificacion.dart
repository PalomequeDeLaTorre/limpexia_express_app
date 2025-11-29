import 'package:flutter/material.dart';
import '../servicios/solicitud_service.dart';

class PantallaCalificacion extends StatefulWidget {
  final String solicitudId;
  final String profesionalId;

  const PantallaCalificacion({
    Key? key, 
    required this.solicitudId, 
    required this.profesionalId
  }) : super(key: key);

  @override
  State<PantallaCalificacion> createState() => _PantallaCalificacionState();
}

class _PantallaCalificacionState extends State<PantallaCalificacion> {
  final SolicitudService _service = SolicitudService();
  double _estrellas = 0; // Valor seleccionado

  void _enviarCalificacion() async {
    if (_estrellas == 0) return;

    await _service.calificarServicio(
      widget.solicitudId, 
      widget.profesionalId, 
      _estrellas
    );

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "¡Servicio Finalizado!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "¿Qué tal estuvo el servicio de tu profesional?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _estrellas ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _estrellas = index + 1.0;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _estrellas > 0 ? _enviarCalificacion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF064E7D),  
                    foregroundColor: Colors.white, 
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text("ENVIAR CALIFICACIÓN"),
                ),
              ),

            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Omitir"),
            )
          ],
        ),
      ),
    );
  }
}