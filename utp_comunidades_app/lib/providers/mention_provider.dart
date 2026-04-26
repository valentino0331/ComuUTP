import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MentionProvider with ChangeNotifier {
  List<dynamic> _mentions = [];
  bool _loading = false;

  List<dynamic> get mentions => _mentions;
  bool get loading => _loading;

  Future<void> fetchUserMentions() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/mentions/user', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _mentions = data['menciones'] ?? [];
      }
    } catch (e) {
      print('Error al obtener menciones: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(int mentionId) async {
    try {
      final res = await ApiService.put('/mentions/$mentionId/read', {}, auth: true);
      if (res.statusCode == 200) {
        await fetchUserMentions();
        return true;
      }
    } catch (e) {
      print('Error al marcar mención como leída: $e');
    }
    return false;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final res = await ApiService.get('/mentions/search?q=$query', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['usuarios'] ?? [];
      }
    } catch (e) {
      print('Error al buscar usuarios: $e');
    }
    return [];
  }
}
