// filepath: utp_comunidades_app/lib/providers/liga_provider.dart
import 'package:flutter/material.dart';
import '../models/liga.dart';
import '../services/api_service.dart';
import 'dart:convert';

class LigaProvider with ChangeNotifier {
  List<Liga> _ligas = [];
  Liga? _ligaActual;
  bool _loading = false;
  String? _error;

  List<Liga> get ligas => _ligas;
  Liga? get ligaActual => _ligaActual;
  bool get loading => _loading;
  String? get error => _error;

  // Obtener todas las ligas
  Future<void> fetchLigas({int? comunidadId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      String url = '/ligas';
      if (comunidadId != null) {
        url += '?comunidad_id=$comunidadId';
      }

      final res = await ApiService.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _ligas = (data['ligas'] as List)
            .map((l) => Liga.fromJson(l))
            .toList();
      } else {
        _error = 'Error al obtener ligas';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  // Obtener detalle de una liga
  Future<void> fetchLigaDetalle(int ligaId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.get('/ligas/$ligaId', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _ligaActual = Liga.fromJson(data['liga']);
      } else {
        _error = 'Liga no encontrada';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  // Crear liga
  Future<bool> crearLiga({
    required String nombre,
    required String descripcion,
    int? comunidadId,
    String? tipo,
    String? fechaFin,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.post('/ligas', {
        'nombre': nombre,
        'descripcion': descripcion,
        'comunidad_id': comunidadId,
        'tipo': tipo ?? 'general',
        'fecha_fin': fechaFin,
      }, auth: true);

      if (res.statusCode == 201) {
        await fetchLigas(comunidadId: comunidadId);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al crear liga';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
    return false;
  }
}
