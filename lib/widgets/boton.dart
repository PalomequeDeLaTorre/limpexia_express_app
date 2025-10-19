import 'package:flutter/material.dart';
import '../utilidades/colores.dart';

class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final Color? color;
  final bool outline;

  const BotonPersonalizado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.color,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outline
          ? OutlinedButton(
              onPressed: cargando ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color ?? AppColores.primario),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      texto,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color ?? AppColores.primario,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: cargando ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? AppColores.primario,
                foregroundColor: AppColores.blanco,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColores.blanco,
                      ),
                    )
                  : Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
    );
  }
}