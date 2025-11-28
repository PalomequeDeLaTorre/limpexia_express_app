import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../providers/auth_provider.dart';

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
  State<EditarPerfilProfesional> createState() =>
      _EditarPerfilProfesionalState();
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

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen == null) return;

    setState(() => _imagen = File(imagen.path));
  }

  Future<String?> _subirImagen(File imagen) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child("fotos_perfil")
          .child("$uid.jpg");

      await ref.putFile(imagen);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }

  // 🌟 Vista previa antes de guardar
  Future<bool?> _mostrarVistaPrevia(
      String nombre, String profesion, String? foto) {
    return showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(),
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Confirmar Cambios"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 45,

                backgroundImage: foto != null
                    ? FileImage(File(foto))
                    : NetworkImage(widget.fotoActual) as ImageProvider,


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
              child: const Text(
                 "Confirmar",
                  style: TextStyle(color: Colors.white), 
                  ),
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

    // Vista previa
    final confirmar = await _mostrarVistaPrevia(
        nombre, profesion, _imagen?.path);

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
      "fotoPerfilUrl": fotoUrl,
    };

    // Guardar en RTDB
    await FirebaseDatabase.instance.ref("usuarios/$uid").update(data);

    // Actualizar Provider
    if (mounted) {
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      authProvider.recargarUsuario();
    }

    setState(() => guardando = false);

    if (mounted) Navigator.pop(context);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Column(
                  children: [
                    // Foto con animación
                    GestureDetector(
                      onTap: _seleccionarFoto,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [

                            AnimatedScale(
  scale: _imagen != null ? 1.05 : 1.0,
  duration: const Duration(milliseconds: 300),
  child: Builder(
    builder: (context) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: _imagen != null
            ? FileImage(_imagen!)
            : (auth.fotoPerfilUrl != null && auth.fotoPerfilUrl!.isNotEmpty
                ? NetworkImage(auth.fotoPerfilUrl!)
                : const AssetImage('assets/icono_usuario.jpg')) as ImageProvider,
      );
    },
  ),
),

                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 6, 78, 125),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Text("Tocar para cambiar foto",
                        style: TextStyle(color: Colors.grey)),

                    const SizedBox(height: 30),

                    // Campo nombre
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: "Nombre",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dropdown de Profesión
                    DropdownButtonFormField<String>(
                    value: _profesionController.text.isNotEmpty
                    ? _profesionController.text
                    : null,
                   items: const [
                   DropdownMenuItem(
                   value: "Lavado de autos",
                   child: Text("Lavado de autos"),
                   ),
                   DropdownMenuItem(
                   value: "Lavado de casas",
                   child: Text("Lavado de casas"),
                    ),
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
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                   ),
                  ),
                  ),


                    const SizedBox(height: 35),

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: guardando ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              const Color.fromARGB(255, 6, 78, 125),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: guardando
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Guardar Cambios",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
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
