import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageProvider with ChangeNotifier {
  List<dynamic> _conversations = [];
  List<dynamic> _messages = [];
  bool _loading = false;
  IO.Socket? _socket;
  int? _currentConversationId;

  List<dynamic> get conversations => _conversations;
  List<dynamic> get messages => _messages;
  bool get loading => _loading;

  MessageProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.on('new_message', (data) {
      if (_currentConversationId != null) {
        _messages.add(data);
        notifyListeners();
      }
    });

    _socket!.connect();
  }

  void joinConversation(int conversationId) {
    _currentConversationId = conversationId;
    _socket!.emit('join_conversation', conversationId);
  }

  void leaveConversation(int conversationId) {
    _socket!.emit('leave_conversation', conversationId);
    _currentConversationId = null;
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

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
        // El mensaje se agregará automáticamente por Socket.io
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
