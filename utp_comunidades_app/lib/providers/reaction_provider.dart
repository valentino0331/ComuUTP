import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ReactionProvider with ChangeNotifier {
  Map<int, String?> _userReactions = {};
  Map<int, Map<String, int>> _postReactions = {};

  Map<int, String?> get userReactions => _userReactions;
  Map<int, Map<String, int>> get postReactions => _postReactions;

  String? getUserReaction(int postId) => _userReactions[postId];

  Map<String, int>? getPostReactions(int postId) => _postReactions[postId];

  Future<void> toggleReaction(int postId, String tipo) async {
    try {
      final res = await ApiService.post('/reactions/toggle', {
        'publicacion_id': postId,
        'tipo': tipo,
      }, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _userReactions[postId] = data['tipo'];
        notifyListeners();
        await fetchPostReactions(postId);
      }
    } catch (e) {
      print('Error al procesar reacción: $e');
    }
  }

  Future<void> fetchPostReactions(int postId) async {
    try {
      final res = await ApiService.get('/reactions/post/$postId', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reactions = <String, int>{};
        for (var reaction in data['reacciones']) {
          reactions[reaction['tipo']] = reaction['count'];
        }
        _postReactions[postId] = reactions;
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener reacciones: $e');
    }
  }

  Future<void> fetchUserReaction(int postId) async {
    try {
      final res = await ApiService.get('/reactions/user/$postId', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _userReactions[postId] = data['tipo'];
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener reacción del usuario: $e');
    }
  }
}
