import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utilidades/colores.dart';
import 'login.dart';

class DashboardProfesional extends StatefulWidget {
  const DashboardProfesional({super.key});

  @override
  State<DashboardProfesional> createState() => _DashboardProfesionalState();
}

class _DashboardProfesionalState extends State<DashboardProfesional> {
  double calificacionPromedio = 4.6;
  bool disponible = true;
  List<String> servicios = [];
  List<double> tarifas = [];

  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configurarServicios();
    });
  }

  void _configurarServicios() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profesion = authProvider.profesion ?? "";

    setState(() {
      if (profesion == "Limpieza de casas") {
        servicios = ["Limpieza profunda", "Lavar ropa", "Planchar"];
        tarifas = [200, 150, 180];
      } else if (profesion == "Lavado de autos") {
        servicios = ["Pulido", "Encerado", "Interior"];
        tarifas = [350, 300, 250];
      } else {
        servicios = [];
        tarifas = [];
      }
    });
  }

  void _mostrarNotificaciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 180,
        child: Center(
          child: Text("No tienes notificaciones nuevas",
              style: TextStyle(color: Colors.grey[700])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final nombreUsuario = authProvider.nombreUsuario ?? "Profesional";
    final profesion = authProvider.profesion ?? "Sin profesión asignada";
    final fotoUsuario = authProvider.fotoPerfilUrl ?? '';

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
                  icon: const Icon(Icons.notifications, color: Colors.white),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'perfil', child: Text('👤 Mi perfil')),
                    PopupMenuItem(
                        value: 'pagos', child: Text('💳 Pagos y facturas')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: 'cerrar', child: Text('🔴 Cerrar sesión')),
                  ],
                  onSelected: (value) async {
                    if (value == 'cerrar') {
                      await authProvider.cerrarSesion();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const PantallaLogin()),
                        );
                      }
                    } else if (value == 'perfil') {
                     
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PerfilProfesionalPage(
                              nombreSimulado: nombreUsuario,
                              fotoUrl: fotoUsuario,
                            ),
                          ),
                        );
                      }
                    } else if (value == 'pagos') {
                     
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PagosFacturasPage(),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$value seleccionado')),
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
          ? _paginaHome(nombreUsuario, profesion, fotoUsuario)
          : _paginaActual == 1
              ? _paginaLimpiezas()
              : _paginaChat(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() => _paginaActual = index);

          if (index == 1) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Limpieza",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  "Actualmente no tienes ningún servicio solicitado.",
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_laundry_service), label: 'Limpiezas'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }

  Widget _paginaHome(String nombre, String profesion, String foto) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: foto.isNotEmpty
                      ? NetworkImage(foto)
                      : const AssetImage('assets/icono_usuario.jpg')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hola, $nombre 👋",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text(profesion,
                        style: const TextStyle(fontSize: 14, color: Colors.black)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _paginaLimpiezas(),
          ],
        ),
      ),
    );
  }

  Widget _paginaLimpiezas() {
    final List<List<Color>> coloresTarifas = [
     [Colors.orangeAccent.shade100, Colors.orangeAccent.shade200], 
     [Colors.deepOrange.shade400, Colors.deepOrange.shade700],    
     [Colors.redAccent.shade400, Colors.red.shade700],             
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Servicios ofrecidos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (servicios.isEmpty)
          const Text("No hay servicios configurados.",
              style: TextStyle(color: Colors.grey)),
        if (servicios.isNotEmpty)
          Center(
            child: Wrap(
              spacing: 14,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: servicios.map((servicio) {
                final bool esAuto =
                    ["Pulido", "Encerado", "Interior"].contains(servicio);
                final icono = esAuto
                    ? Icons.directions_car
                    : Icons.cleaning_services_rounded;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: esAuto
                          ? [
                              const Color.fromARGB(255, 6, 78, 125),
                              const Color.fromARGB(255, 12, 110, 190)
                            ]
                          : [AppColores.secundario, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(2, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icono, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(servicio,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 28),
        const Text(
          "Mis tarifas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
  
        if (tarifas.isNotEmpty)
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: tarifas.asMap().entries.map((entry) {
              int index = entry.key;
              double tarifa = entry.value;
              final colores = coloresTarifas[index % coloresTarifas.length];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colores,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 4))
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {},
                  child: Text(
                    "\$${tarifa.toStringAsFixed(0)} MXN",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 32),
        const Text(
          "Calificaciones y Opiniones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 48),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < calificacionPromedio.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 26,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  "${calificacionPromedio.toStringAsFixed(1)} / 5.0",
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text("Basado en opiniones de clientes",
                    style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "Disponibilidad",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.white, 
            ),
        ),
        const SizedBox(height: 12),
        
        Center(
          child: ElevatedButton.icon(
          onPressed: () => setState(() => disponible = !disponible),
            icon: Icon(
               disponible ? Icons.check_circle : Icons.cancel,
               color: Colors.white,
            ),
            label: Text(
            disponible ? "Disponible" : "No disponible",
            style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            ),
            ),
             style: ElevatedButton.styleFrom(
              backgroundColor: disponible ? Colors.green : Colors.red,
               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(12),
                 ),
                ),
              ),
            ),

        const SizedBox(height: 40),
        const Text(
          "Experiencia",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "3 años de experiencia profesional en servicios de limpieza",
          style: TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            "© 2025 Limpexia Express. Todos los derechos reservados.",
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _paginaChat() {
    return const Center(
      child: Text(
        "💬 Buzón de mensajes vacío",
        style: TextStyle(fontSize: 18, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class OlaAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height - 60, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(OlaAppBarClipper oldClipper) => false;
}


class PerfilProfesionalPage extends StatelessWidget {
  final String nombreSimulado;
  final String fotoUrl;

  const PerfilProfesionalPage({
    super.key,
    required this.nombreSimulado,
    required this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {

    final simulatedEmail = _construirCorreoSimulado(nombreSimulado);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        elevation: 0,
        leading: const BackButton(color: Color.fromARGB(255, 255, 255, 255)),
        title: const Text('Mi perfil', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 140,
                  height: 140,
                  color: Colors.grey[200],
                  child: fotoUrl.isNotEmpty
                      ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (context, e, s) {
                          return Image.asset('assets/icono_usuario.jpg', fit: BoxFit.cover);
                        })
                      : Image.asset('assets/icono_usuario.jpg', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                nombreSimulado,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                simulatedEmail,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () async {
     
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaLogin()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _construirCorreoSimulado(String nombre) {
    try {
      final cleaned = nombre.toLowerCase().replaceAll(RegExp(r'\s+'), '.');
      final safe = cleaned.replaceAll(RegExp(r'[^a-z0-9\._\-]'), '');
      if (safe.isEmpty) return 'usuario@ejemplo.com';
      return '$safe@ejemplo.com';
    } catch (e) {
      return 'usuario@ejemplo.com';
    }
  }
}


class PagosFacturasPage extends StatelessWidget {
  const PagosFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        elevation: 0,
        leading: const BackButton(color: Color.fromARGB(255, 255, 255, 255)),
        title: const Text('Pagos y facturas', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No tienes pagos ni facturas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Cuando tengas movimientos aparecerán aquí.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

