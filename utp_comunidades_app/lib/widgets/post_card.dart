import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/post_detail_screen.dart';
import '../theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.colorSurface,
        borderRadius: BorderRadius.circular(12),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
              // Header del post
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.colorPrimary,
                            AppTheme.colorPrimary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.colorPrimary.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (widget.post.nombreUsuario ?? 'U')
                              .characters
                              .first
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre y metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.nombreUsuario ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.post.nombreComunidad ?? 'Comunidad',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.colorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hace poco',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.colorTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Menu
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

              // Contenido del post
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.contenido,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.colorTextPrimary,
                        height: 1.5,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Mostrar imagen SOLO si existe
                    if (widget.post.imagen != null && 
                        widget.post.imagen!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post.imagen!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                    if (widget.post.imagen != null && 
                        widget.post.imagen!.isNotEmpty)
                      const SizedBox(height: 12),
                  ],
                ),
              ),

              // Reacciones y stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildReactionItem(
                      emoji: '👍',
                      count: widget.post.likes ?? 0,
                    ),
                    const SizedBox(width: 8),
                    _buildReactionItem(
                      emoji: '❤️',
                      count: _isLiked ? 1 : 0,
                    ),
                    const Spacer(),
                    Text(
                      '${widget.post.comentarios ?? 0} comentarios',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Divisor
              Container(
                height: 1,
                color: AppTheme.colorBorder,
              ),

              // Acciones
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
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
                            builder: (_) =>
                                PostDetailScreen(post: widget.post),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? AppTheme.colorPrimary
                      : AppTheme.colorTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? AppTheme.colorPrimary
                        : AppTheme.colorTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
