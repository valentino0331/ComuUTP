import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class HashtagProvider with ChangeNotifier {
  List<dynamic> _trendingHashtags = [];
  List<dynamic> _hashtagPosts = [];
  bool _loading = false;

  List<dynamic> get trendingHashtags => _trendingHashtags;
  List<dynamic> get hashtagPosts => _hashtagPosts;
  bool get loading => _loading;

  Future<void> fetchTrendingHashtags() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/hashtags/trending', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _trendingHashtags = data['hashtags'] ?? [];
      }
    } catch (e) {
      print('Error al obtener trending hashtags: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> searchByHashtag(String hashtag) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/hashtags/search/$hashtag', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _hashtagPosts = data['posts'] ?? [];
      }
    } catch (e) {
      print('Error al buscar por hashtag: $e');
    }

    _loading = false;
    notifyListeners();
  }
}
