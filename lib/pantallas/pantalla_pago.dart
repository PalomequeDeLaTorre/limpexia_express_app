import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../modelos/servicio.dart';
import '../modelos/reserva.dart';
import '../providers/auth_provider.dart';
import '../providers/reserva_provider.dart';
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
/*
class PantallaPago extends StatefulWidget {
  final Servicio servicio;

  const PantallaPago({super.key, required this.servicio});

  @override
  State<PantallaPago> createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  final _formKey = GlobalKey<FormState>();
  final _tarjetaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _cvvController = TextEditingController();
  final _pagoService = PagoService();
  
  String _metodoPago = 'Tarjeta de Crédito';
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  bool _procesando = false;

  @override
  void dispose() {
    _tarjetaController.dispose();
    _nombreController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColores.primario,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColores.primario,
              ),
            ),
            child: child!,
          );
        },
      );

      if (hora != null) {
        setState(() {
          _fechaSeleccionada = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _procesando = true;
    });

    try {
      final exito = await _pagoService.procesarPago(
        monto: widget.servicio.precio,
        metodoPago: _metodoPago,
        tarjetaNumero: _tarjetaController.text.replaceAll(' ', ''),
      );

      if (exito) {
        final authProvider = context.read<AuthProvider>();
        final usuario = authProvider.usuario;

        if (usuario != null) {
          final reserva = Reserva(
            id: const Uuid().v4(),
            servicioId: widget.servicio.id,
            clienteId: usuario.id,
            profesionalId: widget.servicio.profesionalId,
            fechaReserva: _fechaSeleccionada,
            estado: 'pendiente',
            precio: widget.servicio.precio,
            fechaCreacion: DateTime.now(),
          );

          final reservaCreada = await context
              .read<ReservaProvider>()
              .crearReserva(reserva);

          if (mounted && reservaCreada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Reserva creada exitosamente!'),
                backgroundColor: AppColores.secundario,
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardCliente()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColores.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: AppColores.primario,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColores.blanco),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmar Reserva',
          style: TextStyle(color: AppColores.blanco),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColores.blanco,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.servicio.titulo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColores.texto,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.servicio.profesionalNombre,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColores.textoClaro,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a pagar:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColores.texto,
                                ),
                              ),
                              Text(
                                Helpers.formatearPrecio(widget.servicio.precio),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.secundario,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Fecha y hora del servicio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColores.texto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _seleccionarFecha,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColores.blanco,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColores.primario,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              Helpers.formatearFecha(_fechaSeleccionada),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColores.texto,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Método de pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColores.texto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._pagoService.obtenerMetodosPago().map(
                      (metodo) => RadioListTile<String>(
                        title: Text(metodo),
                        value: metodo,
                        groupValue: _metodoPago,
                        onChanged: (value) {
                          setState(() {
                            _metodoPago = value!;
                          });
                        },
                        activeColor: AppColores.primario,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Datos de pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColores.texto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputPersonalizado(
                      label: 'Número de tarjeta',
                      controller: _tarjetaController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.credit_card),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el número de tarjeta';
                        }
                        if (!_pagoService.validarTarjeta(value)) {
                          return 'Tarjeta inválida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputPersonalizado(
                      label: 'Nombre en la tarjeta',
                      controller: _nombreController,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InputPersonalizado(
                            label: 'CVV',
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'CVV requerido';
                              }
                              if (value.length < 3) {
                                return 'CVV inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
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
            child: BotonPersonalizado(
              texto: 'Confirmar y Pagar',
              onPressed: _procesarPago,
              cargando: _procesando,
            ),
          ),
        ],
      ),
    );
  }
}

*/