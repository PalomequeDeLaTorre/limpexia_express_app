import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
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

  Future<void> _guardarCambios() async {
    setState(() => guardando = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    String fotoUrl = widget.fotoActual;

    if (_imagen != null) {
      final nuevaUrl = await _subirImagen(_imagen!);
      if (nuevaUrl != null) fotoUrl = nuevaUrl;
    }

    final data = {
      "nombre": _nombreController.text.trim(),
      "profesion": _profesionController.text.trim(),
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarFoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imagen != null
                    ? FileImage(_imagen!)
                    : (widget.fotoActual.isNotEmpty
                        ? NetworkImage(widget.fotoActual)
                        : const AssetImage("assets/icono_usuario.jpg"))
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profesionController,
              decoration: const InputDecoration(labelText: "Profesión"),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: guardando ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 78, 125),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar cambios", style: TextStyle(color: Colors.white)),
            )
            
          ],
        ),
      ),
    );
  }
}
