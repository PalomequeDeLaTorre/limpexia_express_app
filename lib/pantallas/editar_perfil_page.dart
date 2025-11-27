import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';



class EditarPerfilPage extends StatefulWidget {
  final String nombreActual;
  final String correo;
  final String fotoActual;

  const EditarPerfilPage({
    super.key,
    required this.nombreActual,
    required this.correo,
    required this.fotoActual,
  });

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;
  File? nuevaFoto;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    nombreCtrl.text = widget.nombreActual;
    _cargarTelefono();
  }

  Future<void> _cargarTelefono() async {
    final uid = _auth.currentUser!.uid;
    final snap = await _db.ref("usuarios/$uid/telefono").get();

    if (snap.exists) {
      telefonoCtrl.text = snap.value.toString();
    }
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() => nuevaFoto = File(imagen.path));
    }
  }

  Future<String?> _subirFoto(File imagen) async {
    final uid = _auth.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child("fotos_perfil")
        .child("$uid.jpg");

    await ref.putFile(imagen);

    return await ref.getDownloadURL();
  }

  Future<void> _guardarCambios() async {
    setState(() => guardando = true);

    final uid = _auth.currentUser!.uid;
    String? urlFoto = widget.fotoActual;

    // SI SUBE FOTO NUEVA
    if (nuevaFoto != null) {
      urlFoto = await _subirFoto(nuevaFoto!);
    }

    // GUARDAR EN RTDB
    await _db.ref("usuarios/$uid").update({
      "nombre": nombreCtrl.text.trim(),
      "telefono": telefonoCtrl.text.trim(),
      "fotoPerfilUrl": urlFoto ?? "",
    });

    setState(() => guardando = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        backgroundColor: const Color.fromARGB(255, 6, 78, 125),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO DE PERFIL
            GestureDetector(
              onTap: _seleccionarFoto,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: nuevaFoto != null
                    ? FileImage(nuevaFoto!)
                    : (widget.fotoActual.isNotEmpty
                        ? NetworkImage(widget.fotoActual)
                        : const AssetImage('assets/icono_usuario.jpg')
                            as ImageProvider),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tocar para cambiar foto",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // NOMBRE
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // TELÉFONO
            TextField(
              controller: telefonoCtrl,
              decoration: InputDecoration(
                labelText: "Teléfono",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),

            // BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color.fromARGB(255, 6, 78, 125),
                ),
                child: guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Guardar cambios",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
