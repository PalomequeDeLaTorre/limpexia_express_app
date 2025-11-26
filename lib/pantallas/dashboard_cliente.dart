import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:limpexia_express_app/servicios/servicio_autos.dart';
import 'package:limpexia_express_app/servicios/servicio_casas.dart';
import '../utilidades/colores.dart';
import 'login.dart';
import 'seguimiento_cliente.dart';
import 'pantalla_calificacion.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';


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
  StreamSubscription? _serviciosSubscription;

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
    _serviciosSubscription?.cancel();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).recargarUsuario();
    });
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

  void _cargarServiciosUsuario() async {
    if (mounted) setState(() => cargandoServicios = true);

    final user = _auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String keyLocal = 'servicios_cache_${user.uid}'; 
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    bool hayInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hayInternet) {
      _serviciosSubscription?.cancel();

      _serviciosSubscription = _db
          .ref('solicitudes')
          .orderByChild('clienteId')
          .equalTo(user.uid)
          .onValue
          .listen((event) {
        
        final List<Map<String, dynamic>> listaTemporal = [];

        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          
          data.forEach((key, value) {
            final servicio = Map<String, dynamic>.from(value);
            servicio['id'] = key;
            listaTemporal.add(servicio);
          });

          // Ordenar: Más recientes primero
          listaTemporal.sort((a, b) {
            var timeA = a['timestamp'] ?? 0;
            var timeB = b['timestamp'] ?? 0;
            return timeB.compareTo(timeA);
          });

          // --- AQUÍ ESTÁ EL TRUCO PWA ---
          // Guardamos esta lista fresca en el dispositivo para el futuro
          try {
            String jsonData = jsonEncode(listaTemporal);
            prefs.setString(keyLocal, jsonData);
          } catch (e) {
            print("Error guardando caché: $e");
          }
          // -----------------------------
        }

        if (mounted) {
          setState(() {
            serviciosSolicitados = listaTemporal;
            cargandoServicios = false;
          });
        }
      }, onError: (error) {
        print("Error escuchando servicios: $error");
        if (mounted) setState(() => cargandoServicios = false);
      });

    } else {
      // Leer lo que guardamos antes
      print("Modo Offline: Intentando cargar caché local...");
      
      String? jsonGuardado = prefs.getString(keyLocal);

      if (jsonGuardado != null) {
        try {
          // Decodificar el JSON guardado
          List<dynamic> listaDecodificada = jsonDecode(jsonGuardado);
          
          // Convertir a la estructura de tu app
          List<Map<String, dynamic>> listaOffline = listaDecodificada
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          if (mounted) {
            setState(() {
              serviciosSolicitados = listaOffline;
              cargandoServicios = false;
            });

            // Avisar al usuario que está viendo datos guardados
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sin internet. Mostrando historial guardado."),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          print("Error leyendo caché: $e");
          if (mounted) setState(() => cargandoServicios = false);
        }
      } else {
        // No hay internet y no hay nada guardado (primera vez que entra)
        if (mounted) setState(() => cargandoServicios = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No hay conexión a internet.")),
          );
        }
      }
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

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaPerfil(
                              nombre: nombre,
                              fotoUrl: fotoUrl,
                              correo:
                                  _auth.currentUser?.email ?? 'no disponible',
                            ),
                          ),
                        );
                      }
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
          : _paginaMisServicios(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
            // Recarga si vas a la pestaña 1
            if (index == 1) _cargarServiciosUsuario(); 
          });
        },
        selectedItemColor: const Color.fromARGB(255, 6, 78, 125),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), 
            label: 'Mis servicios'
          ),
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
              textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginaMisServicios() {
    final botonSolicitar = ElevatedButton.icon(
      onPressed: () => _mostrarMenuTiposServicio(context),
      icon: const Icon(Icons.add),
      label: const Text('Solicitar nuevo servicio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );

    // ESTADO DE CARGA
    if (cargandoServicios) {
      return const Center(
        child: CircularProgressIndicator(color: Color.fromARGB(255, 6, 78, 125)),
      );
    }

    // 2. ESTADO VACÍO
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
                const SizedBox(height: 20),
                botonSolicitar, 
              ],
            ),
          ),
        ),
      );
    }

    // ESTADO CON HISTORIAL
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: botonSolicitar,
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: serviciosSolicitados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final servicio = serviciosSolicitados[index];

                  //Extracción de datos
                  final tipo = servicio['tipo'] ?? servicio['categoria'] ?? 'Servicio';
                  final rawDate = servicio['fecha'] ?? servicio['created_at'] ?? servicio['timestamp'];
                  final String idSolicitud = servicio['id'];
                  final String? idProfesional = servicio['profesionalId'];
                  
                  // Estado base de la BD
                  String estadoBD = (servicio['estado'] ?? 'Pendiente').toString().toLowerCase();
                  
                  // Verifica si ya tiene calificación
                  bool yaCalifico = servicio['calificacion'] != null || estadoBD == 'cerrado';

                  String textoEstado;
                  Color colorEstado;
                  bool requiereAccion = false;

                  if (estadoBD == 'finalizado') {
                    if (yaCalifico) {
                      textoEstado = "FINALIZADO";
                      colorEstado = Colors.green;
                    } else {
                      textoEstado = "POR CALIFICAR";
                      colorEstado = Colors.orange;
                      requiereAccion = true;
                    }
                  } else if (estadoBD == 'cerrado') {
                    textoEstado = "FINALIZADO";
                    colorEstado = Colors.green;
                  } else if (estadoBD == 'cancelado') {
                    textoEstado = "CANCELADO";
                    colorEstado = Colors.red;
                  } else {
                    textoEstado = estadoBD.toUpperCase();
                    colorEstado = Colors.blue;
                    requiereAccion = true; // Permite ir al seguimiento
                  }

                  // Formateo de fecha
                  String fechaTexto = '';
                  if (rawDate is int) {
                    final dt = DateTime.fromMillisecondsSinceEpoch(rawDate);
                    fechaTexto = "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                  } else {
                    fechaTexto = rawDate.toString();
                  }

                  return GestureDetector(
                    onTap: () {
                      // Lógica de navegación al tocar la tarjeta entera
                      if (textoEstado == "POR CALIFICAR" && idProfesional != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaCalificacion(
                              solicitudId: idSolicitud,
                              profesionalId: idProfesional,
                            ),
                          ),
                        );
                      } else if (textoEstado == "FINALIZADO") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Servicio completado exitosamente."))
                        );
                      } else if (estadoBD != 'cancelado') {
                        // Ir a seguimiento
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeguimientoCliente(solicitudId: idSolicitud),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: requiereAccion 
                            ? Border.all(color: colorEstado.withOpacity(0.3), width: 1)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    tipo == 'Auto' ? Icons.directions_car : Icons.home,
                                    color: const Color.fromARGB(255, 6, 78, 125),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tipo.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      textoEstado,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorEstado,
                                      ),
                                    ),
                                    if (requiereAccion) ...[
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios, size: 10, color: colorEstado)
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (fechaTexto.isNotEmpty)
                            Text(
                              'Fecha: $fechaTexto',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          
                          if (textoEstado == "POR CALIFICAR")
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Tap para calificar el servicio ⭐",
                                style: TextStyle(color: Colors.orange[800], fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          
        ],
      ),
    );
  }

  // helper para dar color según estado
    Color _getColorEstado(String estado) {
      switch (estado.toLowerCase()) {
        case 'finalizado': return Colors.green;
        case 'cancelado': return Colors.red;
        case 'pendiente': return Colors.orange;
        case 'aceptado': return Colors.blue;
        default: return Colors.grey;
      }
  }

  // Función para mostrar el menú de tipos de servicio
  void _mostrarMenuTiposServicio(BuildContext context) async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Necesitas internet para solicitar un nuevo servicio."),
          backgroundColor: Colors.red,
        )
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecciona un tipo de servicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: Color.fromARGB(255, 6, 78, 125)),
              title: const Text('Casas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicioCasas()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car_rounded, color: Color.fromARGB(255, 6, 78, 125)),
              title: const Text('Autos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicioAutos()));
              },
            ),
          ],
        ),
      ),
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


class PantallaPerfil extends StatelessWidget {
  final String nombre;
  final String fotoUrl;
  final String correo;

  const PantallaPerfil({
    super.key,
    required this.nombre,
    required this.fotoUrl,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi perfil',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: fotoUrl.isNotEmpty
                      ? NetworkImage(fotoUrl)
                      : const AssetImage('assets/icono_usuario.jpg')
                          as ImageProvider,
                ),
                const SizedBox(height: 18),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  correo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                
                const SizedBox(height: 24),
                Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                  onPressed: () async {
                   await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                   Navigator.of(context).pushReplacement(
                   MaterialPageRoute(builder: (_) => const PantallaLogin()),
                   );
                  }
                  },
                 style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                   ),
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
                ),
               ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
