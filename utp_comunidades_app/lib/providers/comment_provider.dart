import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import 'dart:convert';

class CommentProvider with ChangeNotifier {
  List<Comment> _comments = [];
  bool _loading = false;
  String? _error;

  List<Comment> get comments => _comments;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchComments(int publicacionId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.get('/comments/$publicacionId');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['comentarios'] as List;
        _comments = data.map((c) => Comment.fromJson(c)).toList();
      } else {
        // Si falla, usar lista vacía
        _comments = [];
      }
    } catch (e) {
      // Si hay error de conexión, usar lista vacía
      _comments = [];
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<bool> createComment(int publicacionId, String contenido) async {
    final res = await ApiService.post('/comments', {
      'publicacion_id': publicacionId,
      'contenido': contenido,
    }, auth: true);
    if (res.statusCode == 201) {
      await fetchComments(publicacionId);
      return true;
    }
    return false;
  }
}
