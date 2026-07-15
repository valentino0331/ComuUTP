import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/follower.dart';
import '../services/api_service.dart';

class FollowerProvider with ChangeNotifier {
  List<Follower> _followers = [];
  List<Follower> _following = [];
  bool _loading = false;
  String? _error;

  List<Follower> get followers => _followers;
  List<Follower> get following => _following;
  bool get loading => _loading;
  String? get error => _error;

  // Obtener los seguidores de un usuario
  Future<bool> fetchFollowers(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.get('/users/followers/$userId', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['seguidores'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _followers = list.map((json) => Follower.fromJson(json)).toList();
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudieron cargar los seguidores';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener a quiénes sigue un usuario
  Future<bool> fetchFollowing(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.get('/users/following/$userId', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['siguiendo'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _following = list.map((json) => Follower.fromJson(json)).toList();
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudieron cargar los seguidos';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
