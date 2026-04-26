import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReactionsWidget extends StatelessWidget {
  final int postId;
  final String? currentReaction;
  final Function(String) onReactionSelected;

  const ReactionsWidget({
    super.key,
    required this.postId,
    this.currentReaction,
    required this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final reactions = [
      {'emoji': '❤️', 'tipo': 'love', 'color': Colors.red},
      {'emoji': '🔥', 'tipo': 'fire', 'color': Colors.orange},
      {'emoji': '😂', 'tipo': 'laugh', 'color': Colors.yellow},
      {'emoji': '😮', 'tipo': 'wow', 'color': Colors.blue},
      {'emoji': '😢', 'tipo': 'sad', 'color': Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((reaction) {
          final isSelected = currentReaction == reaction['tipo'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onReactionSelected(reaction['tipo'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (reaction['color'] as Color).withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  reaction['emoji'] as String,
                  style: TextStyle(
                    fontSize: isSelected ? 28 : 24,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
