import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/chat_service.dart';
import '../providers/auth_provider.dart';
import '../utilidades/colores.dart';
import '../utilidades/helpers.dart';

/*
class PantallaChat extends StatefulWidget {
  final String reservaId;
  final String nombreOtraParte;

  const PantallaChat({
    super.key,
    required this.reservaId,
    required this.nombreOtraParte,
  });

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final _chatService = ChatService();
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    if (_mensajeController.text.trim().isEmpty) return;

    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;

    await _chatService.enviarMensaje(
      reservaId: widget.reservaId,
      texto: _mensajeController.text.trim(),
      emisorId: usuario.id,
    );

    _mensajeController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: AppColores.primario,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColores.blanco),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColores.blanco,
              child: Text(
                Helpers.obtenerIniciales(widget.nombreOtraParte),
                style: const TextStyle(
                  color: AppColores.primario,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.nombreOtraParte,
              style: const TextStyle(color: AppColores.blanco),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Mensaje>>(
              stream: _chatService.obtenerMensajes(widget.reservaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColores.primario,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay mensajes',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColores.textoClaro,
                      ),
                    ),
                  );
                }

                final mensajes = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje = mensajes[index];
                    final esMio = mensaje.emisorId == usuario?.id;

                    return Align(
                      alignment: esMio
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: esMio
                              ? AppColores.primario
                              : AppColores.blanco,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mensaje.texto,
                              style: TextStyle(
                                fontSize: 15,
                                color: esMio
                                    ? AppColores.blanco
                                    : AppColores.texto,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatearFecha(mensaje.fecha),
                              style: TextStyle(
                                fontSize: 11,
                                color: esMio
                                    ? AppColores.blanco.withOpacity(0.7)
                                    : AppColores.textoClaro,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColores.blanco,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: AppColores.fondo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColores.primario,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: AppColores.blanco,
                    ),
                    onPressed: _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

*/