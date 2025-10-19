import 'package:flutter/material.dart';
import '../utilidades/colores.dart';

class LoadingWidget extends StatelessWidget {
  final String? mensaje;

  const LoadingWidget({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColores.primario,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColores.textoClaro,
              ),
            ),
          ],
        ],
      ),
    );
  }
}