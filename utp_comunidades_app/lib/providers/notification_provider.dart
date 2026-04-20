import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification.dart';
import 'dart:convert';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _loading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.leida).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> fetchNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.get('/notifications', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['notificaciones'] as List;
        _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
      } else {
        // Si falla, usar datos mock
        _notifications = MockData.getNotifications();
      }
    } catch (e) {
      // Si hay error de conexión, usar datos mock
      _notifications = MockData.getNotifications();
    }
    
    _loading = false;
    notifyListeners();
  }
}
