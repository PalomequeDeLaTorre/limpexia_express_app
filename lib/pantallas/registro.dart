import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/boton.dart';
import '../widgets/input.dart';
import '../utilidades/colores.dart';


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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Obtener todos los datos del formulario
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final telefono = _telefonoController.text.trim();
    final rol = _tipoUsuario;
    final profesion =
        (rol == 'profesional') ? _profesionController.text.trim() : null;

    final authProvider = context.read<AuthProvider>();
    final bool exito = await authProvider.registrarUsuario(
      email,
      password,
      nombre,
      telefono,
      rol,
      profesion,
    );

    if (!mounted) return;

    if (exito) {
      if (rol == 'profesional') {
        Navigator.of(context).pushReplacementNamed('dashboard_profesional');
      } else {
        Navigator.of(context).pushReplacementNamed('dashboard_cliente');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.errorMensaje ?? 'Error desconocido al registrarse.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que el widget se redibuje si 'cargando' cambia
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 247, 250),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColores.texto),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Imagen superior
          Positioned(
            top: -58,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/borde_arriba.png',
              height: 400,
              fit: BoxFit.cover,
            ),
          ),

          // Imagen inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/borde_abajo.png',
              height: 400,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
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
                        color: Color(0xFF064E7D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa tus datos para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(162, 0, 0, 0),
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

                    // 🔹 NUEVA SECCIÓN con imágenes seleccionables
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _tipoUsuario = 'cliente';
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _tipoUsuario == 'cliente'
                                      ? const Color.fromARGB(255, 85, 201, 255)
                                      : Colors.grey.shade300,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  if (_tipoUsuario == 'cliente')
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 115, 234, 255).withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/cliente.jpg',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Cliente',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _tipoUsuario = 'profesional';
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _tipoUsuario == 'profesional'
                                      ? const Color.fromARGB(255, 85, 201, 255)
                                      : Colors.grey.shade300,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  if (_tipoUsuario == 'profesional')
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 115, 234, 255).withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/profesional.jpg',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Profesional',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
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
                      label: 'Gmail o Correo electrónico',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu Gmail o Correo electrónico';
                        }
                        // Corrección: Validación de email más robusta
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Gmail o Correo electrónico inválido';
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
                          // --- 2. VALIDACIÓN CORREGIDA ---
                          // Solo valida si el tipo de usuario es profesional
                          if (_tipoUsuario == 'profesional' &&
                              (value == null || value.isEmpty)) {
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
                      // --- 3. CONECTANDO EL BOTÓN ---
                      onPressed: _registrar,
                      cargando: authProvider.cargando,
                      color: const Color(0xFF064E7D),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
