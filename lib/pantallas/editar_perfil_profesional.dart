import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../providers/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EditarPerfilProfesional extends StatefulWidget {
  final String nombreActual;
  final String profesionActual;
  final String fotoActual;

  const EditarPerfilProfesional({
    super.key,
    required this.nombreActual,
    required this.profesionActual,
    required this.fotoActual,
  });

  @override
  State<EditarPerfilProfesional> createState() => _EditarPerfilProfesionalState();
}

class _EditarPerfilProfesionalState extends State<EditarPerfilProfesional> {
  late TextEditingController _nombreController;
  late TextEditingController _profesionController;

  File? _imagen;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreActual);
    _profesionController = TextEditingController(text: widget.profesionActual);
  }

  // Método para solicitar permisos;
  Future<bool> _solicitarPermisos() async {
    if (await Permission.photos.isGranted) {
      return true;
    }
    
    if (await Permission.storage.isGranted) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
    ].request();

    if (statuses[Permission.photos]?.isGranted == true || 
        statuses[Permission.storage]?.isGranted == true) {
      return true;
    }

    if (statuses[Permission.photos]?.isPermanentlyDenied == true ||
        statuses[Permission.storage]?.isPermanentlyDenied == true) {
      
      bool? abrirConfig = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permiso necesario"),
          content: const Text(
            "Para cambiar tu foto de perfil, necesitamos acceso a tu galería. "
            "Por favor, activa el permiso en configuración."
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("Ir a Configuración"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (abrirConfig == true) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  Future<void> _seleccionarFoto() async {
    print("🔍 Botón de seleccionar foto presionado");
    
    bool tienePermiso = await _solicitarPermisos();
    print("📋 Permiso concedido: $tienePermiso");
    
    if (!tienePermiso) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Se necesita permiso para acceder a la galería"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      print("📸 Imagen seleccionada: ${imagen?.path}");

      if (imagen == null) {
        print("❌ No se seleccionó ninguna imagen");
        return;
      }

      setState(() {
        _imagen = File(imagen.path);
        print("✅ Estado actualizado con nueva imagen");
      });
    } catch (e) {
      print("❌ Error al seleccionar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _subirImagen(File imagen) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child("fotos_perfil").child("$uid.jpg");

      await ref.putFile(imagen);
      final url = await ref.getDownloadURL();
      print("✅ Imagen subida: $url");
      return url;
    } catch (e) {
      print("❌ Error subiendo imagen: $e");
      return null;
    }
  }

  Future<bool?> _mostrarVistaPrevia(String nombre, String profesion, String? foto) {
    return showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Confirmar Cambios"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: foto != null
                    ? FileImage(File(foto))
                    : (widget.fotoActual.isNotEmpty
                        ? NetworkImage(widget.fotoActual)
                        : const AssetImage('assets/icono_usuario.jpg')) as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text("Nombre: $nombre"),
              Text("Profesión: $profesion"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 78, 125)),
              child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarCambios() async {
    final nombre = _nombreController.text.trim();
    final profesion = _profesionController.text.trim();

    final confirmar = await _mostrarVistaPrevia(nombre, profesion, _imagen?.path);

    if (confirmar != true) return;

    setState(() => guardando = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    String fotoUrl = widget.fotoActual;

    if (_imagen != null) {
      final nuevaUrl = await _subirImagen(_imagen!);
      if (nuevaUrl != null) fotoUrl = nuevaUrl;
    }

    final data = {
      "nombre": nombre,
      "profesion": profesion,
      "fotoUrl": fotoUrl,
    };

    await FirebaseDatabase.instance.ref("usuarios/$uid").update(data);

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.recargarUsuario();
    }

    setState(() => guardando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _cambiarContrasena() async {
  final TextEditingController actualCtrl = TextEditingController();
  final TextEditingController nuevaCtrl = TextEditingController();

  bool? resultado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cambiar Contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actualCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña actual",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nuevaCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 6, 78, 125),
            ),
            child: const Text("Cambiar", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );

  if (resultado != true) return;

  final actual = actualCtrl.text.trim();
  final nueva = nuevaCtrl.text.trim();

  if (actual.isEmpty || nueva.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Completa ambos campos"), backgroundColor: Colors.red),
    );
    return;
  }

  try {
    final user = FirebaseAuth.instance.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: actual,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(nueva);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada"), backgroundColor: Colors.green),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      String mensajeError;
      if (e.code == 'invalid-credential') {
        mensajeError = "No se pudo actualizar la contraseña porque la contraseña actual es incorrecta";
      } else if (e.code == 'weak-password') {
        mensajeError = "La nueva contraseña es demasiado débil";
      } else if (e.code == 'requires-recent-login') {
        mensajeError = "Por seguridad, debes iniciar sesión nuevamente";
      } else {
        mensajeError = "Error: ${e.message}";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
        centerTitle: true,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("👆 Tap detectado en la foto");
                        _seleccionarFoto();
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AnimatedScale(
                            scale: _imagen != null ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: _imagen != null
                                  ? FileImage(_imagen!)
                                  : (widget.fotoActual.isNotEmpty
                                      ? NetworkImage(widget.fotoActual)
                                      : const AssetImage('assets/icono_usuario.jpg')) as ImageProvider,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 6, 78, 125),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("Tocar para cambiar foto", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: "Nombre",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _profesionController.text.isNotEmpty
                          ? _profesionController.text
                          : null,
                      items: const [
                        DropdownMenuItem(value: "Lavado de autos", child: Text("Lavado de autos")),
                        DropdownMenuItem(value: "Lavado de casas", child: Text("Lavado de casas")),
                      ],
                      onChanged: (valor) {
                        setState(() {
                          _profesionController.text = valor!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Profesión",
                        prefixIcon: const Icon(Icons.work),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: guardando ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 6, 78, 125),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: guardando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Guardar Cambios",
                                style: TextStyle(fontSize: 17, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _cambiarContrasena,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text("Cambiar Contraseña"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color.fromARGB(255, 6, 78, 125),
                          side: const BorderSide(color: Color.fromARGB(255, 6, 78, 125)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}