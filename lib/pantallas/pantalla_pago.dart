import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../modelos/servicio.dart';
import '../modelos/reserva.dart';
import '../providers/auth_provider.dart';
import '../servicios/pago_service.dart';
import '../widgets/boton.dart';
import '../widgets/input.dart';
import '../utilidades/colores.dart';
import '../utilidades/helpers.dart';
import 'dashboard_cliente.dart';

class PantallaPago extends StatelessWidget {
  const PantallaPago({super.key, required Servicio servicio});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
