import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/boton.dart';
import '../widgets/input.dart';
import '../utilidades/colores.dart';
import 'registro.dart';
import 'dashboard_cliente.dart';
import 'dashboard_profesional.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final exito = await authProvider.iniciarSesion(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (exito) {
          final usuario = authProvider.usuario;
          if (usuario != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => usuario.tipo == 'cliente'
                    ? const DashboardCliente()
                    : const DashboardProfesional(),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: AppColores.primario,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Servicios App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColores.texto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encuentra profesionales o ofrece tus servicios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColores.textoClaro,
                    ),
                  ),
                  const SizedBox(height: 48),
                  InputPersonalizado(
                    label: 'Email',
                    hint: 'ejemplo@correo.com',
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
                    label: 'Contraseña',
                    hint: '••••••••',
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
                        return 'Ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BotonPersonalizado(
                    texto: 'Iniciar Sesión',
                    onPressed: _iniciarSesion,
                    cargando: authProvider.cargando,
                  ),
                  const SizedBox(height: 16),
                  BotonPersonalizado(
                    texto: 'Crear Cuenta',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PantallaRegistro(),
                        ),
                      );
                    },
                    outline: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}