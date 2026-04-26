import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class PollProvider with ChangeNotifier {
  Map<int, dynamic> _pollResults = {};
  Map<int, String?> _userVotes = {};
  bool _loading = false;

  Map<int, dynamic> get pollResults => _pollResults;
  Map<int, String?> get userVotes => _userVotes;
  bool get loading => _loading;

  Future<bool> createPoll(int postId, String pregunta, List<String> opciones) async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/polls', {
        'publicacion_id': postId,
        'pregunta': pregunta,
        'opciones': opciones,
      }, auth: true);

      if (res.statusCode == 201) {
        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error al crear encuesta: $e');
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  Future<bool> votePoll(int pollId, int opcionId) async {
    try {
      final res = await ApiService.post('/polls/vote', {
        'encuesta_id': pollId,
        'opcion_id': opcionId,
      }, auth: true);

      if (res.statusCode == 201) {
        _userVotes[pollId] = opcionId.toString();
        await getPollResults(pollId);
        return true;
      }
    } catch (e) {
      print('Error al votar en encuesta: $e');
    }
    return false;
  }

  Future<void> getPollResults(int pollId) async {
    try {
      final res = await ApiService.get('/polls/$pollId/results', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _pollResults[pollId] = data;
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener resultados de encuesta: $e');
    }
  }

  Future<void> getUserVote(int pollId) async {
    try {
      final res = await ApiService.get('/polls/$pollId/vote', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _userVotes[pollId] = data['opcion_id']?.toString();
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener voto del usuario: $e');
    }
  }
}
