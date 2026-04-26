import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/post_detail_screen.dart';
import '../theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onDeleteTap;
  final bool isAuthor;
  
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
    this.onDeleteTap,
    this.isAuthor = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late bool _isLiked = false;
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _likeController.forward().then((_) {
        _likeController.reverse();
      });
    }
    widget.onLikeTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withOpacity(0.33),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: widget.post),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.colorPrimary,
                            AppTheme.colorPrimary.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (widget.post.nombreUsuario ?? 'U')
                              .characters
                              .first
                              .toUpperCase(),
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
                            widget.post.nombreUsuario ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.colorPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.post.nombreComunidad ?? 'Comunidad',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.colorPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hace poco',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.colorTextSecondary,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Reportar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.block, size: 18),
                              SizedBox(width: 8),
                              Text('Bloquear'),
                            ],
                          ),
                        ),
                      ],
                      offset: const Offset(0, 40),
                      child: Icon(
                        Icons.more_vert,
                        color: AppTheme.colorTextSecondary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  widget.post.contenido,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.colorTextPrimary,
                    height: 1.5,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.likes ?? 0}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.colorTextSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble, size: 14, color: Color(0xFF846B70)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.comentarios ?? 0}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.colorTextSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              // Divisor
              Divider(height: 1, color: AppTheme.colorBorder.withOpacity(0.5)),
              // Acciones
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                      label: 'Me gusta',
                      onTap: _toggleLike,
                      isActive: _isLiked,
                      animation: _likeAnimation,
                    ),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'Comentar',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: widget.post),
                          ),
                        );
                      },
                    ),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Compartir',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post compartido'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionItem({
    required String emoji,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.colorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          if (count > 0)
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.colorTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Animation<double>? animation;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppTheme.colorPrimary
                  : AppTheme.colorTextSecondary,
            ),
          ),
        ),
      ),
    );

    if (animation != null && isActive) {
      return ScaleTransition(scale: animation!, child: child);
    }
    return child;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Animation<double>? animation;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppTheme.colorPrimary
                  : AppTheme.colorTextSecondary,
            ),
          ),
        ),
      ),
    );

    if (animation != null && isActive) {
      return ScaleTransition(scale: animation!, child: child);
    }
    return child;
  }
}
