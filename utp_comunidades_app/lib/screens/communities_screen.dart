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
    // Mostrar botón si el usuario es admin
    final isAdmin = authProvider.user?.role == 'admin';

    // Filtrar SOLO comunidades reales donde el usuario es miembro
    final allCommunities = widget.communities;
    
    final filteredCommunities = allCommunities.where((c) {
      // Solo mostrar comunidades donde el usuario es miembro
      if (c.esMiembro != true) return false;
      // Filtro de búsqueda
      if (_searchController.text.isNotEmpty && 
          !c.nombre.toLowerCase().contains(_searchController.text.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Comunidades UTP'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: filteredCommunities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCommunities.length,
                    itemBuilder: (context, index) {
                      return _buildCommunityCard(filteredCommunities[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showCreateCommunity,
              label: const Text(
                'Crear Comunidad',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: AppTheme.colorPrimary,
            )
          : null,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar comunidades...',
              prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Todas',
                'Académica',
                'Deportes',
                'Tecnología',
                'Arte',
                'Social'
              ].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                    selectedColor: AppTheme.colorPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.colorTextPrimary,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar a detalles
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      // _getCategoryIcon(community.categoria),
                      PhosphorIconsRegular.users,
                      color: AppTheme.colorPrimary,
                      size: 24,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Comunidad',
                          style: TextStyle(
                            color: AppTheme.colorTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.users, size: 14),
                        const SizedBox(width: 4),
                        Text(''),
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
                style: TextStyle(color: AppTheme.colorTextSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Por: Comunidad',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Flexible(
                    child: _buildCommunityButton(context, community),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityButton(BuildContext context, Community community) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final isCreator = community.usuarioCreadorId != null && community.usuarioCreadorId == currentUserId;
    final isMember = community.esMiembro ?? false;

    print('Community: ${community.nombre}, creatorId: ${community.usuarioCreadorId}, currentId: $currentUserId, isCreator: $isCreator, isMember: $isMember, esMiembroRaw: ${community.esMiembro}');

    if (isCreator) {
      return Wrap(
        spacing: 8,
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
        children: [
          _buildMembersButton(context, community),
          GestureDetector(
            onTap: () async {
              final confirmLeave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Salir de comunidad'),
                  content: Text('¿Estás seguro de que quieres salir de ${community.nombre}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Salir', style: TextStyle(color: Colors.red)),
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
                          Icon(
                            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text('Saliste de la comunidad'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al salir de la comunidad'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
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
                  Icon(PhosphorIcons.signOut(PhosphorIconsStyle.fill), size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

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
                  const Text('¡Te uniste a la comunidad!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al unirse a la comunidad'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.colorPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Unirse'),
    );
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
          color: const Color(0xFFB21132).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB21132), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.fill), size: 14, color: const Color(0xFFB21132)),
            const SizedBox(width: 4),
            const Text(
              'Ver Miembros',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB21132),
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
          builder: (context) => AlertDialog(
            title: const Text(
              'Eliminar comunidad',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${community.nombre}"? Esta acción no se puede deshacer.',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Montserrat'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // TODO: Call API to delete community
          // await ApiService.delete('/communities/${community.id}', auth: true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Comunidad "${community.nombre}" eliminada',
                    style: const TextStyle(fontFamily: 'Montserrat'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
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
            Icon(PhosphorIcons.trash(PhosphorIconsStyle.fill), size: 14, color: Colors.red),
            const SizedBox(width: 4),
            const Text(
              'Eliminar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Acad�mica': return PhosphorIconsRegular.bookOpen;
      case 'Deportes': return PhosphorIconsRegular.basketball;
      case 'Tecnolog�a': return PhosphorIconsRegular.cpu;
      case 'Arte': return PhosphorIconsRegular.palette;
      default: return PhosphorIconsRegular.users;
    }
  }
}
