import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reserva_provider.dart';
import '../widgets/loading.dart';
import '../utilidades/colores.dart';
import '../utilidades/helpers.dart';
import 'login.dart';



class DashboardProfesional extends StatelessWidget {
  const DashboardProfesional({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
/*
class DashboardProfesional extends StatefulWidget {
  const DashboardProfesional({super.key});

  @override
  State<DashboardProfesional> createState() => _DashboardProfesionalState();
}

class _DashboardProfesionalState extends State<DashboardProfesional> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = context.read<AuthProvider>().usuario;
      if (usuario != null) {
        context.read<ReservaProvider>().cargarReservasProfesional(usuario.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final reservaProvider = context.watch<ReservaProvider>();
    final usuario = authProvider.usuario;

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: AppColores.secundario,
        elevation: 0,
        title: const Text(
          'Mis Reservas',
          style: TextStyle(color: AppColores.blanco),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColores.blanco),
            onPressed: () async {
              await authProvider.cerrarSesion();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColores.secundario,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${usuario?.nombre ?? "Usuario"}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColores.blanco,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  usuario?.profesion ?? 'Profesional',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColores.blanco,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: reservaProvider.cargando
                ? const LoadingWidget(mensaje: 'Cargando reservas...')
                : reservaProvider.reservas.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes reservas pendientes',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColores.textoClaro,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (usuario != null) {
                            await context
                                .read<ReservaProvider>()
                                .cargarReservasProfesional(usuario.id);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reservaProvider.reservas.length,
                          itemBuilder: (context, index) {
                            final reserva = reservaProvider.reservas[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Reserva #${reserva.id.substring(0, 8)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getColorEstado(
                                                    reserva.estado)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            reserva.estado.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  _getColorEstado(reserva.estado),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: AppColores.textoClaro,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          Helpers.formatearFecha(
                                              reserva.fechaReserva),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColores.textoClaro,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 16,
                                          color: AppColores.textoClaro,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          Helpers.formatearPrecio(reserva.precio),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColores.secundario,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (reserva.estado == 'pendiente') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await reservaProvider
                                                    .actualizarEstado(
                                                        reserva.id, 'confirmada');
                                                if (context.mounted &&
                                                    usuario != null) {
                                                  context
                                                      .read<ReservaProvider>()
                                                      .cargarReservasProfesional(
                                                          usuario.id);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColores.secundario,
                                              ),
                                              child: const Text('Confirmar'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                await reservaProvider
                                                    .actualizarEstado(
                                                        reserva.id, 'cancelada');
                                                if (context.mounted &&
                                                    usuario != null) {
                                                  context
                                                      .read<ReservaProvider>()
                                                      .cargarReservasProfesional(
                                                          usuario.id);
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColores.error,
                                              ),
                                              child: const Text('Rechazar'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'confirmada':
        return AppColores.secundario;
      case 'completada':
        return Colors.blue;
      case 'cancelada':
        return AppColores.error;
      default:
        return Colors.orange;
    }
  }
}

*/