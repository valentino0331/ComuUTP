import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';

class CommunitiesScreen extends StatefulWidget {
  final List<Community> communities;
  const CommunitiesScreen({super.key, required this.communities});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  late TextEditingController _searchController;
  String _selectedFilter = 'Todas';
  List<Community> _filteredCommunities = [];

  final List<String> _filters = [
    'Todas',
    'Académica',
    'Deportes',
    'Arte y Cultura',
    'Tecnología',
    'Ocio',
    'Negocios',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _updateFilteredCommunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredCommunities() {
    final allCommunities =
        Provider.of<CommunityProvider>(context, listen: false).communities;
    setState(() {
      _filteredCommunities = allCommunities
          .where((community) =>
              community.nombre
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              community.descripcion
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final communities = Provider.of<CommunityProvider>(context).communities;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            
            // Filter Chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            
            // Communities Grid
            _buildCommunitiesGrid(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFB21132),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Comunidades',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _updateFilteredCommunities(),
          decoration: InputDecoration(
            hintText: 'Buscar comunidades',
            hintStyle: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
              color: Colors.grey[400],
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      PhosphorIcons.x(PhosphorIconsStyle.regular),
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _updateFilteredCommunities();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF474545),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF474545) 
                      : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCommunitiesGrid() {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, _) {
        if (communityProvider.loading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFB21132),
                ),
              ),
            ),
          );
        }

        if (communityProvider.error != null) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              title: 'Error al cargar comunidades',
              subtitle: 'Intenta nuevamente más tarde',
              showButton: true,
              buttonText: 'Reintentar',
              onButtonPressed: () => communityProvider.fetchCommunities(),
            ),
          );
        }

        if (_filteredCommunities.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
              title: 'No hay comunidades',
              subtitle: _searchController.text.isEmpty 
                  ? 'Sé el primero en crear una comunidad'
                  : 'No se encontraron resultados',
              showButton: true,
              buttonText: 'Crear comunidad',
              onButtonPressed: () => Navigator.of(context).pushNamed('/create_community'),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final community = _filteredCommunities[index];
                return _buildCommunityCard(community);
              },
              childCount: _filteredCommunities.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
    String buttonText = '',
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
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
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: Icon(
                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                color: Colors.white,
              ),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB21132),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunityCard(Community community) {
    final colors = [
      const Color(0xFFB21132),    // Rojo
      const Color(0xFF1E3A8A),    // Azul
      const Color(0xFF059669),    // Verde
      const Color(0xFF7C3AED),    // Morado
    ];
    final icons = [
      PhosphorIcons.desktop(PhosphorIconsStyle.fill),
      PhosphorIcons.soccerBall(PhosphorIconsStyle.fill),
      PhosphorIcons.trophy(PhosphorIconsStyle.fill),
      PhosphorIcons.building(PhosphorIconsStyle.fill),
    ];
    
    final color = colors[community.id % colors.length];
    final icon = icons[community.id % icons.length];

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono circular
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              community.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Miembros
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.users(PhosphorIconsStyle.regular),
                size: 14,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                '${(community.id * 30 + 81)} miembros',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botón Unirse
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Provider.of<CommunityProvider>(context, listen: false)
                      .joinCommunity(community.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Te uniste a ${community.nombre}'),
                      backgroundColor: const Color(0xFFB21132),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFB21132),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Unirse',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB21132),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushNamed('/create_community'),
      icon: const Icon(Icons.add),
      label: const Text('Nueva'),
      backgroundColor: const Color(0xFFB21132),
      foregroundColor: Colors.white,
    );
  }
}
