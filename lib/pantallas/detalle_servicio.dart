import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/servicio.dart';
import '../widgets/boton.dart';
import '../utilidades/colores.dart';
import '../utilidades/helpers.dart';
import 'pantalla_pago.dart';

class DetalleServicio extends StatelessWidget {
  final Servicio servicio;

  const DetalleServicio({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: AppColores.primario,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColores.blanco),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Servicio',
          style: TextStyle(color: AppColores.blanco),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColores.primario,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColores.blanco.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            servicio.categoria,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColores.blanco,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          servicio.titulo,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColores.blanco,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (servicio.calificacion != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                servicio.calificacion!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColores.blanco,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColores.texto,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          servicio.descripcion,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColores.textoClaro,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Profesional',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColores.texto,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColores.blanco,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColores.primario,
                                child: Text(
                                  Helpers.obtenerIniciales(
                                      servicio.profesionalNombre),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.blanco,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      servicio.profesionalNombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColores.texto,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      servicio.categoria,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColores.textoClaro,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColores.secundario.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColores.secundario.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Precio del servicio',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColores.textoClaro,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Helpers.formatearPrecio(servicio.precio),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.secundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColores.blanco,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BotonPersonalizado(
              texto: 'Reservar Servicio',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaPago(servicio: servicio),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}