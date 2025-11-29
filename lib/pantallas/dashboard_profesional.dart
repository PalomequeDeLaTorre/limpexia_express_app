import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:limpexia_express_app/pantallas/editar_perfil_profesional.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utilidades/colores.dart';
import 'login.dart';
import '../servicios/usuario_service.dart';
import 'pestana_solicitudes.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import '../servicios/solicitud_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


  class DashboardProfesional extends StatefulWidget {
    const DashboardProfesional({super.key});

    @override
    State<DashboardProfesional> createState() => _DashboardProfesionalState();
  }

  class _DashboardProfesionalState extends State<DashboardProfesional> {
    final UsuarioService _usuarioService = UsuarioService();
    double calificacionPromedio = 4.6;
    bool disponible = true;
    List<String> servicios = [];
    List<double> tarifas = [];

    int _paginaActual = 0;

    double _calificacion = 5.0;
    int _totalResenas = 0;

    @override
    void initState() {
      super.initState();
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensaje recibido en primer plano: ${message.notification?.title}');
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${message.notification!.title}: ${message.notification!.body}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
              
            ),
          );
        }
      });

      _escucharCalificacion();
      _inicializarDatos();
    }

    Future<void> _inicializarDatos() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.recargarUsuario();
      if (!mounted) return;

      print("Datos de usuario cargados. Profesión actual: ${authProvider.profesion}");
      
      _configurarServicios();       
      _configurarNotificaciones(); 
    }

    void _configurarNotificaciones() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Permiso de notificaciones concedido');
        
        try {
          await messaging.subscribeToTopic("profesionales_casa");
          await messaging.subscribeToTopic("profesionales_auto");
          
          print("✅ MODO GLOBAL: Suscrito a alertas de CASAS y AUTOS");
        } catch (e) {
          print("Error al suscribirse a los temas: $e");
        }
      }
    }

    void _escucharCalificacion() {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      FirebaseDatabase.instance
          .ref('usuarios/$uid')
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map?;
          if (data != null && mounted) {
            setState(() {
              var calif = data['calificacion_promedio'];
              _calificacion = (calif is int) ? calif.toDouble() : (calif ?? 5.0);
              
              _totalResenas = data['cantidad_resenas'] ?? 0;
            });
          }
        }
      });
    }

    void _configurarServicios() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profesion = authProvider.profesion ?? "";

    print("🔄 Configurando servicios para profesión: $profesion");
    
    setState(() {
      if (profesion == "Lavado de autos") {
        servicios = ["Pulido", "Encerado", "Interior"];
        tarifas = [250, 300, 500];
      } else if (profesion == "Lavado de casas") {
        servicios = ["Limpieza profunda", "Lavar ropa", "Planchar"];
        tarifas = [300, 400, 600];
      } else {
        servicios = [];
        tarifas = [];
      }
      
      print("✅ Servicios configurados: $servicios");
      print("✅ Tarifas configuradas: $tarifas");
    });
  }

    void _mostrarNotificaciones() {
      showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: 180,
          child: Center(
            child: Text(
              "No tienes notificaciones nuevas",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
      );
    }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configurarServicios();
    });
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'perfil', child: Text('👤 Mi Perfil')),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'cerrar',
                        child: Text('🔴 Cerrar Sesión'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'cerrar') {
                        await authProvider.cerrarSesion();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PantallaLogin(),
                            ),
                          );
                        }
                      } else if (value == 'perfil') {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => const PerfilProfesionalPage(),
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
            ? const PestanaSolicitudes()
            : _paginaHistorial(),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _paginaActual,
          onTap: (index) {
            setState(() => _paginaActual = index);
          },
          
          selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Solicitudes',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: 'Pagos / Servicios'),
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
                        : const AssetImage('assets/icono_usuario.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola, $nombre 👋",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        profesion,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
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
            "Servicios Ofrecidos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (servicios.isEmpty)
            const Text(
              "No hay servicios configurados.",
              style: TextStyle(color: Colors.grey),
            ),
          if (servicios.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 14,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: servicios.map((servicio) {
                  final bool esAuto = [
                    "Pulido",
                    "Encerado",
                    "Interior",
                  ].contains(servicio);
                  final icono = esAuto
                      ? Icons.directions_car
                      : Icons.cleaning_services_rounded;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: esAuto
                            ? [
                                const Color.fromARGB(255, 6, 78, 125),
                                const Color.fromARGB(255, 12, 110, 190),
                              ]
                            : [AppColores.secundario, Colors.blueAccent],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icono, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          servicio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 28),
          const Text(
            "Mis Tarifas",
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
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "\$${tarifa.toStringAsFixed(0)} MXN",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                        i < _calificacion.round() 
                            ? Icons.star 
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 26,
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    "${_calificacion.toStringAsFixed(1)} / 5.0",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  Text(
                    _totalResenas == 0 
                        ? "Sin opiniones todavía"
                        : "Basado en $_totalResenas ${_totalResenas == 1 ? 'opinión' : 'opiniones'}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<DatabaseEvent>(
            stream: _usuarioService.streamUsuario, 
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return const Center(child: CircularProgressIndicator());
              }

              bool isDisponible = false;

              if (snapshot.data!.snapshot.value != null) {
                final data = snapshot.data!.snapshot.value as Map;
                isDisponible = data['disponible'] ?? false;
              }

              return Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _usuarioService.cambiarDisponibilidad(!isDisponible);
                  },
                  icon: Icon(
                    isDisponible ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                  ),
                  label: Text(
                    isDisponible ? "Disponible" : "No Disponible",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDisponible ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
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

    final SolicitudService _solicitudService = SolicitudService();

    Widget _paginaHistorial() {
      final String miUid = FirebaseAuth.instance.currentUser!.uid;

      return StreamBuilder<DatabaseEvent>(
        stream: _solicitudService.streamHistorialProfesional(miUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "Aún no has completado servicios.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          Map data = snapshot.data!.snapshot.value as Map;
          List<Map> listaServicios = [];
          
          data.forEach((key, value) {
            final servicio = Map<String, dynamic>.from(value);
            servicio['key'] = key; 
            listaServicios.add(servicio);
          });

          listaServicios.sort((a, b) {
            int timestampA = a['timestamp'] ?? 0;
            int timestampB = b['timestamp'] ?? 0;
            return timestampB.compareTo(timestampA); 
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listaServicios.length,
            itemBuilder: (context, index) {
              final item = listaServicios[index];
              final String estado = item['estado'] ?? 'desconocido';
              final String tipo = item['tipo'] ?? 'Servicio';
              final int timestamp = item['timestamp'] ?? 0;

              final double? precioTotal = item['precioTotal'] != null 
                  ? (item['precioTotal'] as num).toDouble() 
                  : null;
              final double? calificacion = item['calificacion'] != null 
                  ? (item['calificacion'] as num).toDouble() 
                  : null;
              
              final DateTime fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
              final String fechaTexto = "${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getColorEstado(estado),
                    child: Icon(_getIconTipo(tipo), color: Colors.white),
                  ),
                  title: Text(
                    tipo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(fechaTexto, style: TextStyle(color: Colors.grey[600])),
                      
                      if (precioTotal != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Precio: \$${precioTotal.toStringAsFixed(2)} MXN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getColorEstado(estado).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getColorEstado(estado).withOpacity(0.5))
                            ),
                            child: Text(
                              estado.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold,
                                color: _getColorEstado(estado)
                              ),
                            ),
                          ),
                          if (calificacion != null) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(
                              " $calificacion",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Helpers para colores e iconos;
    Color _getColorEstado(String estado) {
      switch (estado) {
        case 'finalizado': return Colors.green;
        case 'cerrado': return Colors.green[700]!; 
        case 'cancelado': return Colors.red;
        case 'aceptado': return Colors.blue;
        default: return Colors.orange;
      }
    }

    IconData _getIconTipo(String tipo) {
      if (tipo == 'Auto') return Icons.directions_car;
      return Icons.home; 
    }
  }

  class OlaAppBarClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
      Path path = Path();
      path.lineTo(0, size.height - 40);
      path.quadraticBezierTo(
        size.width / 4,
        size.height,
        size.width / 2,
        size.height - 30,
      );
      path.quadraticBezierTo(
        3 / 4 * size.width,
        size.height - 60,
        size.width,
        size.height - 20,
      );
      path.lineTo(size.width, 0);
      path.close();
      return path;
    }

    @override
    bool shouldReclip(OlaAppBarClipper oldClipper) => false;
  }

  class PerfilProfesionalPage extends StatelessWidget {
    const PerfilProfesionalPage({super.key});

    @override
    Widget build(BuildContext context) {
      final auth = Provider.of<AuthProvider>(context);

      final nombre = auth.nombreUsuario ?? "Usuario";
      final profesion = auth.profesion ?? "Sin profesión";
      final correo = FirebaseAuth.instance.currentUser?.email ?? "Sin correo";
      //final foto = auth.fotoPerfilUrl ?? "";
      final fotoUrl = Provider.of<AuthProvider>(context).fotoPerfilUrl ?? '';

      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Text(
            'Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF064E7D),
                Color(0xFF0A6AAE),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FOTO;
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          width: 140,
                          height: 140,
                          child: fotoUrl.isNotEmpty
                              ? Image.network(fotoUrl, fit: BoxFit.cover)
                              : Image.asset('assets/icono_usuario.jpg',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // DATOS REALES;
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 26, horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E7D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              correo,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profesion,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BOTÓN EDITAR PERFIL;
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarPerfilProfesional(
                                nombreActual: nombre,
                                profesionActual: profesion,
                                fotoActual: fotoUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Editar Perfil',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF064E7D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CERRAR SESIÓN;
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await auth.cerrarSesion();

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PantallaLogin()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
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
          title: const Text(
            'Pagos y facturas',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
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
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No tienes pagos ni facturas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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