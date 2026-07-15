import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class FriendshipProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<dynamic> _pendingRequests = [];
  List<dynamic> _friends = [];
  Map<String, String> _friendshipStatus = {};

  bool get loading => _loading;
  String? get error => _error;
  List<dynamic> get pendingRequests => _pendingRequests;
  List<dynamic> get friends => _friends;
  Map<String, String> get friendshipStatus => _friendshipStatus;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Enviar solicitud de amistad
  Future<bool> sendFriendRequest(int amigoId) async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await ApiService.post('/friendship/send', {
        'amigoId': amigoId,
      }, auth: true);

      if (res.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _setError(data['error'] ?? 'Error al enviar solicitud');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Aceptar solicitud de amistad
  Future<bool> acceptFriendRequest(int solicitudId) async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await ApiService.put('/friendship/accept/$solicitudId', {}, auth: true);

      if (res.statusCode == 200) {
        await getPendingRequests(); // Recargar solicitudes pendientes
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _setError(data['error'] ?? 'Error al aceptar solicitud');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Rechazar solicitud de amistad
  Future<bool> rejectFriendRequest(int solicitudId) async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await ApiService.delete('/friendship/reject/$solicitudId', auth: true);

      if (res.statusCode == 200) {
        await getPendingRequests(); // Recargar solicitudes pendientes
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _setError(data['error'] ?? 'Error al rechazar solicitud');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Obtener solicitudes pendientes
  Future<void> getPendingRequests() async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await ApiService.get('/friendship/pending', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _pendingRequests = data;
        _setLoading(false);
      } else {
        final data = jsonDecode(res.body);
        _setError(data['error'] ?? 'Error al obtener solicitudes');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
    }
  }

  // Obtener lista de amigos
  Future<void> getFriends() async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await ApiService.get('/friendship/friends', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _friends = data;
        _setLoading(false);
      } else {
        final data = jsonDecode(res.body);
        _setError(data['error'] ?? 'Error al obtener amigos');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
    }
  }

  // Verificar estado de amistad
  Future<String?> checkFriendshipStatus(int targetUserId) async {
    try {
      final res = await ApiService.get('/friendship/status/$targetUserId', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _friendshipStatus[targetUserId.toString()] = data['status'];
        notifyListeners();
        return data['status'];
      }
    } catch (e) {
      print('Error al verificar estado de amistad: $e');
    }
    return null;
  }
}
