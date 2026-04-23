import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFB21132),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Inicio',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            PhosphorIcons.bell(PhosphorIconsStyle.regular),
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFB21132),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cargando...',
            style: TextStyle(
              color: Color(0xFFB21132),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.smileyXEyes(PhosphorIconsStyle.fill),
            size: 100,
            color: const Color(0xFFB21132).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay publicaciones aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Sé el primero en compartir!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(
      BuildContext context, PostProvider postProvider) {
    return RefreshIndicator(
      onRefresh: () => postProvider.fetchAllPosts(),
      color: const Color(0xFFB21132),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: postProvider.posts.length,
        itemBuilder: (context, index) {
          final post = postProvider.posts[index];
          final authProvider = context.read<AuthProvider>();
          final currentUser = authProvider.user;
          final currentUserId = currentUser?.id;
          final currentUserRole = currentUser?.role;
          // Comparación numérica explícita
          final postUserId = post.usuarioId is int ? post.usuarioId : int.tryParse(post.usuarioId.toString()) ?? 0;
          final authUserId = currentUserId is int ? currentUserId : int.tryParse(currentUserId.toString()) ?? 0;
          final comunidadCreadorId = post.comunidadCreadorId ?? 0;
          // Verificar permisos: autor, admin, o creador de comunidad
          final isAuthor = currentUserId != null && postUserId == authUserId;
          final isAdmin = currentUserRole == 'admin';
          final isCommunityCreator = comunidadCreadorId > 0 && comunidadCreadorId == authUserId;
          final canDelete = isAuthor || isAdmin || isCommunityCreator;
          // Debug
          print('DEBUG Post ${post.id}: postUserId=$postUserId, authUserId=$authUserId, comunidadCreadorId=$comunidadCreadorId, isAuthor=$isAuthor, isAdmin=$isAdmin, isCommunityCreator=$isCommunityCreator, canDelete=$canDelete');
          return PostCard(
            post: post,
            isAuthor: canDelete,
            onLikeTap: () => postProvider.toggleLike(post.id),
            onCommentTap: () => _showCommentSheet(context, post),
            onShareTap: () => _showShareMessage(context),
            onDeleteTap: canDelete
                ? () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  PhosphorIcons.trash(PhosphorIconsStyle.fill),
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '¿Eliminar publicación?',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Esta acción no se puede deshacer.',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (confirmed == true) {
                      final success = await postProvider.deletePost(post.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Publicación eliminada',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                : null,
          );
        },
      ),
    );
  }

  void _showShareMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.shareNetwork(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text('¡Compartido con éxito!'),
          ],
        ),
        backgroundColor: const Color(0xFFB21132),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCommentSheet(BuildContext context, dynamic post) {
    final commentController = TextEditingController();
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.chatCircleText(PhosphorIconsStyle.fill),
                          color: const Color(0xFFB21132),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Comentarios',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.x(PhosphorIconsStyle.bold),
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.chats(PhosphorIconsStyle.fill),
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no hay comentarios',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Añade un comentario...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: "Montserrat",
                          ),
                        ),
                        style: const TextStyle(fontFamily: "Montserrat"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.paperPlaneRight(
                            PhosphorIconsStyle.fill),
                        color: const Color(0xFFB21132),
                        size: 20,
                      ),
                      onPressed: () {
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final dynamic post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback? onDeleteTap;
  final bool isAuthor;

  const PostCard({
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    this.onDeleteTap,
    this.isAuthor = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(
              post: widget.post,
              onMenuTap: widget.onShareTap,
              onDeleteTap: widget.onDeleteTap,
              isAuthor: widget.isAuthor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                widget.post.contenido ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            _PostStats(post: widget.post),
            Divider(height: 1, color: Colors.grey[200]),
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
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final dynamic post;
  final VoidCallback onMenuTap;
  final VoidCallback? onDeleteTap;
  final bool isAuthor;

  const _PostHeader({
    required this.post,
    required this.onMenuTap,
    this.onDeleteTap,
    this.isAuthor = false,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace poco';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return 'Hace ${(difference.inDays / 7).floor()}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG _PostHeader: post.id=${post.id}, isAuthor=$isAuthor, onDeleteTap=$onDeleteTap');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB21132),
                  const Color(0xFFB21132).withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (post.nombreUsuario ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.nombreUsuario ?? 'Usuario',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _getTimeAgo(post.fecha),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      // Handle bar
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Título
                      const Text(
                        'Opciones',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Compartir
                      _buildBottomSheetOption(
                        'Compartir',
                        PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular),
                        const Color(0xFFB21132),
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.fill,
                                    ),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Enlace copiado',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      // Guardar - Deshabilitado hasta implementar backend
                      // _buildBottomSheetOption(
                      //   'Guardar',
                      //   PhosphorIcons.bookmark(PhosphorIconsStyle.regular),
                      //   Colors.blue,
                      //   () {
                      //     Navigator.pop(context);
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text('Próximamente'),
                      //         duration: Duration(milliseconds: 800),
                      //       ),
                      //     );
                      //   },
                      // ),

                      // Reportar
                      _buildBottomSheetOption(
                        'Reportar',
                        PhosphorIcons.flag(PhosphorIconsStyle.regular),
                        Colors.orange,
                        () {
                          Navigator.pop(context);
                          _showReportDialog(context);
                        },
                      ),

                      // Eliminar (solo si es autor)
                      if (isAuthor) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Divider(height: 1, color: Colors.grey[200]),
                        ),
                        _buildBottomSheetOption(
                          'Eliminar',
                          PhosphorIcons.trash(PhosphorIconsStyle.regular),
                          Colors.red,
                          () {
                            Navigator.pop(context);
                            onDeleteTap?.call();
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Cancelar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.black87,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostStats extends StatelessWidget {
  final dynamic post;

  const _PostStats({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.heart(PhosphorIconsStyle.fill),
            color: const Color(0xFFB21132),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.likes ?? 0}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
            color: Colors.grey[600],
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.comentarios ?? 0}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _ActionButton(
              icon: isLiked
                  ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                  : PhosphorIcons.heart(PhosphorIconsStyle.regular),
              label: 'Me gusta',
              color: isLiked ? const Color(0xFFB21132) : Colors.grey[600]!,
              onTap: onLikeTap,
            ),
          ),
          Expanded(
            child: _ActionButton(
              icon: PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
              label: 'Comentar',
              color: Colors.grey[600]!,
              onTap: onCommentTap,
            ),
          ),
          Expanded(
            child: _ActionButton(
              icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular),
              label: 'Compartir',
              color: Colors.grey[600]!,
              onTap: onShareTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}

void _showReportDialog(BuildContext context, {dynamic post}) {
  final List<Map<String, dynamic>> reportReasons = [
    {'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), 'label': 'Contenido inapropiado', 'color': Colors.red},
    {'icon': PhosphorIcons.prohibit(PhosphorIconsStyle.fill), 'label': 'Spam', 'color': Colors.orange},
    {'icon': PhosphorIcons.users(PhosphorIconsStyle.fill), 'label': 'Acoso o bullying', 'color': Colors.purple},
    {'icon': PhosphorIcons.shieldWarning(PhosphorIconsStyle.fill), 'label': 'Violencia', 'color': Colors.red.shade800},
    {'icon': PhosphorIcons.copyright(PhosphorIconsStyle.fill), 'label': 'Contenido con derechos de autor', 'color': Colors.blue},
    {'icon': PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill), 'label': 'Información falsa', 'color': Colors.teal},
    {'icon': PhosphorIcons.question(PhosphorIconsStyle.fill), 'label': 'Otro', 'color': Colors.grey},
  ];

  String? selectedReason;
  final TextEditingController detailsController = TextEditingController();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Icono
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.flag(PhosphorIconsStyle.fill),
                        color: Colors.orange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reportar publicación',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona una razón',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Opciones de reporte
                    ...reportReasons.map((reason) {
                      final isSelected = selectedReason == reason['label'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedReason = reason['label'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? (reason['color'] as Color).withOpacity(0.1) : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? reason['color'] as Color : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  reason['icon'] as IconData,
                                  color: reason['color'] as Color,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason['label'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                                    color: reason['color'] as Color,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    // Campo de detalles adicionales
                    if (selectedReason != null) ...[
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Detalles adicionales (opcional)',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey[600],
                          ),
                          hintText: 'Describe el problema...',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFB21132), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedReason == null
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    // TODO: Enviar reporte al backend
                                    print('Reporte enviado: $selectedReason - ${detailsController.text}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Reporte enviado. Gracias.',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Reportar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
