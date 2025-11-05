import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/boton.dart';
import '../widgets/input.dart';
import 'registro.dart';

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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = context.read<AuthProvider>();

    final bool exito = await authProvider.iniciarSesion(email, password);

    if (!mounted) return;

    if (exito) {
      final rol = authProvider.userRole;

      if (rol == 'profesional') {
        Navigator.of(context).pushReplacementNamed('dashboard_profesional');
      } else {
        Navigator.of(context).pushReplacementNamed('dashboard_cliente');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMensaje ?? 'Error desconocido al iniciar sesión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/borde_arriba.png',
              height: 400,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/borde_abajo.png',
              height: 400,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_limpexia.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Limpexia',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF064E7D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Encuentra profesionales de limpieza o ofrece tus servicios',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(162, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 48),
                      InputPersonalizado(
                        label: 'Gmail o Correo electrónico',
                        hint: 'ejemplo@correo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu Gmail o Correo electrónico';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Gmail o Correo electrónico inválido';
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
                        color: const Color(0xFF064E7D),
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
                        color: const Color(0xFF064E7D),
                      ),
 
                      const SizedBox(height: 20),
                      Row(
                      children: const [
                       Expanded(
                       child: Divider(
                       color: Colors.grey,
                       thickness: 1,
                       endIndent: 10,
                      ),
                     ),
                    Text(
                        'O',
                        style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        ),
                       ),
                      Expanded(
                        child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10,
                       ),
                       ),
                      ],
                     ),
                    const SizedBox(height: 12),
                      SizedBox(
                         width: double.infinity,
                         height: 50,
                         child: ElevatedButton.icon(
                         onPressed: () {
      
                         },
                        icon: Image.asset(
                        'assets/google_logo.jpg',
                        height: 24,
                        width: 24,
                        ),
                        label: const Text(
                        'Continuar con Google',
                        style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                         ),
                        ),
                       style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white,
                       side: const BorderSide(color: Colors.grey),
                       shape: const RoundedRectangleBorder(
                       borderRadius: BorderRadius.all(Radius.circular(8)),
                       ),
                       elevation: 1,
                       ),
                       ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}