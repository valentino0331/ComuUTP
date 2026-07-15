import 'package:flutter/material.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryUser> allStoryUsers;
  final int initialUserIndex;
  final int initialStoryIndex;

  const StoryViewerScreen({
    super.key,
    required this.allStoryUsers,
    this.initialUserIndex = 0,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int currentUserIndex;
  late int currentStoryIndex;

  @override
  void initState() {
    super.initState();
    currentUserIndex = widget.initialUserIndex;
    currentStoryIndex = widget.initialStoryIndex;
  }

  void _goToNextStory() {
    final currentUser = widget.allStoryUsers[currentUserIndex];
    
    if (currentStoryIndex < currentUser.historias.length - 1) {
      currentStoryIndex++;
    } else if (currentUserIndex < widget.allStoryUsers.length - 1) {
      currentUserIndex++;
      currentStoryIndex = 0;
    } else {
      Navigator.pop(context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allStoryUsers.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No hay historias disponibles',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final currentUser = widget.allStoryUsers[currentUserIndex];
    final currentStory = currentUser.historias[currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _goToNextStory,
        child: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                currentStory.imagenUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: currentUser.fotoPerfil != null
                            ? NetworkImage(currentUser.fotoPerfil!)
                            : null,
                        child: currentUser.fotoPerfil == null
                            ? Icon(Icons.person,
                                color: AppTheme.colorTextSecondary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.nombreUsuario,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              currentStory.timeRemaining,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (currentStory.contenido != null)
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentStory.contenido!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${currentStory.totalVistas} vistas',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
