import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servicios/chat_service.dart';

class PantallaChat extends StatefulWidget {
  final String solicitudId;

  const PantallaChat({Key? key, required this.solicitudId}) : super(key: key);

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Obtener el ID del usuario actual 
  final String miUid = FirebaseAuth.instance.currentUser!.uid;

  void _enviar() {
    _chatService.enviarMensaje(widget.solicitudId, _controller.text, miUid);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), _hacerScrollAlFinal);
  }

  void _hacerScrollAlFinal() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Muestra el email actual para verificar identidad
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chat del Servicio", style: TextStyle(fontSize: 16)),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? "Sin email",
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _chatService.streamMensajes(widget.solicitudId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("Sin mensajes aún."));
                }

                // Convertir la data de Firebase  a una Lista
                Map data = snapshot.data!.snapshot.value as Map;
                List mensajes = [];
                data.forEach((key, value) => mensajes.add(value));
                
                // Ordenar por timestamp
                mensajes.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

                WidgetsBinding.instance.addPostFrameCallback((_) => _hacerScrollAlFinal());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: mensajes.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final msg = mensajes[index];
                    
                    // oBTENER DATOS
                    final String remitenteId = msg['remitenteId'].toString();
                    final String miUid = FirebaseAuth.instance.currentUser!.uid;
                    final bool esMio = remitenteId == miUid;

                    return Align(
                      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          // Color Azul si es mio, Gris si es del otro
                          color: esMio ? Colors.blue : Colors.grey[300], 
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: esMio ? const Radius.circular(12) : const Radius.circular(0),
                            bottomRight: esMio ? const Radius.circular(0) : const Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          msg['texto'],
                          style: TextStyle(color: esMio ? Colors.white : Colors.black87), 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviar,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}