import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../models/community.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/community_provider.dart';
import '../providers/follower_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final currentUser = context.watch<AuthProvider>().user;
    final isCurrentUser = currentUser?.id == user.id;
    final postProvider = context.watch<PostProvider>();
    final communityProvider = context.watch<CommunityProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar con título y acciones
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: const Color(0xFFB21132),
              elevation: 0,
              leading: null,
              automaticallyImplyLeading: false,
              title: const Text(
                'Mi Perfil',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    PhosphorIcons.shareFat(PhosphorIconsStyle.bold),
                    color: Colors.white,
                  ),
                  onPressed: () => _showShareProfileModal(context, user),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIcons.list(PhosphorIconsStyle.bold),
                    color: Colors.white,
                  ),
                  tooltip: 'Menú de usuario',
                  onPressed: () => _showSettingsMenu(context),
                ),
              ],
            ),

            // Info del perfil
            SliverToBoxAdapter(
              child: _buildProfileHeader(user, isCurrentUser),
            ),

            // Stats (Seguidos, Seguidores, Me gusta)
            SliverToBoxAdapter(
              child: _buildStatsRow(user),
            ),

            // Biografía
            SliverToBoxAdapter(
              child: _buildBioSection(user),
            ),

            // Botones de acción (Editar perfil / Seguir)
            SliverToBoxAdapter(
              child: _buildActionButtons(user, isCurrentUser),
            ),

            // TabBar (Posts / Comunidades / Compartidos)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[500],
                  tabs: [
                    Tab(
                      icon: Icon(
                        PhosphorIcons.squaresFour(PhosphorIconsStyle.bold),
                        size: 24,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
                        size: 24,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(context, user, postProvider),
            _buildCommunitiesList(context, user, communityProvider),
            _buildSharedPosts(user),
          ],
        ),
      ),
        ),
    );
  }

  Widget _buildProfileHeader(User user, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Avatar mejorado
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: user.esPremium ? const Color(0xFFB21132) : Colors.transparent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[200],
              backgroundImage: user.fotoPerfil != null
                  ? NetworkImage(user.fotoPerfil!)
                  : null,
              child: user.fotoPerfil == null
                  ? Text(
                      user.nombre.isNotEmpty
                          ? user.nombre[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB21132),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          // User info
          Column(
            children: [
              // Nombre - más grande y prominente
              Text(
                user.nombre,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Username/Email
              Text(
                '@${user.email.split('@').first.toLowerCase()}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              // Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.esPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFB21132).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.crown(PhosphorIconsStyle.fill),
                            size: 14,
                            color: const Color(0xFFB21132),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Premium',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB21132),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              user.seguidosCount?.toString() ?? '0',
              'Siguiendo',
              () => _showFollowersList(context, 'Siguiendo'),
            ),
            Container(width: 1, height: 40, color: Colors.grey[200]),
            _buildStatColumn(
              user.seguidoresCount?.toString() ?? '0',
              'Seguidores',
              () => _showFollowersList(context, 'Seguidores'),
            ),
            Container(width: 1, height: 40, color: Colors.grey[200]),
            _buildStatColumn(
              '0',
              'Me gusta',
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.biografia != null && user.biografia!.isNotEmpty)
            Text(
              user.biografia!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 8),
          // Intereses/Tags
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              '🎸 Rock',
              '🎨 Arte',
              '🎵 Música',
            ].map((interest) {
              return Chip(
                label: Text(
                  interest,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                  ),
                ),
                backgroundColor: Colors.grey[100],
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User user, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          if (isCurrentUser)
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB21132), width: 2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          size: 18,
                          color: const Color(0xFFB21132),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Editar perfil',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFFB21132),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else ...[
            Expanded(
              flex: 4,
              child: !_isFollowing
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFB21132),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB21132).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _isFollowing = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ahora sigues a este usuario'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Center(
                            child: Text(
                              'Seguir',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _isFollowing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Has dejado de seguir a este usuario'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Center(
                            child: Text(
                              'Siguiendo',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidad de mensajes directos próximamente'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.userPlus(PhosphorIconsStyle.bold),
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsGrid(BuildContext context, User user, PostProvider postProvider) {
    final posts = postProvider.posts.where((p) => p.usuarioId == user.id).toList();
    if (postProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return _buildEmptyState(
        icon: PhosphorIcons.camera(PhosphorIconsStyle.bold),
        title: 'Aún no hay publicaciones',
        subtitle: '¡Empieza a compartir tus ideas!',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/post_detail', arguments: post);
          },
          child: Container(
            color: Colors.grey[200],
            child: Stack(
              fit: StackFit.expand,
              children: [
                (post.contenido.isNotEmpty && post.contenido.startsWith('http'))
                    ? post.contenido.startsWith('data:')
                        ? Image.memory(
                            base64Decode(post.contenido.split(',')[1]),
                            fit: BoxFit.cover,
                          )
                        : Image.network(post.contenido, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            post.contenido,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.heart(PhosphorIconsStyle.fill),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes ?? 0}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.chatCircleText(PhosphorIconsStyle.fill),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comentarios ?? 0}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunitiesList(BuildContext context, User user, CommunityProvider communityProvider) {
    return FutureBuilder<List<Community>>(
      future: communityProvider.getMyCommunities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: PhosphorIcons.warning(PhosphorIconsStyle.bold),
            title: 'Error al cargar',
            subtitle: 'No se pudieron cargar tus comunidades',
          );
        }

        final communities = snapshot.data ?? [];
        
        if (communities.isEmpty) {
          return _buildEmptyState(
            icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
            title: 'Aún no hay comunidades',
            subtitle: 'Únete o crea una comunidad',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  child: Text(
                    community.nombre.isNotEmpty ? community.nombre[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  community.nombre,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Miembro',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/community_detail', arguments: community);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSharedPosts(User user) {
    return _buildEmptyState(
      icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
      title: 'Aún no hay compartidos',
      subtitle: 'Los posts que compartas aparecerán aquí',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFollowersList(BuildContext context, String type) {
    final followerProvider = Provider.of<FollowerProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Cargar datos según el tipo
        if (type == 'Seguidores') {
          followerProvider.fetchFollowers(widget.user.id);
        } else {
          followerProvider.fetchFollowing(widget.user.id);
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<FollowerProvider>(
                      builder: (context, provider, _) {
                        if (provider.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final list = type == 'Seguidores' 
                            ? provider.followers 
                            : provider.following;

                        if (list.isEmpty) {
                          return _buildEmptyState(
                            icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                            title: 'Sin $type',
                            subtitle: 'Aún no hay $type',
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final follower = list[index];
                            final nombre = type == 'Seguidores'
                                ? follower.seguidorNombre
                                : follower.seguidoNombre;
                            final fotoPerfil = type == 'Seguidores'
                                ? follower.seguidorFotoPerfil
                                : follower.seguidoFotoPerfil;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage: fotoPerfil != null
                                    ? NetworkImage(fotoPerfil)
                                    : null,
                                child: fotoPerfil == null
                                    ? Icon(PhosphorIcons.user(), color: Colors.grey[400],)
                                    : null,
                              ),
                              title: Text(
                                nombre ?? 'Usuario',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: const Text('Seguir'),
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
          },
        );
      },
    );
  }

  void _showShareProfileModal(BuildContext context, User user) {
    final shareUrl = 'https://utpcomunidades.app/u/${user.id}';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Perfil card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFB21132),
                    backgroundImage: user.fotoPerfil != null
                        ? NetworkImage(user.fotoPerfil!)
                        : null,
                    child: user.fotoPerfil == null
                        ? Text(
                            user.nombre.isNotEmpty
                                ? user.nombre[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.nombre,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '@${user.email.split('@').first.toLowerCase()}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copiado al portapapeles')),
                        );
                      },
                      icon: Icon(PhosphorIcons.link(PhosphorIconsStyle.bold)),
                      label: const Text('Copiar enlace'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abriendo opciones de compartir...')),
                        );
                      },
                      icon: Icon(PhosphorIcons.shareFat(PhosphorIconsStyle.bold)),
                      label: const Text('Compartir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB21132),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showUpgradeToPremiumDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Header con icono
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFB21132), Color(0xFFE83E8C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB21132).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.crown(PhosphorIconsStyle.fill),
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Premium',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloquea todo el potencial',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Features list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPremiumFeature('Crea comunidades ilimitadas', PhosphorIcons.usersThree(PhosphorIconsStyle.fill)),
                  const SizedBox(height: 12),
                  _buildPremiumFeature('Sin necesidad de asistencias', PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)),
                  const SizedBox(height: 12),
                  _buildPremiumFeature('Badge premium exclusivo', PhosphorIcons.seal(PhosphorIconsStyle.fill)),
                  const SizedBox(height: 12),
                  _buildPremiumFeature('Soporte prioritario', PhosphorIcons.headset(PhosphorIconsStyle.fill)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Plan cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildPremiumPlanCard2(
                    'Mensual',
                    'S/ 50.00',
                    '1 mes',
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumPlanCard2(
                    'Semestre',
                    'S/ 250.00',
                    '6 meses',
                    true,
                    originalPrice: 'S/ 300.00',
                    savings: 'Ahorra 17%',
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumPlanCard2(
                    'Anual',
                    'S/ 450.00',
                    '12 meses',
                    false,
                    originalPrice: 'S/ 600.00',
                    savings: 'Ahorra 25%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botón cerrar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'No, gracias',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFB21132),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumPlanCard2(
    String name,
    String price,
    String duration, 
    bool isRecommended, {
    String? originalPrice,
    String? savings,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended 
            ? const Color(0xFFB21132).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended 
              ? const Color(0xFFB21132)
              : Colors.white.withOpacity(0.1),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB21132),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'RECOMENDADO',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (isRecommended) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      duration,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (originalPrice != null)
                    Text(
                      originalPrice,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (savings != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        savings,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Plan $name seleccionado - Redirigiendo a pago...'),
                    backgroundColor: const Color(0xFFB21132),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended 
                    ? const Color(0xFFB21132)
                    : Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Seleccionar $name',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text(
                  'Configuración',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Contenido - Single child scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN: Cuenta
                      _buildSettingsSection(
                        title: 'Cuenta',
                        items: [
                          (
                            icon: PhosphorIcons.lock(PhosphorIconsStyle.bold),
                            title: 'Cambiar contraseña',
                            subtitle: 'Actualiza tu seguridad',
                            onTap: () {
                              Navigator.pop(context);
                              _showChangePasswordDialog(context);
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // SECCIÓN: Privacidad y Seguridad
                      _buildSettingsSection(
                        title: 'Privacidad y Seguridad',
                        items: [
                          (
                            icon: PhosphorIcons.shield(PhosphorIconsStyle.bold),
                            title: 'Privacidad',
                            subtitle: 'Controla quién te ve',
                            onTap: () {
                              Navigator.pop(context);
                              _showPrivacyDialog(context);
                            },
                          ),
                          (
                            icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.bold),
                            title: 'Autenticación',
                            subtitle: 'Autenticación de dos factores',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcionalidad próximamente'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),

                      // SECCIÓN: Administración (Solo visible para admins)
                      if (user?.role == 'admin') ...[
                        _buildSettingsSection(
                          title: 'Administración',
                          color: const Color(0xFFB21132),
                          items: [
                            (
                              icon: PhosphorIcons.userGear(PhosphorIconsStyle.bold),
                              title: 'Panel de Admin',
                              subtitle: 'Gestiona usuarios y comunidades',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/admin');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],
                      
                      // SECCIÓN: Información
                      _buildSettingsSection(
                        title: 'Información',
                        items: [
                          (
                            icon: PhosphorIcons.notepad(PhosphorIconsStyle.bold),
                            title: 'Términos y Condiciones',
                            subtitle: 'Lee nuestros términos',
                            onTap: () {
                              Navigator.pop(context);
                              _showTermsDialog(context);
                            },
                          ),
                          (
                            icon: PhosphorIcons.bookOpen(PhosphorIconsStyle.bold),
                            title: 'Política de Privacidad',
                            subtitle: 'Protegemos tus datos',
                            onTap: () {
                              Navigator.pop(context);
                              _showPrivacyDialog(context);
                            },
                          ),
                          (
                            icon: PhosphorIcons.question(PhosphorIconsStyle.bold),
                            title: 'Ayuda y Soporte',
                            subtitle: 'Preguntas frecuentes',
                            onTap: () {
                              Navigator.pop(context);
                              _showHelpDialog(context);
                            },
                          ),
                          (
                            icon: PhosphorIcons.info(PhosphorIconsStyle.bold),
                            title: 'Acerca de',
                            subtitle: 'Versión 1.0.0',
                            onTap: () {
                              Navigator.pop(context);
                              _showAboutDialog(context);
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // SECCIÓN: Peligro
                      _buildSettingsSection(
                        title: 'Peligro',
                        color: Colors.red,
                        items: [
                          (
                            icon: PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                            title: 'Cerrar sesión',
                            subtitle: 'Salir de tu cuenta',
                            onTap: () {
                              Navigator.pop(context);
                              _showLogoutDialog(context);
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<({
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    })> items,
    Color color = const Color(0xFFB21132),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: items[index].onTap,
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(11))
                          : index == items.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(11))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  items[index].icon,
                                  size: 22,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index].title,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    items[index].subtitle,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: Colors.grey[200],
                      indent: 76,
                      endIndent: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool _obscureCurrent = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

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
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFFB21132),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa tu contraseña actual y la nueva',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Campos de contraseña
                    _buildPasswordField(
                      controller: currentPasswordController,
                      label: 'Contraseña actual',
                      icon: Icons.lock_clock,
                      obscure: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: newPasswordController,
                      label: 'Nueva contraseña',
                      icon: Icons.lock_outline,
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'Confirmar contraseña',
                      icon: Icons.lock_person,
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 24),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB21132),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (newPasswordController.text != confirmPasswordController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Las contraseñas no coinciden'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    if (newPasswordController.text.length < 6) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Mínimo 6 caracteres'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isLoading = true);

                                    try {
                                      final user = firebase_auth.FirebaseAuth.instance.currentUser;
                                      if (user != null && user.email != null) {
                                        final credential = firebase_auth.EmailAuthProvider.credential(
                                          email: user.email!,
                                          password: currentPasswordController.text,
                                        );
                                        await user.reauthenticateWithCredential(credential);
                                        await user.updatePassword(newPasswordController.text);

                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Contraseña actualizada exitosamente'),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    } on firebase_auth.FirebaseAuthException catch (e) {
                                      if (!context.mounted) return;
                                      setState(() => isLoading = false);
                                      String errorMessage = 'Error al cambiar la contraseña';
                                      if (e.code == 'wrong-password') {
                                        errorMessage = 'Contraseña actual incorrecta';
                                      } else if (e.code == 'weak-password') {
                                        errorMessage = 'La contraseña es muy débil';
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Cambiar',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFB21132)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
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
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB21132), Color(0xFFD32F5A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.info(PhosphorIconsStyle.fill),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Comunidades UTP',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Versión 1.0.0',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB21132),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Acerca de',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Una plataforma revolucionaria para estudiantes de UTP donde puedes compartir experiencias, conectar con otros estudiantes, intercambiar información y construir comunidades sólidas.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Desarrollador',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'UTP Dev Team',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Última actualización',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Abril 2026',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '© 2024-2026 UTP. Todos los derechos reservados.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Privacidad y Seguridad',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Controla quién puede ver tu perfil y contenido',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuración de Perfil',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildPrivacySwitch(
                        title: 'Perfil Público',
                        subtitle: 'Cualquiera puede descubrir y ver tu perfil',
                        value: true,
                        onChanged: (v) => setState(() {}),
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _buildPrivacySwitch(
                        title: 'Publicaciones Públicas',
                        subtitle: 'Todos pueden ver tus posts y comentarios',
                        value: true,
                        onChanged: (v) => setState(() {}),
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _buildPrivacySwitch(
                        title: 'Permitir Mensajes',
                        subtitle: 'Otros usuarios pueden enviarte mensajes directos',
                        value: true,
                        onChanged: (v) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bloqueados',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      'No tienes usuarios bloqueados',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configuración de privacidad guardada'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB21132),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      activeColor: const Color(0xFFB21132),
      onChanged: onChanged,
    );
  }

  void _showTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildTermSection(
                title: '1. Aceptación de Términos',
                content: 'Al usar Comunidades UTP, aceptas completamente estos términos y condiciones. Si no estás de acuerdo, por favor no utilices la plataforma.',
              ),
              _buildTermSection(
                title: '2. Comportamiento del Usuario',
                content: 'No debes crear contenido ofensivo, discriminatorio, ilegal o que viole los derechos de terceros. Somos tolerantes cero con el acoso y el abuso.',
              ),
              _buildTermSection(
                title: '3. Responsabilidad',
                content: 'Eres responsable de todo contenido que publiques. No nos hacemos responsables por daños causados por tu uso de la plataforma.',
              ),
              _buildTermSection(
                title: '4. Privacidad',
                content: 'Tu información será protegida y procesada de acuerdo con nuestra política de privacidad. Solo usamos tus datos para mejorar tu experiencia.',
              ),
              _buildTermSection(
                title: '5. Cambios en los Términos',
                content: 'Nos reservamos el derecho de modificar estos términos. Te notificaremos sobre cambios importantes mediante la aplicación.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB21132),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Preguntas Frecuentes',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildFAQItem(
                title: '¿Cómo crear una comunidad?',
                content: 'Ve a la sección de Comunidades, presiona el botón "+" y completa los detalles de tu comunidad. Elige un nombre único, descripción y foto de portada.',
                icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
              ),
              _buildFAQItem(
                title: '¿Cómo hacer una publicación?',
                content: 'Presiona el botón "+" en la barra de navegación inferior. Escribe tu contenido, agrega fotos, videos o enlaces, y presiona "Publicar".',
                icon: PhosphorIcons.pencil(PhosphorIconsStyle.bold),
              ),
              _buildFAQItem(
                title: '¿Cómo seguir a usuarios?',
                content: 'Visita el perfil del usuario que deseas seguir y presiona el botón "Seguir". Verás sus publicaciones en tu feed.',
                icon: PhosphorIcons.userPlus(PhosphorIconsStyle.bold),
              ),
              _buildFAQItem(
                title: '¿Cómo reportar contenido?',
                content: 'Presiona los tres puntos en cualquier publicación o perfil, selecciona "Reportar" y describe el problema. Nuestro equipo lo revisará rápidamente.',
                icon: PhosphorIcons.flag(PhosphorIconsStyle.bold),
              ),
              _buildFAQItem(
                title: '¿Cómo cambiar mi privacidad?',
                content: 'En la configuración, selecciona "Privacidad y Seguridad" para controlar quién puede ver tu perfil, publicaciones y mensajes.',
                icon: PhosphorIcons.shield(PhosphorIconsStyle.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB21132).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.lightbulb(PhosphorIconsStyle.fill),
                      color: const Color(0xFFB21132),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¿Necesitas más ayuda? Contacta a soporte a través de la app o envía un correo a support@utp.edu.pe',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB21132).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFFB21132),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
