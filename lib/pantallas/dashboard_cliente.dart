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

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color.fromARGB(255, 123, 196, 246)),
        ),
      );
    }

    final nombre = userData?['nombre'] ?? 'Usuario';
    final fotoUrl = userData?['fotoUrl'] ?? '';

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        elevation: 0,
        title: ClipOval(
        child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(4), 
        child: Image.asset(
      'assets/logo_limpexia2.png', 
      height: 35, 
      fit: BoxFit.contain,
       ),
      ),
     ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del usuario;
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: fotoUrl.isNotEmpty
                            ? NetworkImage(fotoUrl)
                            : const AssetImage('assets/cliente.jpg')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, $nombre!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColores.texto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Encuentra tu servicio ideal',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColores.textoClaro,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Barra de búsqueda;
                  TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios de limpieza...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color.fromARGB(255, 6, 78, 125)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de categorías;
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _categoriaBoton(Icons.home_rounded, 'Casas', const Color.fromARGB(255, 6, 78, 125)),
                      _categoriaBoton(Icons.directions_car_rounded, 'Carros',
                          const Color.fromARGB(255, 6, 78, 125)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Carrusel de promociones;
                  const Text(
                    'Promociones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColores.texto,
                    ),
                  ),
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

                  const SizedBox(height: 28),

                  // Servicios próximos;
                  const Text(
                    'Servicios próximos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColores.texto,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _servicioProximo(
                    titulo: 'Servicio de Baño para Mascotas',
                    descripcion:
                        'Disponible muy pronto - ¡Tu peludo merece lo mejor!',
                    imagen:
                        'https://st.depositphotos.com/2166177/56666/i/450/depositphotos_566660794-stock-photo-dog-taking-bath-home-bathing.jpg',
                  ),
                 
                  const SizedBox(height: 32),

                  // Copyright;
                  Center(
                    child: Text(
                      '© 2025 Limpexia. Todos los derechos reservados.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones flotantes laterales (derecha);
          Positioned(
            top: 20,
            right: 16,
            child: Column(
              children: [
                // Menú desplegable;
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(31, 0, 0, 0),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: Color.fromARGB(231, 255, 255, 255)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'perfil', child: Text('👤 Mi perfil')),
                      PopupMenuItem(
                          value: 'servicios', child: Text('🧾 Mis servicios')),
                      PopupMenuItem(
                          value: 'pagos', child: Text('💳 Pagos y facturas')),
                      PopupMenuItem(
                          value: 'ayuda', child: Text('🛟 Ayuda y soporte')),
                      PopupMenuItem(
                          value: 'configuración', child: Text('⚙️ Configuración')),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'cerrar', child: Text('🚪 Cerrar sesión')),
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Seleccionaste: $value')),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Botón de notificaciones;
                FloatingActionButton.small(
                  heroTag: 'notif',
                  backgroundColor: const Color.fromARGB(255, 248, 0, 0),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Centro de notificaciones')),
                    );
                  },
                  child: const Icon(Icons.notifications,
                      color: Color.fromARGB(255, 253, 253, 253)),
                ),

                const SizedBox(height: 12),

                // Botón de chat;
                FloatingActionButton.small(
                  heroTag: 'chat',
                  backgroundColor: AppColores.secundario,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrir chat')),
                    );
                  },
                  child: const Icon(Icons.chat, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para botón de categoría;
  Widget _categoriaBoton(IconData icono, String texto, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        if (texto == 'Casas') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServicioCasas()),
          );
        } else if (texto == 'Carros') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServicioAutos()),
          );
        }
      },
      icon: Icon(icono, color: Colors.white, size: 22),
      label: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
      ),
    );
  }

  // Widget para servicio próximo;
  Widget _servicioProximo({
    required String titulo,
    required String descripcion,
    required String imagen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagen,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColores.textoClaro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
