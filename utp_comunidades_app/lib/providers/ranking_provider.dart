// filepath: utp_comunidades_app/lib/providers/ranking_provider.dart
import 'package:flutter/material.dart';
import '../models/liga.dart';
import '../services/api_service.dart';
import 'dart:convert';

class RankingProvider with ChangeNotifier {
  List<RankingUsuario> _ranking = [];
  RankingUsuario? _miPosicion;
  bool _loading = false;
  String? _error;

  List<RankingUsuario> get ranking => _ranking;
  RankingUsuario? get miPosicion => _miPosicion;
  bool get loading => _loading;
  String? get error => _error;

  // Obtener ranking de una liga
  Future<void> fetchRankingLiga(int ligaId, {int limit = 50}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.get('/ranking/liga/$ligaId?limit=$limit', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _ranking = (data['ranking'] as List)
            .map((r) => RankingUsuario.fromJson(r))
            .toList();
      } else {
        _error = 'Error al obtener ranking';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  // Obtener mi posición en una liga
  Future<void> fetchMiPosicion(int ligaId) async {
    try {
      final res = await ApiService.get('/ranking/liga/$ligaId/mi-posicion', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['posicion'] != null) {
          _miPosicion = RankingUsuario.fromJson(data['posicion']);
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  // Obtener ranking general
  Future<void> fetchRankingGeneral({int limit = 100}) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/ranking?limit=$limit');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _ranking = (data['ranking'] as List)
            .map((r) => RankingUsuario.fromJson(r))
            .toList();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  // Obtener ranking por comunidad
  Future<void> fetchRankingComunidad(int comunidadId, {int limit = 50}) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get(
        '/ranking/comunidad/$comunidadId?limit=$limit',
        auth: true,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _ranking = (data['ranking'] as List)
            .map((r) => RankingUsuario.fromJson(r))
            .toList();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }
}
