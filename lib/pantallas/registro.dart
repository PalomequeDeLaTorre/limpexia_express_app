import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/boton.dart';
import '../widgets/input.dart';
import '../utilidades/colores.dart';
import '../utilidades/constantes.dart';
import 'dashboard_cliente.dart';
import 'dashboard_profesional.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _profesionController = TextEditingController();
  
  String _tipoUsuario = 'cliente';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final exito = await authProvider.registrar(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telefono: _telefonoController.text.trim(),
        tipo: _tipoUsuario,
        profesion: _tipoUsuario == 'profesional'
            ? _profesionController.text.trim()
            : null,
      );

      if (mounted) {
        if (exito) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => _tipoUsuario == 'cliente'
                  ? const DashboardCliente()
                  : const DashboardProfesional(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrar'),
              backgroundColor: AppColores.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColores.texto),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa tus datos para comenzar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColores.textoClaro,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Tipo de cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cliente'),
                        value: 'cliente',
                        groupValue: _tipoUsuario,
                        onChanged: (value) {
                          setState(() {
                            _tipoUsuario = value!;
                          });
                        },
                        activeColor: AppColores.primario,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Profesional'),
                        value: 'profesional',
                        groupValue: _tipoUsuario,
                        onChanged: (value) {
                          setState(() {
                            _tipoUsuario = value!;
                          });
                        },
                        activeColor: AppColores.primario,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InputPersonalizado(
                  label: 'Nombre completo',
                  controller: _nombreController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputPersonalizado(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputPersonalizado(
                  label: 'Teléfono',
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_tipoUsuario == 'profesional') ...[
                  InputPersonalizado(
                    label: 'Profesión',
                    controller: _profesionController,
                    prefixIcon: const Icon(Icons.work_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu profesión';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                InputPersonalizado(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                BotonPersonalizado(
                  texto: 'Registrarse',
                  onPressed: _registrar,
                  cargando: authProvider.cargando,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}