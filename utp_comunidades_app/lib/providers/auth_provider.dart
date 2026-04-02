import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final res = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['token'];
      await ApiService.saveToken(_token!);
      final meRes = await ApiService.get('/auth/me', auth: true);
      if (meRes.statusCode == 200) {
        _user = User.fromJson(jsonDecode(meRes.body)['user']);
        _loading = false;
        notifyListeners();
        return true;
      }
    } else {
      _error = 'Credenciales inválidas';
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await ApiService.deleteToken();
    notifyListeners();
  }
}
