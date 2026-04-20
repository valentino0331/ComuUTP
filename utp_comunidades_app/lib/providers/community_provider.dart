import 'package:flutter/material.dart';
import '../models/community.dart';
import '../services/api_service.dart';
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
      // Intentar cargar desde API primero - CON AUTH para obtener es_miembro correctamente
      final res = await ApiService.get('/communities', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['comunidades'] as List;
        _communities = data.map((c) => Community.fromJson(c)).toList();
      } else {
        // Si falla, usar lista vacía
        _communities = [];
      }
    } catch (e) {
      // Si hay error de conexión, usar lista vacía
      _communities = [];
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<bool> joinCommunity(int comunidadId) async {
    try {
      final res = await ApiService.post('/communities/join', {'comunidad_id': comunidadId}, auth: true);
      
      // 200/201 = join exitoso, 409 = ya eres miembro (no es error)
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 409) {
        print('✅ Join exitoso, refrescando comunidades...');
        // Force clear y reload
        _communities.clear();
        notifyListeners();
        
        await Future.delayed(const Duration(milliseconds: 100));
        await fetchCommunities();
        
        print('✅ Comunidades refrescadas. Ahora tienes ${_communities.where((c) => c.esMiembro ?? false).length} comunidades');
        return true;
      }
      print('❌ Join falló con status ${res.statusCode}');
      return false;
    } catch (e) {
      print('Error joining community: $e');
      return false;
    }
  }

  Future<List<Community>> getMyCommunities() async {
    try {
      final res = await ApiService.get('/communities/my-communities', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['comunidades'] as List;
        return data.map((c) => Community.fromJson(c)).toList();
      }
    } catch (e) {
      print('Error getting my communities: $e');
    }
    return [];
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

  /// Dejar de ser miembro de una comunidad
  Future<bool> leaveCommunity(int comunidadId) async {
    try {
      final res = await ApiService.delete(
        '/communities/$comunidadId/leave',
        auth: true,
      );
      
      if (res.statusCode == 200 || res.statusCode == 204) {
        print('✅ Abandonaste la comunidad');
        // Refresco comunidades
        _communities.clear();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
        await fetchCommunities();
        return true;
      }
      print('❌ No se pudo abandonar la comunidad');
      return false;
    } catch (e) {
      print('Error leaving community: $e');
      return false;
    }
  }

  /// Obtener lista de miembros de una comunidad
  Future<List<Map<String, dynamic>>> getMembersOfCommunity(int comunidadId) async {
    try {
      final res = await ApiService.get(
        '/communities/$comunidadId/members',
        auth: true,
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final miembros = (data['miembros'] as List? ?? [])
            .map((m) => m as Map<String, dynamic>)
            .toList();
        return miembros;
      }
      return [];
    } catch (e) {
      print('Error getting community members: $e');
      return [];
    }
  }
}
