class PagoService {
  Future<bool> procesarPago({
    required double monto,
    required String metodoPago,
    required String tarjetaNumero,
  }) async {
    try {
      // Simular procesamiento de pago
      await Future.delayed(const Duration(seconds: 2));
      
      // Validar número de tarjeta básico
      if (tarjetaNumero.length != 16) {
        throw Exception('Número de tarjeta inválido');
      }
      
      return true;
    } catch (e) {
      throw Exception('Error al procesar pago: $e');
    }
  }

  List<String> obtenerMetodosPago() {
    return ['Tarjeta de Crédito', 'Tarjeta de Débito', 'PayPal'];
  }

  bool validarTarjeta(String numero) {
    return numero.replaceAll(' ', '').length == 16;
  }
}