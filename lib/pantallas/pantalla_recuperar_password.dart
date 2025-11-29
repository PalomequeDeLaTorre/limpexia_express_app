import 'package:flutter/material.dart';
import 'package:limpexia_express_app/pantallas/login.dart';

class PantallaRecuperarPassword extends StatefulWidget {
  const PantallaRecuperarPassword({super.key});

  @override
  State<PantallaRecuperarPassword> createState() => _PantallaRecuperarPasswordState();
}

class _PantallaRecuperarPasswordState extends State<PantallaRecuperarPassword> {
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _nuevaPasswordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _codigoEnviado = false;
  bool _codigoVerificado = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _codigoGenerado;

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _nuevaPasswordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  String _generarCodigo() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  Future<void> _enviarCodigo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _mostrarError("Ingresa un correo electrónico válido");
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    final codigo = _generarCodigo();
    setState(() {
      _codigoGenerado = codigo;
      _codigoEnviado = true;
    });

    _mostrarExito("Código enviado a $email\nCódigo: $codigo");
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      _mostrarError("Ingresa el código de verificación");
      return;
    }

    if (codigo != _codigoGenerado) {
      _mostrarError("Código incorrecto");
      return;
    }

    setState(() {
      _codigoVerificado = true;
    });

    _mostrarExito("Código verificado correctamente");
  }

  Future<void> _cambiarPassword() async {
    final password = _nuevaPasswordController.text.trim();
    final confirmPassword = _confirmarPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _mostrarError("Completa todos los campos");
      return;
    }

    if (password.length < 6) {
      _mostrarError("La contraseña debe tener mínimo 6 caracteres");
      return;
    }

    if (password != confirmPassword) {
      _mostrarError("Las contraseñas no coinciden");
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    _mostrarExito("Contraseña actualizada con éxito");

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PantallaLogin(),
      ),
    );
  }

  void _cancelar() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PantallaLogin(),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar Contraseña"),
        backgroundColor: const Color(0xFF064E7D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF064E7D),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        _codigoVerificado 
                            ? "Nueva Contraseña"
                            : _codigoEnviado 
                                ? "Verificar Código"
                                : "Recuperar Contraseña",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        _codigoVerificado
                            ? "Ingresa tu nueva contraseña"
                            : _codigoEnviado
                                ? "Ingresa el código enviado a tu correo"
                                : "Ingresa tu correo para generar un código",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      if (!_codigoEnviado)
                        _buildEmailField(),

                      if (_codigoEnviado && !_codigoVerificado)
                        _buildCodeField(),

                      if (_codigoVerificado)
                        _buildPasswordFields(),

                      const SizedBox(height: 24),

                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        hintText: "tu@correo.com",
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildCodeField() {
    return Column(
      children: [
        TextFormField(
          controller: _codigoController,
          decoration: InputDecoration(
            labelText: "Código de verificación",
            hintText: "123456",
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        Text(
          "Código generado: $_codigoGenerado",
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nuevaPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Nueva contraseña",
            hintText: "••••••••",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmarPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirmar contraseña",
            hintText: "••••••••",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (!_codigoEnviado) {
                _enviarCodigo();
              } else if (!_codigoVerificado) {
                _verificarCodigo();
              } else {
                _cambiarPassword();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E7D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              _codigoVerificado 
                  ? "Guardar Cambios"
                  : _codigoEnviado 
                      ? "Verificar Código"
                      : "Generar Código",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              if (_codigoVerificado) {
                _cancelar();
              } else if (_codigoEnviado) {
                setState(() {
                  _codigoEnviado = false;
                  _codigoController.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF064E7D)),
            ),
            child: Text(
              _codigoVerificado ? "Cancelar" : "Volver", 
              style: const TextStyle(
                color: Color(0xFF064E7D),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}