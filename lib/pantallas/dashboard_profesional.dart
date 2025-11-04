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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configurarServicios();
    });
  }

  // Método auxiliar para obtener el ImageProvider correcto;
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final nombreUsuario = authProvider.nombreUsuario ?? "Profesional";
    final profesion = authProvider.profesion ?? "Sin profesión asignada";
    final fotoUsuario = authProvider.fotoPerfilUrl ?? '';

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: ClipOval(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/logo_limpexia2.png',
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notificaciones")),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
            onSelected: (value) async {
              if (value == 'cerrar') {
                await authProvider.cerrarSesion();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaLogin()),
                  );
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'perfil', child: Text('👤 Mi perfil')),
              PopupMenuItem(value: 'servicios', child: Text('🧾 Mis servicios')),
              PopupMenuItem(value: 'pagos', child: Text('💳 Pagos y facturas')),
              PopupMenuItem(value: 'ayuda', child: Text('🛟 Ayuda y soporte')),
              PopupMenuItem(value: 'config', child: Text('⚙️ Configuración')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'cerrar', child: Text('🚪 Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Perfil;
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                       backgroundImage: fotoUsuario.isNotEmpty
                       ? NetworkImage(fotoUsuario)
                        : const AssetImage('assets/icono_usuario.jpg') as ImageProvider,
                       ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, $nombreUsuario 👋",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            profesion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Servicios;
                const Text(
                  "Servicios ofrecidos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (servicios.isEmpty)
                  const Text(
                    "No hay servicios configurados para esta profesión.",
                    style: TextStyle(color: Colors.black),
                  ),
                if (servicios.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: servicios.map((servicio) {
                      final bool esAuto = servicio == "Pulido" ||
                          servicio == "Encerado" ||
                          servicio == "Interior";
                      return Chip(
                        label: Text(servicio),
                        labelStyle: const TextStyle(color: Colors.white),
                        backgroundColor: esAuto
                            ? const Color.fromARGB(255, 6, 78, 125)
                            : AppColores.secundario,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 28),

                // Tarifas;
                const Text(
                  "Mis tarifas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                if (tarifas.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: tarifas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final precio = entry.value;
                      Color colorTarifa;
                      if (index == 0) {
                        colorTarifa = Colors.yellow.shade700;
                      } else if (index == 1) {
                        colorTarifa = Colors.orange;
                      } else {
                        colorTarifa = Colors.red;
                      }
                      return ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorTarifa,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: Text(
                          "\$${precio.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),

                // Calificaciones;
                const Text(
                  "Calificaciones y Opiniones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < calificacionPromedio.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${calificacionPromedio.toStringAsFixed(1)} / 5.0",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Promedio basado en opiniones de clientes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Disponibilidad;
                const Text(
                  "Disponibilidad",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        disponible = !disponible;
                      });
                    },
                    icon: Icon(
                      disponible ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                    ),
                    label: Text(
                      disponible ? "Disponible" : "No disponible",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          disponible ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Experiencia;
                const Text(
                  "Experiencia",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "3 años de experiencia profesional en servicios de limpieza",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: Text(
                    "© 2025 Limpexia Express. Todos los derechos reservados.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Botón flotante de chat;
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: AppColores.secundario,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Abrir chat")),
                );
              },
              child: const Icon(Icons.chat, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}