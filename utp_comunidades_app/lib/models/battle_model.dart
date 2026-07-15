// filepath: utp_comunidades_app/lib/models/battle_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'battle_model.g.dart';

@JsonSerializable()
class Battle {
  final int id;
  final int challengerCommunityId;
  final int challengedCommunityId;
  final String challengerName;
  final String challengedName;
  final int leaderId;
  final String leaderUsername;
  final int? opponentLeaderId;
  final String? opponentUsername;
  final String difficulty;
  final String career;
  final String status; // pending, waiting_start, active, completed
  final DateTime? startTime;
  final DateTime? endTime;
  final String? winnerTeam;
  final int challengerScore;
  final int challengedScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  Battle({
    required this.id,
    required this.challengerCommunityId,
    required this.challengedCommunityId,
    required this.challengerName,
    required this.challengedName,
    required this.leaderId,
    required this.leaderUsername,
    this.opponentLeaderId,
    this.opponentUsername,
    required this.difficulty,
    required this.career,
    required this.status,
    this.startTime,
    this.endTime,
    this.winnerTeam,
    this.challengerScore = 0,
    this.challengedScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Battle.fromJson(Map<String, dynamic> json) => _$BattleFromJson(json);
  Map<String, dynamic> toJson() => _$BattleToJson(this);
}

@JsonSerializable()
class BattleQuestion {
  final int id;
  final int order;
  final String title;
  final List<String> options;

  BattleQuestion({
    required this.id,
    required this.order,
    required this.title,
    required this.options,
  });

  factory BattleQuestion.fromJson(Map<String, dynamic> json) =>
      _$BattleQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$BattleQuestionToJson(this);
}

@JsonSerializable()
class BattleScore {
  final int memberId;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final int rankingPoints;

  BattleScore({
    required this.memberId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.rankingPoints,
  });

  factory BattleScore.fromJson(Map<String, dynamic> json) =>
      _$BattleScoreFromJson(json);
  Map<String, dynamic> toJson() => _$BattleScoreToJson(this);
}

@JsonSerializable()
class BattleResult {
  final int battleId;
  final String? winnerTeam;
  final int challengerScore;
  final int challengedScore;
  final DateTime timestamp;

  BattleResult({
    required this.battleId,
    this.winnerTeam,
    required this.challengerScore,
    required this.challengedScore,
    required this.timestamp,
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) =>
      _$BattleResultFromJson(json);
  Map<String, dynamic> toJson() => _$BattleResultToJson(this);
}
