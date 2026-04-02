import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class LikeProvider with ChangeNotifier {
  Map<int, bool> _likes = {};
  bool _loading = false;
  String? _error;

  Map<int, bool> get likes => _likes;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> likePost(int publicacionId) async {
    _loading = true;
    notifyListeners();
    final res = await ApiService.post('/likes', {
      'publicacion_id': publicacionId,
    }, auth: true);
    if (res.statusCode == 200) {
      _likes[publicacionId] = true;
      _loading = false;
      notifyListeners();
      return true;
    }
    _loading = false;
    notifyListeners();
    return false;
  }
}
