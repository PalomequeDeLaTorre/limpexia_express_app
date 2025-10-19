import 'package:intl/intl.dart';

class Helpers {
  static String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
  
  static String formatearPrecio(double precio) {
    return '\$${precio.toStringAsFixed(2)}';
  }
  
  static bool validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool validarTelefono(String telefono) {
    return RegExp(r'^\d{10}$').hasMatch(telefono);
  }
  
  static String obtenerIniciales(String nombre) {
    final partes = nombre.split(' ');
    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}