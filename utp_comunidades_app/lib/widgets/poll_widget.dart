import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/poll_provider.dart';
import '../theme/app_theme.dart';

class PollWidget extends StatelessWidget {
  final int postId;
  final dynamic poll;

  const PollWidget({
    super.key,
    required this.postId,
    required this.poll,
  });

  @override
  Widget build(BuildContext context) {
    final pollProvider = context.watch<PollProvider>();
    final userVote = pollProvider.userVotes[poll['id']];
    final results = pollProvider.pollResults[poll['id']];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll['pregunta'] ?? '',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (results != null)
            ...results['opciones'].map<Widget>((opcion) {
              final totalVotes = results['total_votos'] ?? 0;
              final votes = opcion['votos'] ?? 0;
              final percentage = totalVotes > 0 ? (votes / totalVotes * 100).round() : 0;
              final isSelected = userVote == opcion['id'].toString();

              return _buildPollOption(
                opcion['texto'],
                percentage,
                isSelected,
                true,
              );
            }).toList()
          else
            ...poll['opciones'].map<Widget>((opcion) {
              final opcionId = opcion['id'];
              return _buildPollOption(
                opcion['texto'],
                0,
                false,
                false,
                onTap: () {
                  pollProvider.votePoll(poll['id'], opcionId);
                },
              );
            }).toList(),
          const SizedBox(height: 8),
          Text(
            '${results?['total_votos'] ?? 0} votos',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    String texto,
    int percentage,
    bool isSelected,
    bool showResults, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB21132).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB21132) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        texto,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (showResults)
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected ? const Color(0xFFB21132) : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (showResults && percentage > 0)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFB21132).withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
