import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class NotificationProvider with ChangeNotifier {
  List<String> _notifications = [];
  bool _loading = false;
  String? _error;

  List<String> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final res = await ApiService.get('/notifications', auth: true);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['notificaciones'] as List;
      _notifications = data.map((n) => n['mensaje'].toString()).toList();
    } else {
      _error = 'No se pudieron cargar las notificaciones';
    }
    _loading = false;
    notifyListeners();
  }
}
