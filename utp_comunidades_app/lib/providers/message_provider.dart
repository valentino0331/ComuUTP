import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MessageProvider with ChangeNotifier {
  List<dynamic> _conversations = [];
  List<dynamic> _messages = [];
  bool _loading = false;

  List<dynamic> get conversations => _conversations;
  List<dynamic> get messages => _messages;
  bool get loading => _loading;

  Future<void> fetchConversations() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/messages/conversations', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _conversations = data['conversaciones'] ?? [];
      }
    } catch (e) {
      print('Error al obtener conversaciones: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchMessages(int conversationId) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get('/messages/conversation/$conversationId/messages', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _messages = data['mensajes'] ?? [];
      }
    } catch (e) {
      print('Error al obtener mensajes: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(int conversationId, String contenido) async {
    try {
      final res = await ApiService.post('/messages/send', {
        'conversacion_id': conversationId,
        'contenido': contenido,
      }, auth: true);

      if (res.statusCode == 201) {
        await fetchMessages(conversationId);
        return true;
      }
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
    return false;
  }

  Future<bool> createConversation(int usuario2Id) async {
    try {
      final res = await ApiService.post('/messages/conversation', {
        'usuario2_id': usuario2Id,
      }, auth: true);

      if (res.statusCode == 201) {
        await fetchConversations();
        return true;
      }
    } catch (e) {
      print('Error al crear conversación: $e');
    }
    return false;
  }
}
