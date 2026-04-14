import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar con título y acciones
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: isCurrentUser ? null : IconButton(
                icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  if (user.esPremium) ...[
                    const SizedBox(width: 4),
                    Icon(
                      PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                      color: const Color(0xFFB21132),
                      size: 18,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    PhosphorIcons.shareFat(PhosphorIconsStyle.bold),
                    color: Colors.black,
                  ),
                  onPressed: () => _showShareProfileModal(context, user),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIcons.list(PhosphorIconsStyle.bold),
                    color: Colors.black,
                  ),
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

            // Indicador de comunidades
            SliverToBoxAdapter(
              child: _buildCommunitiesIndicator(user),
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
            _buildPostsGrid(user),
            _buildCommunitiesList(user),
            _buildSharedPosts(user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar simplificado
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: user.esPremium ? const Color(0xFFB21132) : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 43,
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB21132),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Info de usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${user.email.split('@').first.toLowerCase()}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (user.esPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB21132).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.crown(PhosphorIconsStyle.fill),
                          size: 12,
                          color: const Color(0xFFB21132),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Premium',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB21132),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!user.puedeCrearComunidad && !user.esPremium)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/submit_attendance'),
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
                            size: 10,
                            color: Colors.orange[800],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${6 - (user.asistenciasVerificadas ?? 0)} asistencias para comunidades',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn(
            user.seguidosCount?.toString() ?? '0',
            'Siguiendo',
            () => _showFollowersList(context, 'Siguiendo'),
          ),
          _buildStatColumn(
            user.seguidoresCount?.toString() ?? '0',
            'Seguidores',
            () => _showFollowersList(context, 'Seguidores'),
          ),
          _buildStatColumn(
            '0',
            'Me gusta',
            () {},
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isCurrentUser) ...[
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                ),
                icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 16),
                label: const Text(
                  'Editar perfil',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Icon(PhosphorIcons.userPlus(PhosphorIconsStyle.bold), size: 16),
              ),
            ),
          ] else ...[
            Expanded(
              flex: 4,
              child: _isFollowing
                  ? OutlinedButton(
                      onPressed: () => setState(() => _isFollowing = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Siguiendo',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => setState(() => _isFollowing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB21132),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Seguir',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunitiesIndicator(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${user.comunidadesCount ?? 0} comunidades',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          if (!user.puedeCrearComunidad && !user.esPremium)
            GestureDetector(
              onTap: () => _showUpgradeToPremiumDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Obtener Premium',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(User user) {
    final List<Map<String, dynamic>> mockPosts = [];

    if (mockPosts.isEmpty) {
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
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        final post = mockPosts[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.grey[200],
            child: Stack(
              fit: StackFit.expand,
              children: [
                post['hasImage']
                    ? Container(
                        color: Colors.grey[300],
                        child: Icon(
                          PhosphorIcons.image(PhosphorIconsStyle.regular),
                          color: Colors.grey[500],
                          size: 32,
                        ),
                      )
                    : Container(
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            'Post de texto...',
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
                          '${post['likes']}',
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
                          '${post['comments']}',
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

  Widget _buildCommunitiesList(User user) {
    final mockCommunities = [];

    if (mockCommunities.isEmpty) {
      return _buildEmptyState(
        icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
        title: 'Aún no hay comunidades',
        subtitle: 'Únete o crea una comunidad',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockCommunities.length,
      itemBuilder: (context, index) {
        final community = mockCommunities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(community['color'] as int),
              child: Text(
                (community['name'] as String).substring(0, 1),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              community['name'] as String,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              community['role'] as String,
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
          ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text('U$index'),
                        ),
                        title: Text('Usuario $index'),
                        subtitle: Text('@usuario$index'),
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Fondo semitransparente para cerrar al tocar fuera
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Drawer lateral
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-300 * (1 - animation.value), 0),
                  child: child,
                );
              },
              child: Container(
                width: 300,
                height: double.infinity,
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con info del usuario
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFB21132),
                              Color(0xFFD32F5A),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  PhosphorIcons.user(PhosphorIconsStyle.fill),
                                  color: const Color(0xFFB21132),
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.nombre ?? 'Usuario',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      
                      // Título Configuración
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          'Configuración',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      
                      // Opciones del menú
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.userCircle(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Editar perfil',
                              subtitle: 'Modifica tu información',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                                color: Colors.red,
                                size: 24,
                              ),
                              title: 'Cerrar sesión',
                              subtitle: 'Salir de tu cuenta',
                              color: Colors.red,
                              onTap: () {
                                Navigator.pop(context);
                                _showLogoutDialog(context);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.bell(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Notificaciones',
                              subtitle: 'Gestiona tus notificaciones',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.shield(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Privacidad',
                              subtitle: 'Controla tu privacidad',
                              onTap: () {
                                Navigator.pop(context);
                                _showPrivacyDialog(context);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.notepad(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Términos y Condiciones',
                              subtitle: 'Lee nuestros términos',
                              onTap: () {
                                Navigator.pop(context);
                                _showTermsDialog(context);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.info(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Acerca de',
                              subtitle: 'Información de la app',
                              onTap: () {
                                Navigator.pop(context);
                                _showAboutDialog(context);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildDrawerItem(
                              icon: Icon(
                                PhosphorIcons.question(PhosphorIconsStyle.bold),
                                color: const Color(0xFFB21132),
                                size: 24,
                              ),
                              title: 'Ayuda',
                              subtitle: 'Preguntas frecuentes',
                              onTap: () {
                                Navigator.pop(context);
                                _showHelpDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Footer sin línea amarilla
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Comunidades UTP v1.0.0',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFFB21132),
    bool isAdmin = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isAdmin ? const Color(0xFFB21132) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: icon),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isAdmin ? const Color(0xFFB21132) : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        trailing: isAdmin
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
        onTap: onTap,
      ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comunidades UTP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('Versión 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Una plataforma para estudiantes de UTP donde puedes compartir experiencias, conectar con otros estudiantes e intercambiar información.',
              ),
              SizedBox(height: 16),
              Text(
                '© 2024 UTP. Todos los derechos reservados.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacidad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Controla quién puede ver tu perfil y tus publicaciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Perfil Público'),
                subtitle: const Text('Cualquiera puede ver tu perfil'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Publicaciones Públicas'),
                subtitle: const Text('Todos pueden ver tus posts'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Permitir Mensajes'),
                subtitle: const Text('Otros usuarios pueden contactarte'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Bloqueados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('No tienes usuarios bloqueados'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '1. Aceptación de Términos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Al usar Comunidades UTP, aceptas estos términos y condiciones.',
              ),
              SizedBox(height: 16),
              Text(
                '2. Comportamiento del Usuario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'No debes crear contenido ofensivo, discriminatorio o que viole los derechos de terceros.',
              ),
              SizedBox(height: 16),
              Text(
                '3. Responsabilidad',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'El usuario es responsable de todo contenido que publique en la plataforma.',
              ),
              SizedBox(height: 16),
              Text(
                '4. Privacidad',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tu información será protegida de acuerdo con nuestra política de privacidad.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preguntas Frecuentes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '¿Cómo crear una comunidad?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ve a la sección de Comunidades y selecciona "Crear Comunidad". Completa los detalles y listo.',
              ),
              SizedBox(height: 16),
              Text(
                '¿Cómo hacer una publicación?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Presiona el botón "+" en la barra de navegación inferior para crear un nuevo post.',
              ),
              SizedBox(height: 16),
              Text(
                '¿Cómo seguir a usuarios?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Visita el perfil del usuario y presiona el botón "Seguir".',
              ),
              SizedBox(height: 16),
              Text(
                '¿Cómo reportar contenido?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Presiona los tres puntos en cualquier post o perfil y selecciona "Reportar".',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
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
