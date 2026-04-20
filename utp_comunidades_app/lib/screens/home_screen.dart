import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import 'create_story_screen.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          if (postProvider.loading) {
            return _buildLoadingState();
          }

          if (postProvider.posts.isEmpty) {
            return _buildEmptyState();
          }

          return _buildFeedContent(context, postProvider);
        },
      ),
    );
  }

  /// Build AppBar con degradado profesional azul/morado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB21132).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFFB21132), // Rojo primario
              const Color(0xFFA00D24), // Rojo oscuro
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'LUTP',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.2,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xFF2C0B14),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border,
              color: Colors.black87, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(0xFF2563EB),
        ),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
              color: const Color(0xFF2563EB).withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay publicaciones aún',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sé el primero en compartir!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// Contenido principal del feed
  Widget _buildFeedContent(
      BuildContext context, PostProvider postProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Sección de historias
          _StorySection(),

          // Separador
          Container(height: 8, color: Colors.grey[100]),

          // Feed de posts
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return PostCard(
                post: post,
                onLikeTap: () => postProvider.toggleLike(post.id),
                onCommentTap: () => _showCommentSheet(context, post),
                onShareTap: () => _showShareMessage(context),
              );
            },
          ),

          // FAB Button movido al body para mejor UX
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreatePostScreen()),
                );
              },
              backgroundColor: const Color(0xFF2563EB),
              child: const Icon(Icons.add_photo_alternate,
                  color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar mensaje de compartir
  void _showShareMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Compartido'),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Bottom Sheet para comentarios
  void _showCommentSheet(BuildContext context, dynamic post) {
    final commentController = TextEditingController();
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comentarios',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Comentarios lista
              Expanded(
                child: Center(
                  child: Text(
                    'Aún no hay comentarios',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),

              // Input comentario
              _CommentInputField(
                currentUser: currentUser,
                commentController: commentController,
                onSend: () {
                  if (commentController.text.isNotEmpty &&
                      currentUser != null) {
                    Provider.of<PostProvider>(context, listen: false)
                        .addComment(
                      post.id,
                      commentController.text,
                      currentUser.nombre,
                    );
                    commentController.clear();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget: Sección de Historias
class _StorySection extends StatelessWidget {
  final List<Color> storyColors = const [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF0D47A1),
    Color(0xFF3949AB),
    Color(0xFF512DA8),
  ];

  const _StorySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return StoryItem(
            index: index,
            color: storyColors[index % storyColors.length],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateStoryScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget: Item de historia individual
class StoryItem extends StatelessWidget {
  final int index;
  final Color color;
  final VoidCallback onTap;

  const StoryItem({
    required this.index,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstStory = index == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isFirstStory
                          ? color.withOpacity(0.4)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: isFirstStory ? 12 : 8,
                      offset: const Offset(0, 3),
                      spreadRadius: isFirstStory ? 2 : 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Avatar circular
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFirstStory
                              ? color
                              : Colors.grey[300]!,
                          width: isFirstStory ? 3 : 2,
                        ),
                        color: isFirstStory
                            ? color.withOpacity(0.1)
                            : Colors.grey[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: color,
                            size: isFirstStory ? 38 : 32,
                          ),
                          if (isFirstStory)
                            Text(
                              'Añade',
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Badge del "+" mejorado
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              isFirstStory ? 'Tu historia' : 'Usuario ${index}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isFirstStory ? 12 : 11,
                color: isFirstStory ? Colors.black87 : Colors.grey[600],
                fontWeight: isFirstStory ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget: Tarjeta de publicación
class PostCard extends StatefulWidget {
  final dynamic post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const PostCard({
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _PostHeader(
            post: widget.post,
            onMenuTap: widget.onShareTap,
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.contenido ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Imagen placeholder
          _PostImagePlaceholder(),

          // Estadísticas
          _PostStats(post: widget.post),

          const Divider(height: 1),

          // Acciones
          _PostActions(
            isLiked: _isLiked,
            onLikeTap: () {
              setState(() => _isLiked = !_isLiked);
              widget.onLikeTap();
            },
            onCommentTap: widget.onCommentTap,
            onShareTap: widget.onShareTap,
          ),
        ],
      ),
    );
  }
}

/// Widget: Encabezado del post
class _PostHeader extends StatelessWidget {
  final dynamic post;
  final VoidCallback onMenuTap;

  const _PostHeader({
    required this.post,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.15),
            child: Text(
              post.nombreUsuario?[0] ?? 'U',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.nombreUsuario ?? 'Usuario',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  post.nombreComunidad ?? 'Comunidad',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.share, size: 18),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
                onTap: onMenuTap,
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reportar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget: Imagen placeholder del post
class _PostImagePlaceholder extends StatelessWidget {
  const _PostImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.2),
            const Color(0xFF7C3AED).withOpacity(0.2),
          ],
        ),
        color: Colors.grey[200],
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: 60,
      ),
    );
  }
}

/// Widget: Estadísticas del post
class _PostStats extends StatelessWidget {
  final dynamic post;

  const _PostStats({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          if ((post.likes ?? 0) > 0)
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes ?? 0}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if ((post.comentarios ?? 0) > 0)
            Text(
              '${post.comentarios ?? 0} comentarios',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget: Botones de acciones del post
class _PostActions extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const _PostActions({
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Me gusta',
            color: isLiked ? Colors.red[400]! : Colors.black54,
            onTap: onLikeTap,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Comentar',
            onTap: onCommentTap,
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Compartir',
            onTap: onShareTap,
          ),
          _ActionButton(
            icon: Icons.bookmark_border,
            label: 'Guardar',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Widget: Botón de acción individual
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.black54,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget: Campo de entrada de comentarios
class _CommentInputField extends StatelessWidget {
  final dynamic currentUser;
  final TextEditingController commentController;
  final VoidCallback onSend;

  const _CommentInputField({
    required this.currentUser,
    required this.commentController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.2),
            child: Text(
              currentUser?.nombre[0] ?? 'U',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Añade un comentario...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
