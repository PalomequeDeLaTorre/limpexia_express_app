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
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
          Positioned(
            top: -58,
            left: 0,
            right: 0,
            child: Image.asset('assets/borde_arriba.png',
                height: 400, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/borde_abajo.png',
                height: 400, fit: BoxFit.cover),
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
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),

                    // Tipo de cuenta;
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _tipoCuentaOpcion('cliente', 'Cliente', 'assets/cliente.jpg'),
                        _tipoCuentaOpcion('profesional', 'Profesional', 'assets/profesional.jpg'),
                      ],
                    ),

                    const SizedBox(height: 24),
                    InputPersonalizado(
                      label: 'Nombre completo',
                      controller: _nombreController,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    InputPersonalizado(
                      label: 'Correo electrónico',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu correo';
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Correo inválido';
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
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu teléfono' : null,
                    ),
                    const SizedBox(height: 16),

                    // Profesión seleccionable;
                    if (_tipoUsuario == 'profesional') ...[
                      const Text(
                        'Profesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColores.texto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.work_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text("Selecciona tu profesión"),
                        items: const [
                          DropdownMenuItem(
                              value: 'Limpieza de casas',
                              child: Text('Limpieza de casas')),
                          DropdownMenuItem(
                              value: 'Lavado de autos',
                              child: Text('Lavado de autos')),
                        ],
                        onChanged: (value) {
                          _profesionController.text = value!;
                        },
                        validator: (value) {
                          if (_tipoUsuario == 'profesional' &&
                              (value == null || value.isEmpty)) {
                            return 'Selecciona una profesión';
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
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    BotonPersonalizado(
                      texto: 'Registrarse',
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

  Widget _tipoCuentaOpcion(String tipo, String texto, String asset) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoUsuario = tipo),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: _tipoUsuario == tipo
                  ? const Color(0xFF064E7D)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(asset, height: 100, fit: BoxFit.cover),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tipoUsuario == tipo
                      ? const Color(0xFF064E7D)
                      : Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Text(
                  texto,
                  style: TextStyle(
                    color: _tipoUsuario == tipo
                        ? Colors.white
                        : AppColores.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
