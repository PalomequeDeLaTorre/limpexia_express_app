import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reserva_provider.dart';
import '../widgets/tarjeta_servicio.dart';
import '../widgets/loading.dart';
import '../utilidades/colores.dart';
import '../utilidades/constantes.dart';
import 'detalle_servicio.dart';
import 'login.dart';


class DashboardCliente extends StatelessWidget {
  const DashboardCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/cliente.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        // Aquí va tu contenido encima del fondo
      ),
    );
  }
}

/*

class DashboardCliente extends StatefulWidget {
  const DashboardCliente({super.key});

  @override
  State<DashboardCliente> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente> {
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservaProvider>().cargarServicios();
    });
  }

  void _filtrarPorCategoria(String? categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });

    if (categoria == null) {
      context.read<ReservaProvider>().cargarServicios();
    } else {
      context.read<ReservaProvider>().cargarServiciosPorCategoria(categoria);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final reservaProvider = context.watch<ReservaProvider>();
    final usuario = authProvider.usuario;

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: AppColores.primario,
        elevation: 0,
        title: const Text(
          'Servicios Disponibles',
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
              color: AppColores.primario,
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
                const Text(
                  '¿Qué servicio necesitas hoy?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColores.blanco,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chipCategoria('Todos', _categoriaSeleccionada == null),
                ...Constantes.categoriasServicios.map(
                  (cat) => _chipCategoria(cat, _categoriaSeleccionada == cat),
                ),
              ],
            ),
          ),
          Expanded(
            child: reservaProvider.cargando
                ? const LoadingWidget(mensaje: 'Cargando servicios...')
                : reservaProvider.servicios.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay servicios disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColores.textoClaro,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => context
                            .read<ReservaProvider>()
                            .cargarServicios(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reservaProvider.servicios.length,
                          itemBuilder: (context, index) {
                            final servicio = reservaProvider.servicios[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TarjetaServicio(
                                servicio: servicio,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DetalleServicio(
                                        servicio: servicio,
                                      ),
                                    ),
                                  );
                                },
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

  Widget _chipCategoria(String categoria, bool seleccionado) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(categoria),
        selected: seleccionado,
        onSelected: (selected) {
          _filtrarPorCategoria(selected ? (categoria == 'Todos' ? null : categoria) : null);
        },
        backgroundColor: AppColores.blanco,
        selectedColor: AppColores.primario,
        labelStyle: TextStyle(
          color: seleccionado ? AppColores.blanco : AppColores.texto,
          ///hagafadfadafa
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}




*/