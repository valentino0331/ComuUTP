import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class SavedProvider with ChangeNotifier {
  List<dynamic> _savedPosts = [];
  List<dynamic> _collections = [];
  bool _loading = false;

  List<dynamic> get savedPosts => _savedPosts;
  List<dynamic> get collections => _collections;
  bool get loading => _loading;

  Future<void> fetchSavedPosts() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/saved/posts', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _savedPosts = data['posts'] ?? [];
      }
    } catch (e) {
      print('Error al obtener posts guardados: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchCollections() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/saved/collections', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _collections = data['colecciones'] ?? [];
      }
    } catch (e) {
      print('Error al obtener colecciones: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> savePost(int postId, {int? coleccionId}) async {
    try {
      final res = await ApiService.post('/saved/save', {
        'post_id': postId,
        if (coleccionId != null) 'coleccion_id': coleccionId,
      }, auth: true);

      if (res.statusCode == 201) {
        await fetchSavedPosts();
        return true;
      }
    } catch (e) {
      print('Error al guardar post: $e');
    }
    return false;
  }

  Future<bool> unsavePost(int postId) async {
    try {
      final res = await ApiService.delete('/saved/unsave/$postId', auth: true);
      if (res.statusCode == 200) {
        await fetchSavedPosts();
        return true;
      }
    } catch (e) {
      print('Error al desguardar post: $e');
    }
    return false;
  }

  Future<bool> createCollection(String nombre, {String? descripcion, bool privada = true}) async {
    try {
      final res = await ApiService.post('/saved/collection', {
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        'privada': privada,
      }, auth: true);

      if (res.statusCode == 201) {
        await fetchCollections();
        return true;
      }
    } catch (e) {
      print('Error al crear colección: $e');
    }
    return false;
  }
}
