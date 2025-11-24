import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../servicios/solicitud_service.dart';
import '../servicios/usuario_service.dart';
import 'seguimiento_profesional.dart';

class PestanaSolicitudes extends StatefulWidget {
  const PestanaSolicitudes({super.key});

  @override
  State<PestanaSolicitudes> createState() => _PestanaSolicitudesState();
}

class _PestanaSolicitudesState extends State<PestanaSolicitudes> {
  final SolicitudService _solicitudService = SolicitudService();
  final UsuarioService _usuarioService = UsuarioService();

  final Set<String> _rechazados = {};

  @override
  Widget build(BuildContext context) {
    // verfiacar si el profesional está DISPONIBLE
    return StreamBuilder<DatabaseEvent>(
      stream: _usuarioService.streamUsuario,
      builder: (context, snapshotUser) {
        bool disponible = false;
        String nombreProfesional = "Profesional";

        if (snapshotUser.hasData && snapshotUser.data!.snapshot.value != null) {
          final data = snapshotUser.data!.snapshot.value as Map;
          disponible = data['disponible'] ?? false;
          nombreProfesional = data['nombre'] ?? "Profesional";
        }

        // SI NO ESTÁ DISPONIBLE
        if (!disponible) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Estás marcado como 'No disponible'",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // SI ESTÁ DISPONIBLE escucha las solicitudes
        return StreamBuilder<DatabaseEvent>(
          stream: _solicitudService.querySolicitudesPendientes.onValue,
          builder: (context, snapshotSolicitudes) {
            if (snapshotSolicitudes.hasError) {
              return const Center(child: Text("Error al cargar solicitudes"));
            }

            if (!snapshotSolicitudes.hasData ||
                snapshotSolicitudes.data!.snapshot.value == null) {
              return const Center(
                child: Text(
                  "No hay solicitudes pendientes en tu zona.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            // Convertir el JSON de Firebase a una Lista
            Map<dynamic, dynamic> data =
                snapshotSolicitudes.data!.snapshot.value as Map;
            List<Map<String, dynamic>> solicitudes = [];

            data.forEach((key, value) {
              // Filtrar los que hayamos rechazado localmente
              if (!_rechazados.contains(key)) {
                final solicitud = Map<String, dynamic>.from(value);
                solicitud['key'] = key;
                solicitudes.add(solicitud);
              }
            });

            if (solicitudes.isEmpty) {
              return const Center(child: Text("No hay solicitudes nuevas."));
            }

            // LISTA DE TARJETAS
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final sol = solicitudes[index];
                final isAuto = sol['tipo'] == 'Auto';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAuto
                              ? const Color(0xFF064E7D)
                              : Colors.blueAccent,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAuto ? Icons.directions_car : Icons.home,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Solicitud de ${sol['tipo']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cliente: ${sol['clienteNombre'] ?? 'Usuario'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text("Servicios solicitados:"),
                            Wrap(
                              spacing: 8,
                              children: (sol['opciones'] as List)
                                  .map(
                                    (e) => Chip(
                                      label: Text(
                                        e.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 20),

                            // BOTONES DE ACCIÓN
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _rechazados.add(sol['key']);
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: const Text("RECHAZAR"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {

                                      final navigator = Navigator.of(context);

                                      await _solicitudService.aceptarSolicitud(
                                        sol['key'],
                                        nombreProfesional,
                                      );

                              
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SeguimientoProfesional(
                                                solicitudId: sol['key'],
                                                solicitudData: sol,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("ACEPTAR"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
