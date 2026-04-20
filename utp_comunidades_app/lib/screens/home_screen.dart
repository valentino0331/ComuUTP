import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      backgroundColor: const Color(0xFFF8F8F8),
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
      elevation: 8,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFED1C24),
              const Color(0xFFB21132),
            ],
          ),
        ),
      ),
      toolbarHeight: 90,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.houseSimple(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'UTP Comunidades',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tu comunidad universitaria',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            PhosphorIcons.bell(PhosphorIconsStyle.regular),
            color: Colors.white,
            size: 26,
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _StorySection(),
            Container(height: 16, color: Colors.transparent),
            _buildQuickPostSection(context),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPostSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFB21132).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              color: const Color(0xFFB21132),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.plus(PhosphorIconsStyle.bold),
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '¿Qué piensas?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateStoryScreen(),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFB21132),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.image(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
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

class _StorySection extends StatelessWidget {
  const _StorySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.image(PhosphorIconsStyle.fill),
                  color: const Color(0xFFB21132),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Historias',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 8,
              itemBuilder: (context, index) {
                return StoryItem(
                  index: index,
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
          ),
        ],
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const StoryItem({
    required this.index,
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
                          ? const Color(0xFFB21132).withOpacity(0.4)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: isFirstStory ? 12 : 6,
                      offset: const Offset(0, 3),
                      spreadRadius: isFirstStory ? 2 : 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFirstStory
                              ? const Color(0xFFB21132)
                              : Colors.grey[300]!,
                          width: isFirstStory ? 3 : 2,
                        ),
                        color: isFirstStory
                            ? const Color(0xFFB21132).withOpacity(0.08)
                            : Colors.grey[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFirstStory
                                ? PhosphorIcons.plus(PhosphorIconsStyle.bold)
                                : PhosphorIcons.image(
                                    PhosphorIconsStyle.fill),
                            color: isFirstStory
                                ? const Color(0xFFB21132)
                                : Colors.grey[400],
                            size: isFirstStory ? 36 : 28,
                          ),
                          if (isFirstStory) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Añade',
                              style: TextStyle(
                                color: const Color(0xFFB21132),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    if (isFirstStory)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB21132),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB21132)
                                    .withOpacity(0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            PhosphorIcons.plus(PhosphorIconsStyle.bold),
                            color: Colors.white,
                            size: 18,
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
            width: 80,
            child: Text(
              isFirstStory ? 'Tu historia' : 'Usuario ${index}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isFirstStory ? 12 : 11,
                fontFamily: 'Montserrat',
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            post: widget.post,
            onMenuTap: widget.onShareTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.post.contenido ?? '',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          if (widget.post.imagen != null &&
              widget.post.imagen!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imagen!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFB21132),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        PhosphorIcons.image(PhosphorIconsStyle.regular),
                        color: Colors.grey[400],
                        size: 60,
                      ),
                    );
                  },
                ),
              ),
            ),
          _PostStats(post: widget.post),
          const Divider(height: 1),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFB21132).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              color: const Color(0xFFB21132),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario ${post.usuarioId}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Hace 2 horas',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.fill),
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: onMenuTap,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.heart(PhosphorIconsStyle.fill),
            color: const Color(0xFFB21132),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '42',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
            color: Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '8',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: isLiked
                ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                : PhosphorIcons.heart(PhosphorIconsStyle.regular),
            label: 'Me gusta',
            color: isLiked ? const Color(0xFFB21132) : Colors.grey[600]!,
            onTap: onLikeTap,
          ),
          _ActionButton(
            icon: PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
            label: 'Comentar',
            color: Colors.grey[600]!,
            onTap: onCommentTap,
          ),
          _ActionButton(
            icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular),
            label: 'Compartir',
            color: Colors.grey[600]!,
            onTap: onShareTap,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
