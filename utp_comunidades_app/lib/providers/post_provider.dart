import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'dart:convert';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _loading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchPostsByCommunity(int comunidadId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final res = await ApiService.get('/posts/community/$comunidadId');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['publicaciones'] as List;
      _posts = data.map((p) => Post.fromJson(p)).toList();
    } else {
      _error = 'No se pudieron cargar las publicaciones';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createPost(int comunidadId, String contenido) async {
    final res = await ApiService.post('/posts', {
      'comunidad_id': comunidadId,
      'contenido': contenido,
    }, auth: true);
    if (res.statusCode == 201) {
      await fetchPostsByCommunity(comunidadId);
      return true;
    }
    return false;
  }
}
