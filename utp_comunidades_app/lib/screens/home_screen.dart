import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
      Provider.of<CommunityProvider>(context, listen: false).fetchCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(authProvider),
            ),
            SliverToBoxAdapter(
              child: _buildStoriesRow(),
            ),
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: Consumer<PostProvider>(
                builder: (context, postProvider, _) {
                  if (postProvider.loading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (postProvider.posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('No hay publicaciones aún'),
                      ),
                    );
                  }
                  
                  final posts = postProvider.posts;
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = posts[index];
                        return Column(
                          children: [
                            _buildPostCardFromModel(context, post, postProvider),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                      childCount: posts.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '¡Hola, ${authProvider.user?.nombre.split(' ').first ?? 'Usuario'}!',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB21132),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tenemos nuevas publicaciones de tus comunidades',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todo', 'Seguidos', 'Popular'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = index);
                final postProvider = Provider.of<PostProvider>(context, listen: false);
                _filterPosts(index, postProvider);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF474545),
              side: BorderSide(
                color: isSelected ? const Color(0xFF474545) : Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              label: Text(
                filters[index],
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoriesRow() {
    final List<Map<String, dynamic>> mockStories = [
      {'name': 'Tu historia', 'isUser': true, 'hasStory': false},
      {'name': 'María', 'isUser': false, 'hasStory': true, 'viewed': false},
      {'name': 'Carlos', 'isUser': false, 'hasStory': true, 'viewed': true},
      {'name': 'Ana', 'isUser': false, 'hasStory': true, 'viewed': false},
      {'name': 'Pedro', 'isUser': false, 'hasStory': true, 'viewed': false},
      {'name': 'Laura', 'isUser': false, 'hasStory': false, 'viewed': false},
      {'name': 'Diego', 'isUser': false, 'hasStory': true, 'viewed': true},
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: mockStories.length,
        itemBuilder: (context, index) {
          final story = mockStories[index];
          return GestureDetector(
            onTap: () {
              if (story['isUser']) {
                _showAddStoryOptions();
              } else if (story['hasStory']) {
                _showStoryViewer(story['name']);
              }
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Avatar con borde degradado para historias no vistas
                  Container(
                    width: 64,
                    height: 64,
                    decoration: story['hasStory']
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: story['viewed']
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey[400]!,
                                      Colors.grey[400]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFB21132),
                                      Color(0xFFE83E8C),
                                      Color(0xFFFFD700),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          )
                        : null,
                    child: Padding(
                      padding: story['hasStory']
                          ? const EdgeInsets.all(2)
                          : EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: !story['hasStory']
                              ? Border.all(color: Colors.grey[300]!, width: 1)
                              : null,
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: story['isUser']
                              ? const Color(0xFFB21132)
                              : Colors.grey[300],
                          child: story['isUser']
                              ? const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  story['name'][0],
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nombre
                  Text(
                    story['name'],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: story['isUser'] ? FontWeight.w600 : FontWeight.normal,
                      color: story['isUser'] ? const Color(0xFFB21132) : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddStoryOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFB21132),
                ),
              ),
              title: const Text(
                'Cámara',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo cámara...')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Galería',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo galería...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryViewer(String username) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => StoryViewer(username: username),
    );
  }

  Widget _buildPostCardFromModel(BuildContext context, Post post, PostProvider postProvider) {
    final userInitial = post.nombreUsuario?.substring(0, 1) ?? 'U';
    final isLiked = postProvider.isPostLiked(post.id);
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFB21132),
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        post.nombreComunidad ?? 'Comunidad',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(context, post),
                  icon: Icon(
                    PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                    color: Colors.grey[400],
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () => _navigateToPostDetail(context, post),
              child: Text(
                post.contenido,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () => _navigateToPostDetail(context, post),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(
                    PhosphorIcons.image(PhosphorIconsStyle.regular),
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildActionButton(
                  icon: isLiked 
                      ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                      : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                  count: post.likes ?? 0,
                  color: isLiked ? const Color(0xFFB21132) : Colors.grey[500],
                  onTap: () => postProvider.toggleLike(post.id),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: PhosphorIcons.chatCircleText(PhosphorIconsStyle.bold),
                  count: postProvider.getCommentCount(post.id),
                  onTap: () => _showComments(context, post),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _sharePost(context, post),
                  icon: Icon(
                    PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold),
                    color: Colors.grey[500],
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(PhosphorIcons.bookmark(PhosphorIconsStyle.regular)),
              title: const Text('Guardar publicación'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Publicación guardada')),
                );
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular)),
              title: const Text('Compartir en...'),
              onTap: () {
                Navigator.pop(context);
                _sharePost(context, post);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.warning(PhosphorIconsStyle.regular), color: Colors.orange),
              title: const Text('Reportar publicación', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, post);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar publicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Por qué quieres reportar esta publicación de ${post.nombreUsuario}?'),
            const SizedBox(height: 16),
            _buildReportOption('Contenido inapropiado'),
            _buildReportOption('Spam'),
            _buildReportOption('Información falsa'),
            _buildReportOption('Otros'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte enviado: $reason')),
        );
      },
    );
  }

  void _navigateToPostDetail(BuildContext context, Post post) {
    Navigator.pushNamed(
      context, 
      '/post-detail',
      arguments: {'postId': post.id},
    );
  }

  void _showComments(BuildContext context, Post post) {
    final commentController = TextEditingController();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserName = authProvider.user?.nombre ?? 'Usuario';
    
    postProvider.loadCommentsForPost(post.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<PostProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Comentarios',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${provider.comments.length}',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Comments list
                Expanded(
                  child: Consumer<PostProvider>(
                    builder: (context, provider, _) {
                      if (provider.comments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aún no hay comentarios',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sé el primero en comentar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.comments.length,
                        itemBuilder: (context, index) {
                          final comment = provider.comments[index];
                          return _buildCommentItem(comment, index);
                        },
                      );
                    },
                  ),
                ),
                
                // Input area
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFB21132),
                        child: Text(
                          currentUserName.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              postProvider.addComment(post.id, text.trim(), currentUserName);
                              commentController.clear();
                              setModalState(() {});
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Agrega un comentario...',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            suffixIcon: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: commentController,
                              builder: (context, value, child) {
                                if (value.text.isEmpty) return const SizedBox.shrink();
                                return IconButton(
                                  onPressed: () {
                                    if (commentController.text.trim().isNotEmpty) {
                                      postProvider.addComment(post.id, commentController.text.trim(), currentUserName);
                                      commentController.clear();
                                      setModalState(() {});
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.send,
                                    color: Color(0xFFB21132),
                                    size: 22,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, int index) {
    final mockUsers = MockData.getUsers();
    final user = mockUsers.firstWhere(
      (u) => u.id == comment.usuarioId,
      orElse: () => mockUsers.first,
    );
    final timeAgo = _getTimeAgo(comment.fecha);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user.fotoPerfil != null
                ? NetworkImage(user.fotoPerfil!)
                : null,
            backgroundColor: const Color(0xFFB21132),
            child: user.fotoPerfil == null
                ? Text(
                    user.nombre.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.nombre,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.contenido,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCommentAction('Responder'),
                    const SizedBox(width: 16),
                    _buildCommentAction('Me gusta'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentAction(String label) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[500],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  void _sharePost(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Compartir',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(PhosphorIcons.link(PhosphorIconsStyle.regular), 'Copiar link', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copiado al portapapeles')),
                  );
                }),
                _buildShareOption(PhosphorIcons.whatsappLogo(PhosphorIconsStyle.regular), 'WhatsApp', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartiendo en WhatsApp...')),
                  );
                }),
                _buildShareOption(PhosphorIcons.facebookLogo(PhosphorIconsStyle.regular), 'Facebook', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartiendo en Facebook...')),
                  );
                }),
                _buildShareOption(PhosphorIcons.twitterLogo(PhosphorIconsStyle.regular), 'Twitter', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartiendo en Twitter...')),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: const Color(0xFFB21132)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String userName,
    required String userCareer,
    required String userInitial,
    required String content,
    required int likes,
    required int comments,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFB21132),
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        userCareer,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                    color: Colors.grey[400],
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              content,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[200],
                child: Icon(
                  PhosphorIcons.image(PhosphorIconsStyle.regular),
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildActionButton(
                  icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
                  count: likes,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: PhosphorIcons.chatCircleText(PhosphorIconsStyle.bold),
                  count: comments,
                  onTap: () {},
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold),
                    color: Colors.grey[500],
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _filterPosts(int filterIndex, PostProvider postProvider) {
    // Filter logic for the chips: 0=Todo, 1=Seguidos, 2=Popular
    final allPosts = MockData.getPosts();
    
    switch (filterIndex) {
      case 0: // Todo - show all posts
        postProvider.setFilteredPosts(allPosts);
        break;
      case 1: // Seguidos - show posts from followed communities/users
        // For now, simulate followed posts by showing posts from communities 1,2
        final followedPosts = allPosts.where((p) => 
          p.comunidadId == 1 || p.comunidadId == 2
        ).toList();
        postProvider.setFilteredPosts(followedPosts.isEmpty ? allPosts : followedPosts);
        break;
      case 2: // Popular - sort by likes
        final popularPosts = List<Post>.from(allPosts)
          ..sort((a, b) => (b.likes ?? 0).compareTo(a.likes ?? 0));
        postProvider.setFilteredPosts(popularPosts);
        break;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.grey[500],
            size: 22,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryViewer extends StatefulWidget {
  final String username;

  const StoryViewer({
    super.key,
    required this.username,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentStoryIndex = 0;
  final int _totalStories = 3;

  final List<Map<String, dynamic>> _mockStoryContent = [
    {
      'type': 'image',
      'content': 'Contenido de historia 1',
      'time': '2h',
    },
    {
      'type': 'text',
      'content': '¡Hola a todos! 👋',
      'time': '1h',
    },
    {
      'type': 'image',
      'content': 'Contenido de historia 3',
      'time': '30m',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  void _nextStory() {
    if (_currentStoryIndex < _totalStories - 1) {
      setState(() {
        _currentStoryIndex++;
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _progressController.reset();
        _progressController.forward();
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _progressController.stop(),
        onLongPressEnd: (_) => _progressController.forward(),
        child: Stack(
          children: [
            // Contenido de la historia
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Center(
                child: _mockStoryContent[_currentStoryIndex]['type'] == 'image'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.image(PhosphorIconsStyle.regular),
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _mockStoryContent[_currentStoryIndex]['content'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB21132),
                              Colors.purple,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _mockStoryContent[_currentStoryIndex]['content'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),

            // Barra de progreso
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(_totalStories, (index) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: index < _currentStoryIndex
                          ? Container(color: Colors.white)
                          : index == _currentStoryIndex
                              ? AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    return LinearProgressIndicator(
                                      value: _progressController.value,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                    ),
                  );
                }),
              ),
            ),

            // Header con avatar y nombre
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[600],
                    child: Text(
                      widget.username[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _mockStoryContent[_currentStoryIndex]['time'],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Botón de mensaje
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Enviar mensaje...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
