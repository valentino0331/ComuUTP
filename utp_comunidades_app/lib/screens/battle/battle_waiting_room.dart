// filepath: utp_comunidades_app/lib/screens/battle/battle_waiting_room.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/battle_model.dart';
import '../../services/battle_service.dart';
import '../../providers/user_provider.dart';

class BattleWaitingRoom extends StatefulWidget {
  final int battleId;
  final Battle battle;

  const BattleWaitingRoom({
    required this.battleId,
    required this.battle,
    Key? key,
  }) : super(key: key);

  @override
  State<BattleWaitingRoom> createState() => _BattleWaitingRoomState();
}

class _BattleWaitingRoomState extends State<BattleWaitingRoom> {
  late BattleService battleService;
  List<Map<String, dynamic>> teamMembers = [];
  bool isLeader = false;
  bool allReady = false;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    battleService = context.read<BattleService>();

    isLeader = widget.battle.leaderId == userProvider.user!.id;

    // Cargar miembros del equipo
    _loadTeamMembers();

    // Listeners Socket
    battleService.onPlayerReady((data) {
      setState(() {
        teamMembers = [
          ...teamMembers,
          {'user_id': data['user_id'], 'ready': true}
        ];
        _checkAllReady();
      });
    });
  }

  Future<void> _loadTeamMembers() async {
    // Mock: obtener miembros del equipo
    setState(() {
      allReady = teamMembers.length >= 2;
    });
  }

  void _checkAllReady() {
    setState(() {
      allReady = teamMembers.length >= 2 &&
          teamMembers.every((m) => m['ready'] == true);
    });
  }

  Future<void> _startBattle() async {
    try {
      await battleService.startBattle(widget.battleId);
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        '/battle-arena',
        arguments: {'battleId': widget.battleId, 'battle': widget.battle},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sala de Espera'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Encabezado: Comunidades
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCommunityCard(
                  name: widget.battle.challengerName,
                  label: 'RETADOR',
                  color: Colors.blue,
                ),
                Icon(Icons.vs_mobiledata, size: 32),
                _buildCommunityCard(
                  name: widget.battle.challengedName,
                  label: 'DESAFIADO',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Divider(),
          // Dificultad y carrera
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dificultad: ${widget.battle.difficulty.toUpperCase()}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Carrera: ${widget.battle.career}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Divider(),
          // Miembros del equipo (representantes)
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'TU EQUIPO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
                ...teamMembers.map((member) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Text(
                              member['user_id']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Usuario ${member['user_id']}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          member['ready']
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.schedule, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // Botones de control
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (isLeader)
                  ElevatedButton(
                    onPressed: allReady ? _startBattle : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allReady ? Colors.green : Colors.grey,
                      minimumSize: Size.fromHeight(50),
                    ),
                    child: Text(
                      allReady ? 'INICIAR BATALLA' : 'Esperando todos listos...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Text(
                    'Esperando al líder...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard({
    required String name,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
