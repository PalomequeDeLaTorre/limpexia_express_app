import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:limpexia_express_app/servicios/servicio_autos.dart';
import 'package:limpexia_express_app/servicios/servicio_casas.dart';
import '../utilidades/colores.dart';
import 'login.dart';

class DashboardCliente extends StatefulWidget {
  const DashboardCliente({super.key});

  @override
  State<DashboardCliente> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;
  Map<dynamic, dynamic>? userData;
  bool cargando = true;

  List<Map<String, dynamic>> serviciosSolicitados = [];
  bool cargandoServicios = true;

  List<String> notificaciones = [];
  bool cargandoNotificaciones = true;

  int _paginaActual = 0;
  final TextEditingController _busquedaController = TextEditingController();

  final List<String> promociones = [
    'https://mx.habcdn.com/photos/business/medium/istock-9067775081-845441.jpg',
    'https://cdn.prod.website-files.com/629f82979557273ac33feb21/62a8fc884a38e17bb5ee0ddf_9-tipos-de-promociones-para-tu-punto-de-venta.jpg',
    'https://media.istockphoto.com/id/1433923860/es/foto/concepto-de-servicio-de-limpieza-durante-las-vacaciones-de-a%C3%B1o-nuevo.jpg?s=612x612&w=0&k=20&c=tjx-nNfECT42yAs_edeuKzLwZpx0s67m7fXU5rC1ik4=',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarServiciosUsuario();
    _cargarNotificaciones();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _db.ref('usuarios/${user.uid}').get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.value as Map<dynamic, dynamic>;
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> _cargarServiciosUsuario() async {
    setState(() {
      cargandoServicios = true;
      serviciosSolicitados = [];
    });
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _db.ref('solicitudes/${user.uid}').get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is Map) {
          value.forEach((key, val) {
            if (val is Map) {
              serviciosSolicitados.add(Map<String, dynamic>.from(val));
            } else {
              serviciosSolicitados.add({'id': key, 'data': val.toString()});
            }
          });
        } else if (value is List) {
          for (var item in value) {
            if (item is Map) {
              serviciosSolicitados.add(Map<String, dynamic>.from(item));
            } else {
              serviciosSolicitados.add({'data': item.toString()});
            }
          }
        }
      }
    } catch (e) {
      print('Error al cargar servicios: $e');
    } finally {
      setState(() {
        cargandoServicios = false;
      });
    }
  }

  Future<void> _cargarNotificaciones() async {
    setState(() {
      cargandoNotificaciones = true;
      notificaciones = [];
    });
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _db.ref('notificaciones/${user.uid}').get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is Map) {
          value.forEach((k, v) {
            if (v is Map && v['mensaje'] != null) {
              notificaciones.add(v['mensaje'].toString());
            } else {
              notificaciones.add(v.toString());
            }
          });
        } else if (value is List) {
          for (var item in value) {
            if (item is Map && item['mensaje'] != null) {
              notificaciones.add(item['mensaje'].toString());
            } else {
              notificaciones.add(item.toString());
            }
          }
        }
      }
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    } finally {
      setState(() {
        cargandoNotificaciones = false;
      });
    }
  }

  void _mostrarNotificaciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (cargandoNotificaciones) {
          return const SizedBox(
            height: 140,
            child: Center(
                child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 6, 78, 125))),
          );
        }
        if (notificaciones.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
                child: Text('No tienes notificaciones',
                    style: TextStyle(color: Colors.grey[700]))),
          );
        }
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notificaciones.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final texto = notificaciones[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: Text(texto),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
              color: Color.fromARGB(255, 123, 196, 246)),
        ),
      );
    }

    final nombre = userData?['nombre'] ?? 'Usuario';
    final fotoUrl = userData?['fotoUrl'] ?? '';

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Stack(
          children: [
            ClipPath(
              clipper: OlaAppBarClipper(),
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 6, 78, 125),
                      Color.fromARGB(255, 12, 110, 190),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: ClipOval(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/logo_limpexia2.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: _mostrarNotificaciones,
                  icon:
                      const Icon(Icons.notifications, color: Colors.white),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: 'perfil',  child: Text('👤 Ver perfil')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: 'cerrar', child: Text('🔴 Cerrar sesión')),
                  ],
                  onSelected: (value) async {
                    if (value == 'cerrar') {
                      await _auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const PantallaLogin()),
                        );
                      }
                    } else if (value == 'perfil') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Perfil del usuario')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: _paginaActual == 0
          ? _paginaHome(nombre, fotoUrl)
          : _paginaActual == 1
              ? _paginaMisServicios()
              : _paginaChat(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
            if (index == 1) _cargarServiciosUsuario();
          });
        },
        selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Mis servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }

  Widget _paginaHome(String nombre, String fotoUrl) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: fotoUrl.isNotEmpty
                      ? NetworkImage(fotoUrl)
                      : const AssetImage('assets/icono_usuario.jpg')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, $nombre!',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColores.texto)),
                    const SizedBox(height: 4),
                    const Text('Encuentra tu servicio ideal',
                        style: TextStyle(
                            fontSize: 14, color: AppColores.textoClaro)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar servicios de limpieza...',
                prefixIcon: const Icon(Icons.search,
                    color: Color.fromARGB(255, 6, 78, 125)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoriaBoton(Icons.home_rounded, 'Casas',
                    const Color.fromARGB(255, 6, 78, 125)),
                _categoriaBoton(Icons.directions_car_rounded, 'Carros',
                    const Color.fromARGB(255, 6, 78, 125)),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Promociones',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColores.texto)),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promociones.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                          image: NetworkImage(promociones[index]),
                          fit: BoxFit.cover),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            const Text('Servicios próximos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColores.texto)),
            const SizedBox(height: 12),
            _servicioProximo(
              titulo: 'Servicio de Baño para Mascotas',
              descripcion:
                  'Disponible muy pronto - ¡Tu peludo merece lo mejor!',
              imagen:
                  'https://st.depositphotos.com/2166177/56666/i/450/depositphotos_566660794-stock-photo-dog-taking-bath-home-bathing.jpg',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text('© 2025 Limpexia. Todos los derechos reservados.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginaMisServicios() {
    if (cargandoServicios) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color.fromARGB(255, 6, 78, 125)),
      );
    }

    if (serviciosSolicitados.isEmpty) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tienes servicios solicitados todavía.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20))),
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Selecciona un tipo de servicio',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ListTile(
                              leading: const Icon(Icons.home_rounded,
                                  color: Color.fromARGB(255, 6, 78, 125)),
                              title: const Text('Casas'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ServicioCasas()));
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                  Icons.directions_car_rounded,
                                  color:
                                      Color.fromARGB(255, 6, 78, 125)),
                              title: const Text('Autos'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ServicioAutos()));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Solicitar un servicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 6, 78, 125),
                         foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _cargarServiciosUsuario,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: serviciosSolicitados.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final servicio = serviciosSolicitados[index];
            final tipo = servicio['tipo'] ??
                servicio['categoria'] ??
                servicio['servicio'] ??
                'Servicio';
            final fecha = servicio['fecha'] ??
                servicio['fecha_solicitud'] ??
                servicio['created_at'] ??
                '';
            final estado = servicio['estado'] ?? 'Pendiente';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tipo.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  if (fecha.toString().isNotEmpty)
                    Text('Fecha: ${fecha.toString()}'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estado: $estado'),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ver detalles del servicio')));
                        },
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _paginaChat() {
    return const Center(
      child: Text('💬 Aquí irá la sección de Chat',
          style: TextStyle(fontSize: 18, color: Colors.black54)),
    );
  }

  Widget _categoriaBoton(IconData icono, String texto, Color color) {
    return GestureDetector(
      onTap: () {
        if (texto == 'Casas') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ServicioCasas()));
        } else if (texto == 'Carros') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ServicioAutos()));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icono, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(texto,
              style: const TextStyle(
                  color: AppColores.texto, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _servicioProximo(
      {required String titulo,
      required String descripcion,
      required String imagen}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(imagen, width: 60, fit: BoxFit.cover),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(descripcion),
      ),
    );
  }
}

/// ClipPath personalizado para AppBar ondulada
class OlaAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 4, size.height,
        size.width / 2, size.height - 30);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height - 60, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(OlaAppBarClipper oldClipper) => false;
}
