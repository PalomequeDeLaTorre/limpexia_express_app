import 'package:flutter/material.dart';
import '../servicios/pwa_service.dart';

class PwaProvider with ChangeNotifier {
  final PwaService _pwaService = PwaService();

  bool get esInstalable => _pwaService.esInstalable;
  bool get esInstalada => _pwaService.esInstalada;

  void inicializar() {
    _pwaService.inicializar();
    notifyListeners();
  }

  Future<bool> instalarApp() async {
    final resultado = await _pwaService.instalarApp();
    notifyListeners();
    return resultado;
  }

  bool esModoOffline() {
    return _pwaService.esModoOffline();
  }
}