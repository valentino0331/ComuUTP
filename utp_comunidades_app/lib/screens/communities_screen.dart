import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import './create_community_screen.dart';
import './community_members_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  final List<Community> communities;
  const CommunitiesScreen({super.key, required this.communities});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  late TextEditingController _searchController;
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';
    final allCommunities = widget.communities;
    
    final filteredCommunities = allCommunities.where((c) {
      if (c.esMiembro != true) return false;
      if (_searchController.text.isNotEmpty && 
          !c.nombre.toLowerCase().contains(_searchController.text.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Comunidades',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: filteredCommunities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    itemCount: filteredCommunities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCommunityCard(filteredCommunities[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showCreateCommunity,
              label: const Text(
                'Nueva',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 22),
              backgroundColor: AppTheme.colorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar comunidades...',
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF846B70).withOpacity(0.8),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 14),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Todas',
                'Académica',
                'Deporte',
                'Tecnología',
                'Arte y Cultura',
              ].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF474545) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected ? null : Border.all(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(Community community) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF846B70).withOpacity(0.37),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    community.nombre.isNotEmpty ? community.nombre[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFFB21132),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.nombre,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Comunidad',
                      style: TextStyle(
                        color: Color(0xFF846B70),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            community.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF846B70),
              fontSize: 13,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(PhosphorIconsRegular.users, size: 14, color: Color(0xFF846B70).withOpacity(0.8)),
              const SizedBox(width: 4),
              Text(
                'Por: Comunidad',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF846B70),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCommunityButton(context, community),
        ],
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, Community community) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Provider.of<CommunityProvider>(context, listen: false).joinCommunity(community.id);
        if (!context.mounted) return;
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text('¡Te uniste!', style: TextStyle(fontFamily: 'Montserrat')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error', style: TextStyle(fontFamily: 'Montserrat')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB21132),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(62, 21),
        elevation: 0,
      ),
      child: const Text(
        'Unirse',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCommunityButton(BuildContext context, Community community) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final isCreator = community.usuarioCreadorId != null && community.usuarioCreadorId == currentUserId;
    final isMember = community.esMiembro ?? false;

    if (isCreator) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: const Text(
              'Administrador',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          _buildMembersButton(context, community),
          _buildDeleteCommunityButton(context, community),
        ],
      );
    }

    if (isMember) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildMembersButton(context, community),
          _buildLeaveCommunityButton(context, community),
        ],
      );
    }

    return _buildJoinButton(context, community);
  }

  Widget _buildMembersButton(BuildContext context, Community community) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityMembersScreen(community: community),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFFB21132).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFB21132), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.fill), size: 12, color: Color(0xFFB21132)),
            const SizedBox(width: 4),
            const Text(
              'Ver Miembros',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB21132),
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCommunityButton(BuildContext context, Community community) {
    return GestureDetector(
      onTap: () async {
        final confirmLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Salir de comunidad', style: TextStyle(fontFamily: 'Montserrat')),
            content: Text(
              '¿Estás seguro de que quieres salir de ${community.nombre}?',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir', style: TextStyle(color: Colors.red, fontFamily: 'Montserrat')),
              ),
            ],
          ),
        );

        if (confirmLeave == true && context.mounted) {
          final result = await Provider.of<CommunityProvider>(context, listen: false).leaveCommunity(community.id);
          if (!context.mounted) return;

          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    const Text('Saliste de la comunidad', style: TextStyle(fontFamily: 'Montserrat')),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
            setState(() {});
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.signOut(PhosphorIconsStyle.fill), size: 12, color: Colors.red),
            const SizedBox(width: 4),
            const Text(
              'Salir',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteCommunityButton(BuildContext context, Community community) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => _buildModernDeleteDialog(
            title: '¿Eliminar comunidad?',
            message: '"${community.nombre}" se eliminará permanentemente junto con todas sus publicaciones.',
            confirmText: 'Eliminar',
          ),
        );

        if (confirmed == true && context.mounted) {
          final result = await Provider.of<CommunityProvider>(context, listen: false).deleteCommunity(community.id);
          if (!context.mounted) return;

          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Text('Comunidad eliminada', style: TextStyle(fontFamily: 'Montserrat')),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Error al eliminar comunidad', style: TextStyle(fontFamily: 'Montserrat')),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.trash(PhosphorIconsStyle.fill), size: 12, color: Colors.red),
            const SizedBox(width: 4),
            const Text(
              'Eliminar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsRegular.usersThree, size: 64, color: AppTheme.colorTextSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No se encontraron comunidades',
            style: TextStyle(color: AppTheme.colorTextSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDeleteDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return Dialog(
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
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
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
                    child: Text(
                      confirmText,
                      style: const TextStyle(
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
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Acadmica': return PhosphorIconsRegular.bookOpen;
      case 'Deportes': return PhosphorIconsRegular.basketball;
      case 'Tecnologa': return PhosphorIconsRegular.cpu;
      case 'Arte': return PhosphorIconsRegular.palette;
      default: return PhosphorIconsRegular.users;
    }
  }
}
