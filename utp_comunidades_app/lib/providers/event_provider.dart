import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class EventProvider with ChangeNotifier {
  List<dynamic> _events = [];
  bool _loading = false;

  List<dynamic> get events => _events;
  bool get loading => _loading;

  Future<void> fetchCommunityEvents(int comunidadId) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/events/community/$comunidadId', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _events = data['eventos'] ?? [];
      }
    } catch (e) {
      print('Error al obtener eventos: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> rsvpEvent(int eventoId, String estado) async {
    try {
      final res = await ApiService.post('/events/rsvp', {
        'evento_id': eventoId,
        'estado': estado,
      }, auth: true);

      if (res.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print('Error al RSVP evento: $e');
    }
    return false;
  }

  Future<String?> getUserRsvp(int eventoId) async {
    try {
      final res = await ApiService.get('/events/rsvp/$eventoId', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['estado'];
      }
    } catch (e) {
      print('Error al obtener RSVP del usuario: $e');
    }
    return null;
  }
}
