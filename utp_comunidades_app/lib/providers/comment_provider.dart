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

  Future<bool> deleteComment(int commentId, int publicacionId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.delete('/comments/$commentId', auth: true);
      if (res.statusCode == 200) {
        // Eliminar del listado local
        _comments.removeWhere((c) => c.id == commentId);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['error'] ?? 'Error al eliminar comentario';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComment(int commentId, String newContent, int publicacionId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.put('/comments/$commentId', {
        'contenido': newContent,
      }, auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Actualizar en el listado local
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index] = Comment.fromJson(data['comentario']);
        }
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['error'] ?? 'Error al actualizar comentario';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
