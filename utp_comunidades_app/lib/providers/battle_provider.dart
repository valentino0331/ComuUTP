// filepath: utp_comunidades_app/lib/providers/battle_provider.dart
import 'package:flutter/material.dart';
import '../models/battle_model.dart';
import '../services/battle_service.dart';

class BattleProvider with ChangeNotifier {
  final BattleService battleService;

  Battle? currentBattle;
  List<Battle> myBattles = [];
  List<BattleQuestion> currentQuestions = [];
  bool isLoading = false;
  String? error;

  BattleProvider({required this.battleService});

  // ===== CHALLENGE =====
  Future<void> challengeCommunity({
    required int challengerCommunityId,
    required int challengedCommunityId,
    required String difficulty,
    required String career,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await battleService.challengeCommunity(
        challengerCommunityId: challengerCommunityId,
        challengedCommunityId: challengedCommunityId,
        difficulty: difficulty,
        career: career,
      );

      if (result['success']) {
        await getBattle(result['battle_id']);
      } else {
        error = 'No se pudo crear el desafío';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== RESPOND =====
  Future<void> respondToChallenge({
    required int battleId,
    required String response,
    required int leaderId,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await battleService.respondToChallenge(
        battleId: battleId,
        response: response,
        leaderId: leaderId,
      );

      if (result['success']) {
        await getBattle(battleId);
      } else {
        error = 'Error respondiendo al desafío';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== START =====
  Future<void> startBattle(int battleId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await battleService.startBattle(battleId);
      await getBattle(battleId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== GET BATTLE =====
  Future<void> getBattle(int battleId) async {
    try {
      final battle = await battleService.getBattle(battleId);
      currentBattle = battle;
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  // ===== GET QUESTIONS =====
  Future<void> getQuestions(int battleId) async {
    try {
      final questions = await battleService.getQuestions(battleId);
      currentQuestions = questions;
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  // ===== SUBMIT ANSWER =====
  Future<bool> submitAnswer({
    required int battleId,
    required int questionId,
    required String selectedOption,
  }) async {
    try {
      final result = await battleService.submitAnswer(
        battleId: battleId,
        questionId: questionId,
        selectedOption: selectedOption,
      );
      return result['is_correct'] ?? false;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  // ===== CANCEL =====
  Future<void> cancelBattle(int battleId) async {
    try {
      await battleService.cancelBattle(battleId);
      currentBattle = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  // ===== FINISH =====
  Future<void> finishBattle(int battleId) async {
    try {
      await battleService.finishBattle(battleId);
      await getBattle(battleId);
    } catch (e) {
      error = e.toString();
    }
  }

  // ===== GET MY BATTLES =====
  Future<void> getMyBattles() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final battles = await battleService.getMyBattles();
      myBattles = battles;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== SOCKET.IO =====
  void joinBattle({
    required int battleId,
    required int userId,
    required int memberId,
    required String team,
  }) {
    battleService.joinBattle(
      battleId: battleId,
      userId: userId,
      memberId: memberId,
      team: team,
    );
  }

  void submitAnswerSocket({
    required int battleId,
    required int questionId,
    required String selectedOption,
  }) {
    battleService.submitAnswerSocket(
      battleId: battleId,
      questionId: questionId,
      selectedOption: selectedOption,
    );
  }

  void setupSocketListeners({
    required Function(Map<String, dynamic>) onStart,
    required Function(Map<String, dynamic>) onPlayerReady,
    required Function(Map<String, dynamic>) onAnswerResult,
    required Function(Map<String, dynamic>) onTeamUpdate,
    required Function(Map<String, dynamic>) onFinished,
  }) {
    battleService.onBattleStart(onStart);
    battleService.onPlayerReady(onPlayerReady);
    battleService.onAnswerResult(onAnswerResult);
    battleService.onTeamUpdate(onTeamUpdate);
    battleService.onBattleFinished(onFinished);
  }

  void cleanup() {
    battleService.leaveBattle();
  }

  @override
  void dispose() {
    battleService.disconnect();
    super.dispose();
  }
}
