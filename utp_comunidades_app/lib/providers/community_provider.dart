import 'package:flutter/material.dart';
import '../models/community.dart';
import '../services/api_service.dart';
import '../utils/mock_data.dart';
import 'dart:convert';

class CommunityProvider with ChangeNotifier {
  List<Community> _communities = [];
  bool _loading = false;
  String? _error;

  List<Community> get communities => _communities;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchCommunities() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Intentar cargar desde API primero
      final res = await ApiService.get('/communities');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['comunidades'] as List;
        _communities = data.map((c) => Community.fromJson(c)).toList();
      } else {
        // Si falla, usar datos mock
        _communities = MockData.getCommunities();
      }
    } catch (e) {
      // Si hay error de conexión, usar datos mock
      _communities = MockData.getCommunities();
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<bool> joinCommunity(int comunidadId) async {
    final res = await ApiService.post('/communities/join', {'comunidad_id': comunidadId}, auth: true);
    if (res.statusCode == 200) {
      await fetchCommunities();
      return true;
    }
    return false;
  }

  Future<bool> createCommunity(String nombre, String descripcion) async {
    final res = await ApiService.post('/communities', {
      'nombre': nombre,
      'descripcion': descripcion,
    }, auth: true);
    if (res.statusCode == 201) {
      await fetchCommunities();
      return true;
    }
    return false;
  }
}
