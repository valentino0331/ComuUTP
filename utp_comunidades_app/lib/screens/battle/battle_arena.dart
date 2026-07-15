// filepath: utp_comunidades_app/lib/screens/battle/battle_arena.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/battle_model.dart';
import '../../services/battle_service.dart';

class BattleArena extends StatefulWidget {
  final int battleId;
  final Battle battle;

  const BattleArena({
    required this.battleId,
    required this.battle,
    Key? key,
  }) : super(key: key);

  @override
  State<BattleArena> createState() => _BattleArenaState();
}

class _BattleArenaState extends State<BattleArena> {
  late BattleService battleService;
  late Timer timerClock;
  List<BattleQuestion> questions = [];
  int currentQuestionIndex = 0;
  int timeRemaining = 60; // segundos por pregunta
  late DateTime battleStartTime;
  int myScore = 0;
  int rivalScore = 0;
  bool answered = false;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    battleService = context.read<BattleService>();

    // Cargar preguntas
    _loadQuestions();

    // Socket listeners
    battleService.onBattleStart((data) {
      setState(() {
        battleStartTime = DateTime.parse(data['start_time']);
      });
      _startTimer();
    });

    battleService.onAnswerResult((data) {
      setState(() {
        if (data['is_correct']) {
          myScore++;
        }
        answered = true;
      });
    });

    battleService.onTeamUpdate((data) {
      setState(() {
        rivalScore++;
      });
    });

    battleService.onBattleFinished((data) {
      _showResults(data);
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final qs = await battleService.getQuestions(widget.battleId);
      setState(() {
        questions = qs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando preguntas: $e')),
      );
    }
  }

  void _startTimer() {
    timerClock = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
        if (timeRemaining <= 0) {
          _nextQuestion();
        }
      });
    });
  }

  void _submitAnswer(String option) async {
    if (answered) return;

    try {
      final question = questions[currentQuestionIndex];
      await battleService.submitAnswer(
        battleId: widget.battleId,
        questionId: question.id,
        selectedOption: option,
      );

      setState(() {
        selectedOption = option;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timeRemaining = 60;
        answered = false;
        selectedOption = null;
      });
    } else {
      _endBattle();
    }
  }

  Future<void> _endBattle() async {
    timerClock.cancel();
    try {
      await battleService.finishBattle(widget.battleId);
    } catch (e) {
      print('Error finalizando: $e');
    }
  }

  void _showResults(Map<String, dynamic> data) {
    timerClock.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final winner = data['winner_team'];
        final challengerScore = data['final_scores']['challenger'];
        final challengedScore = data['final_scores']['challenged'];

        return AlertDialog(
          title: Text('BATALLA FINALIZADA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Icon(
                winner == 'challenger' ? Icons.emoji_events : Icons.mood_sad,
                size: 64,
                color:
                    winner == 'challenger' ? Colors.amber : Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                winner == null
                    ? 'EMPATE'
                    : 'Ganador: ${winner.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Retador'),
                      SizedBox(height: 8),
                      Text(
                        '$challengerScore',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.vs_mobiledata),
                  Column(
                    children: [
                      Text('Desafiado'),
                      SizedBox(height: 8),
                      Text(
                        '$challengedScore',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timerClock.cancel();
    battleService.leaveBattle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ronda ${currentQuestionIndex + 1} de ${questions.length}'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${timeRemaining}s',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: timeRemaining <= 10 ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scoreboard
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('TÚ', style: TextStyle(color: Colors.grey)),
                    Text(
                      '$myScore',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.vs_mobiledata, size: 28),
                Column(
                  children: [
                    Text('RIVAL', style: TextStyle(color: Colors.grey)),
                    Text(
                      '$rivalScore',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          // Pregunta
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                SizedBox(height: 20),
                Text(
                  question.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Opciones
                ...question.options.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String option = entry.value;
                  bool isSelected = selectedOption == option;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (!answered) {
                          _submitAnswer(option);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + idx), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(option),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // Control
          if (answered && currentQuestionIndex < questions.length - 1)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text('SIGUIENTE'),
              ),
            ),
        ],
      ),
    );
  }
}
