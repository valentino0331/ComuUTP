import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> reportContent(String tipo, int referenciaId, String motivo) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final res = await ApiService.post('/reports', {
      'tipo': tipo,
      'referencia_id': referenciaId,
      'motivo': motivo,
    }, auth: true);
    if (res.statusCode == 201) {
      _loading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'No se pudo registrar el reporte';
    }
    _loading = false;
    notifyListeners();
    return false;
  }
}
