import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class SearchProvider with ChangeNotifier {
  List<dynamic> _users = [];
  List<dynamic> _posts = [];
  List<dynamic> _communities = [];
  List<dynamic> _hashtags = [];
  bool _loading = false;

  List<dynamic> get users => _users;
  List<dynamic> get posts => _posts;
  List<dynamic> get communities => _communities;
  List<dynamic> get hashtags => _hashtags;
  bool get loading => _loading;

  Future<void> search(String query, {String? tipo}) async {
    _loading = true;
    notifyListeners();

    try {
      final queryParams = tipo != null ? '?q=$query&tipo=$tipo' : '?q=$query';
      final res = await ApiService.get('/search$queryParams', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _users = data['usuarios'] ?? [];
        _posts = data['posts'] ?? [];
        _communities = data['comunidades'] ?? [];
        _hashtags = data['hashtags'] ?? [];
      }
    } catch (e) {
      print('Error al buscar: $e');
    }

    _loading = false;
    notifyListeners();
  }

  void clearResults() {
    _users = [];
    _posts = [];
    _communities = [];
    _hashtags = [];
    notifyListeners();
  }
}
