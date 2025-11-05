import '../pantallas/dashboard_cliente.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utilidades/colores.dart';
import 'dart:async';

class ServicioAutos extends StatefulWidget {
  const ServicioAutos({super.key});

  @override
  State<ServicioAutos> createState() => _ServicioAutosState();
}

class _ServicioAutosState extends State<ServicioAutos> {
  late GoogleMapController _mapController;
  final LatLng _ubicacionCliente = const LatLng(19.4326, -99.1332);
  final Set<Marker> _marcadores = {};
  final Set<String> _seleccionados = {};
  bool _buscando = false;
  int _paginaActual = 0; 

  final List<String> _servicios = [
    'Pulido',
    'Encerado',
    'Limpieza interior',
  ];

  final List<String> _catalogoImgs = [
    'https://www.shutterstock.com/image-photo/woman-washing-her-car-selfservice-600nw-1861269733.jpg',
    'https://static.vecteezy.com/system/resources/previews/003/658/952/non_2x/professional-cleaning-and-car-wash-in-the-car-showroom-photo.jpg',
    'https://www.shutterstock.com/image-photo/man-worker-washing-cars-alloy-600nw-243440098.jpg',
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

  void _buscarProfesional() {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un servicio')),
      );
      return;
    }

    setState(() => _buscando = true);

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _buscando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay profesionales de limpieza disponibles en tu área.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        title: Text(
          _paginaActual == 0 ? 'Limpieza para Autos' : 'Chat con Profesional',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_paginaActual == 1) {
              setState(() => _paginaActual = 0);
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
        onTap: (index) => setState(() => _paginaActual = index),
        selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_car_wash), label: 'Servicio'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
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
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _ubicacionCliente,
                        zoom: 14,
                      ),
                      markers: _marcadores,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Servicios disponibles',
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
                          activo ? Icons.check_circle : Icons.local_car_wash_outlined,
                          color: activo ? AppColores.secundario : AppColores.texto,
                        ),
                        title: Text(
                          s,
                          style: TextStyle(
                            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                            color: activo ? AppColores.secundario : AppColores.texto,
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
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _buscando ? null : _buscarProfesional,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Buscar profesional',
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
                  'Descubre más',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColores.texto),
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
                              image: NetworkImage(img), fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
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
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (_buscando)
          Container(
            color: Colors.black45,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Buscando profesionales cerca de ti...',
                    style: TextStyle(color: Colors.white),
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
