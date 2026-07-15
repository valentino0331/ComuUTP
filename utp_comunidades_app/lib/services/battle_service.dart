// filepath: utp_comunidades_app/lib/services/battle_service.dart
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/battle_model.dart';

class BattleService {
  final Dio dio;
  late IO.Socket socket;
  final String baseUrl;

  BattleService({required this.dio, required this.baseUrl}) {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableReconnection()
        .build());

    socket.onConnect((_) {
      print('⚔️ Socket conectado');
    });

    socket.onDisconnect((_) {
      print('❌ Socket desconectado');
    });

    socket.onError((data) {
      print('⚠️ Error Socket: $data');
    });
  }

  // ===== ENDPOINTS REST =====

  /// Desafiar a comunidad rival
  Future<Map<String, dynamic>> challengeCommunity({
    required int challengerCommunityId,
    required int challengedCommunityId,
    required String difficulty,
    required String career,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/battles/challenge',
        data: {
          'challenger_community_id': challengerCommunityId,
          'challenged_community_id': challengedCommunityId,
          'difficulty': difficulty,
          'career': career,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error desafiando: ${e.message}');
    }
  }

  /// Responder a desafío
  Future<Map<String, dynamic>> respondToChallenge({
    required int battleId,
    required String response, // 'accept' | 'reject'
    required int leaderId,
  }) async {
    try {
      final resp = await dio.put(
        '$baseUrl/api/battles/$battleId/respond',
        data: {
          'response': response,
          'leader_id': leaderId,
        },
      );
      return resp.data;
    } on DioException catch (e) {
      throw Exception('Error respondiendo: ${e.message}');
    }
  }

  /// Iniciar batalla
  Future<Map<String, dynamic>> startBattle(int battleId) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/battles/$battleId/start',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error iniciando: ${e.message}');
    }
  }

  /// Obtener batalla
  Future<Battle> getBattle(int battleId) async {
    try {
      final response = await dio.get('$baseUrl/api/battles/$battleId');
      return Battle.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error obteniendo batalla: ${e.message}');
    }
  }

  /// Obtener preguntas
  Future<List<BattleQuestion>> getQuestions(int battleId) async {
    try {
      final response =
          await dio.get('$baseUrl/api/battles/$battleId/questions');
      final List questions = response.data['questions'] ?? [];
      return questions
          .map((q) => BattleQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error obteniendo preguntas: ${e.message}');
    }
  }

  /// Enviar respuesta
  Future<Map<String, dynamic>> submitAnswer({
    required int battleId,
    required int questionId,
    required String selectedOption,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/battles/$battleId/answer',
        data: {
          'question_id': questionId,
          'selected_option': selectedOption,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error enviando respuesta: ${e.message}');
    }
  }

  /// Cancelar batalla
  Future<Map<String, dynamic>> cancelBattle(int battleId) async {
    try {
      final response = await dio.put('$baseUrl/api/battles/$battleId/cancel');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error cancelando: ${e.message}');
    }
  }

  /// Finalizar batalla
  Future<Map<String, dynamic>> finishBattle(int battleId) async {
    try {
      final response = await dio.post('$baseUrl/api/battles/$battleId/finish');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error finalizando: ${e.message}');
    }
  }

  /// Obtener mis batallas
  Future<List<Battle>> getMyBattles() async {
    try {
      final response = await dio.get('$baseUrl/api/battles/user/my-battles');
      final List battles = response.data['battles'] ?? [];
      return battles
          .map((b) => Battle.fromJson(b as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error obteniendo mis batallas: ${e.message}');
    }
  }

  // ===== SOCKET.IO EVENTS =====

  void joinBattle({
    required int battleId,
    required int userId,
    required int memberId,
    required String team,
  }) {
    socket.emit('join_battle', {
      'battle_id': battleId,
      'user_id': userId,
      'member_id': memberId,
      'team': team,
    });
  }

  void syncTimer({required int battleId, required DateTime startTime}) {
    socket.emit('sync_timer', {
      'battle_id': battleId,
      'timestamp': startTime.toIso8601String(),
    });
  }

  void submitAnswerSocket({
    required int battleId,
    required int questionId,
    required String selectedOption,
  }) {
    socket.emit('submit_answer', {
      'battle_id': battleId,
      'question_id': questionId,
      'selected_option': selectedOption,
    });
  }

  void leaveBattle() {
    socket.emit('leave_battle');
  }

  // ===== SOCKET.IO LISTENERS =====

  void onBattleStart(Function(Map<String, dynamic>) callback) {
    socket.on('battle:start', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onPlayerReady(Function(Map<String, dynamic>) callback) {
    socket.on('battle:player_ready', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onAnswerResult(Function(Map<String, dynamic>) callback) {
    socket.on('battle:answer_result', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onTeamUpdate(Function(Map<String, dynamic>) callback) {
    socket.on('battle:team_update', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onBattleFinished(Function(Map<String, dynamic>) callback) {
    socket.on('battle:finished', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onTimerSync(Function(Map<String, dynamic>) callback) {
    socket.on('battle:timer_sync', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onBattleError(Function(Map<String, dynamic>) callback) {
    socket.on('battle:error', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
