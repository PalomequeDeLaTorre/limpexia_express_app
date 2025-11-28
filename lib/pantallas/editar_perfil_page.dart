import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animations/animations.dart';

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

  // 📌 Seleccionar foto (sin recortar)
  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen == null) return;

    setState(() => nuevaFoto = File(imagen.path));
  }

  Future<String?> _subirFoto(File imagen) async {
    final uid = _auth.currentUser!.uid;
    final ref =
        FirebaseStorage.instance.ref().child("fotos_perfil/$uid.jpg");

    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  // 📌 Validación de teléfono
  bool _telefonoValido(String tel) {
    final regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(tel);
  }

  // 📌 Vista previa antes de guardar
  Future<bool?> _mostrarVistaPrevia(String nombre, String tel, String? foto) {
    return showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              Text("Teléfono: $tel"),
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
    final nombre = nombreCtrl.text.trim();
    final telefono = telefonoCtrl.text.trim();

    if (!_telefonoValido(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El teléfono debe tener 10 dígitos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vista previa antes de guardar
    final confirmar = await _mostrarVistaPrevia(
        nombre, telefono, nuevaFoto?.path);

    if (confirmar != true) return;

    setState(() => guardando = true);

    final uid = _auth.currentUser!.uid;
    String? urlFoto = widget.fotoActual;

    if (nuevaFoto != null) {
      urlFoto = await _subirFoto(nuevaFoto!);
    }

    await _db.ref("usuarios/$uid").update({
      "nombre": nombre,
      "telefono": telefono,
      "fotoPerfilUrl": urlFoto ?? "",
    });

    setState(() => guardando = false);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Perfil actualizado correctamente"),
        backgroundColor: Colors.green,
      ),
    );
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
                              scale: nuevaFoto != null ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: nuevaFoto != null
                                    ? FileImage(nuevaFoto!)
                                    : (widget.fotoActual.isNotEmpty
                                        ? NetworkImage(widget.fotoActual)
                                        : const AssetImage(
                                            'assets/icono_usuario.jpg'))
                                            as ImageProvider,
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

                    // CAMPO NOMBRE
                    TextField(
                      controller: nombreCtrl,
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

                    // CAMPO TELÉFONO
                    TextField(
                      controller: telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Teléfono",
                        prefixIcon: const Icon(Icons.phone),
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
