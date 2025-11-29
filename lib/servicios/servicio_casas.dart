import 'package:limpexia_express_app/pantallas/seguimiento_cliente.dart';

import '../pantallas/dashboard_cliente.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../utilidades/colores.dart';
import '../../servicios/solicitud_service.dart';

class ServicioCasas extends StatefulWidget {
  const ServicioCasas({super.key});

  @override
  State<ServicioCasas> createState() => _ServicioCasasState();
}

class _ServicioCasasState extends State<ServicioCasas> {
  late GoogleMapController _mapController;
  final SolicitudService _solicitudService = SolicitudService();
  final LatLng _ubicacionCliente = const LatLng(19.4326, -99.1332);
  final Set<Marker> _marcadores = {};
  final Set<String> _seleccionados = {};
  String? _solicitudIdActual;
  StreamSubscription? _solicitudSubscription;

  bool _buscando = false;
  int _paginaActual = 0;
  final List<String> _servicios = [
    'Limpieza profunda - \$600',
    'Lavar ropa - \$400',
    'Planchar - \$300',
  ];

  final List<String> _catalogoImgs = [
    'https://media.istockphoto.com/id/1440050060/es/foto/servicio-de-limpieza-retrato-y-limpiador-en-una-oficina-con-spray-botella-de-desinfectante.jpg?s=612x612&w=0&k=20&c=3bjsK-vm8jfmEpsxndZLePZSWg1QErxADQdTVsRk_Ng=',
    'https://media.istockphoto.com/id/1417833124/es/foto/limpiador-profesional-limpiando-una-mesa-en-una-casa.jpg?s=612x612&w=0&k=20&c=maYLxuJ0aCoAayq7s2Q7NR3gNcHX65mDCgDEuhPhU-E=',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnXW2ekLWOhDVQrEz9K-Fuakfpxi_--u5VeQ&s',
  ];

  @override
  void initState() {
    super.initState();
    _marcadores.add(
      Marker(
        markerId: const MarkerId('cliente'),
        position: _ubicacionCliente,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
      ),
    );
    _solicitudSubscription?.cancel();
  }

  void _toggleServicio(String s) {
    setState(() {
      if (_seleccionados.contains(s)) {
        _seleccionados.remove(s);
      } else {
        _seleccionados.add(s);
      }
    });
  }

  // === CAMBIO 1: Función para calcular precio total ===
  double _calcularPrecioTotal() {
    double total = 0.0;
    
    for (String servicio in _seleccionados) {
      // Extraer el precio del string del servicio
      RegExp regex = RegExp(r'\$(\d+)');
      Match? match = regex.firstMatch(servicio);
      if (match != null) {
        total += double.parse(match.group(1)!);
      }
    }
    
    return total;
  }

  void _buscarProfesional() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un servicio')),
      );
      return;
    }

    setState(() => _buscando = true);

    try {
      // === CAMBIO 2: Calcular precio total antes de enviar ===
      double precioTotal = _calcularPrecioTotal();
      
      String nuevoId = await _solicitudService.crearSolicitud(
        tipoServicio: 'Casa',
        opcionesSeleccionadas: _seleccionados.toList(),
        precioTotal: precioTotal, // === CAMBIO 3: Enviar precio total ===
      );

      setState(() {
        _solicitudIdActual = nuevoId;
      });

      _escucharCambiosSolicitud(nuevoId);
    } catch (e) {
      setState(() => _buscando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _escucharCambiosSolicitud(String solicitudId) {
    _solicitudSubscription?.cancel();

    _solicitudSubscription = _solicitudService.streamSolicitud(solicitudId).listen((
      event,
    ) {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map;
      final estado = data['estado'];

      if (estado == 'aceptado') {
        _solicitudSubscription?.cancel();

        if (mounted) {
          setState(() => _buscando = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeguimientoCliente(
                solicitudId: solicitudId, 
              ),
            ),
          );
        }
      }
    });
  }

  // Función para cancelar la espera manualmnete
  void _cancelarBusqueda() async {
    if (_solicitudIdActual != null) {
      await _solicitudService.cancelarSolicitud(_solicitudIdActual!);

      _solicitudSubscription?.cancel();
    }

    setState(() {
      _buscando = false;
      _solicitudIdActual = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Búsqueda Cancelada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        title: Text(
          _paginaActual == 0 ? 'Limpieza para Casas' : 'Chat con Profesional',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_paginaActual == 1) {
              setState(() {
                _paginaActual = 0;
              });
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardCliente()),
              );
            }
          },
        ),
        centerTitle: true,
      ),
      body: _paginaActual == 0 ? _paginaServicio() : _paginaChat(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Servicio',
          ),
        ],
      ),
    );
  }

  Widget _paginaServicio() {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 240,
                    child: Image.asset(
                    'assets/prof-limpieza.png',
                      fit: BoxFit.cover,
                      ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Servicios Disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _servicios.map((s) {
                    final activo = _seleccionados.contains(s);
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          activo
                              ? Icons.check_circle
                              : Icons.cleaning_services_outlined,
                          color: activo
                              ? AppColores.secundario
                              : AppColores.texto,
                        ),
                        title: Text(
                          s,
                          style: TextStyle(
                            fontWeight: activo
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: activo
                                ? AppColores.secundario
                                : AppColores.texto,
                          ),
                        ),
                        trailing: Checkbox(
                          value: activo,
                          onChanged: (_) => _toggleServicio(s),
                          activeColor: AppColores.secundario,
                        ),
                        onTap: () => _toggleServicio(s),
                      ),
                    );
                  }).toList(),
                ),

                // === CAMBIO 4: Mostrar precio total ===
                if (_seleccionados.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total a pagar:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            '\$${_calcularPrecioTotal().toStringAsFixed(2)} MXN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _buscando ? null : _buscarProfesional,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Buscar Profesional',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Descubre Más',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _catalogoImgs.length,
                    itemBuilder: (context, i) {
                      final img = _catalogoImgs[i];
                      return Container(
                        width: 220,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(img),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),
                Center(
                  child: Text(
                    '© 2025 Limpexia. Todos los derechos reservados.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (_buscando)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Solicitud Enviada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Esperando a que un profesional acepte...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 50),

                  // Botón para cancelar la espera
                  TextButton.icon(
                    onPressed: _cancelarBusqueda,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      "Cancelar Búsqueda",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _paginaChat() {
    return const Center(
      child: Text(
        '💬 Buzón de mensajes vacío',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}