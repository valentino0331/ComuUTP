import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.colorSurface,
        elevation: 0,
        title: Text(
          'Comunidades',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.colorTextPrimary,
                fontSize: AppTheme.fontSizeMd,
              ),
        ),
        toolbarHeight: 56,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.colorBorder,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _updateFilteredCommunities(),
              decoration: InputDecoration(
                hintText: 'Buscar comunidades...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilteredCommunities();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.colorBorder),
                ),
                filled: true,
                fillColor: AppTheme.colorSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: _filters
                    .map((filter) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                            },
                            backgroundColor: AppTheme.colorSurface,
                            selectedColor: AppTheme.colorPrimary
                                .withOpacity(0.2),
                            side: BorderSide(
                              color: _selectedFilter == filter
                                  ? AppTheme.colorPrimary
                                  : AppTheme.colorBorder,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Grid de comunidades
          Expanded(
            child: Consumer<CommunityProvider>(
              builder: (context, communityProvider, _) {
                if (communityProvider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.colorPrimary),
                    ),
                  );
                }

                if (communityProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar comunidades',
                          style: TextStyle(
                            color: AppTheme.colorTextSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              communityProvider.fetchCommunities(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.colorPrimary,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredCommunities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 64,
                          color: AppTheme.colorTextSecondary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No hay comunidades disponibles'
                              : 'No se encontraron comunidades',
                          style: TextStyle(
                            color: AppTheme.colorTextSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredCommunities.length,
                    itemBuilder: (context, index) {
                      final community = _filteredCommunities[index];
                      return CommunityCardGrid(community: community);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityCardGrid extends StatelessWidget {
  final Community community;

  const CommunityCardGrid({
    super.key,
    required this.community,
  });

  Color _getColorForCommunity(int index) {
    final colors = [
      AppTheme.colorIconSistemas,      // Rojo
      AppTheme.colorIconFutbol,         // Azul marino
      AppTheme.colorIconHacks,          // Verde
      AppTheme.colorIconArequipa,       // Rojo claro
    ];
    return colors[index % colors.length];
  }

  IconData _getIconForCommunity(int index) {
    final icons = [
      Icons.computer,
      Icons.sports_soccer,
      Icons.emoji_events,
      Icons.location_city,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono de comunidad circular
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getColorForCommunity(community.id),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getColorForCommunity(community.id).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconForCommunity(community.id),
                color: AppTheme.colorTextWhite,
                size: 36,
              ),
            ),
          ),

          // Nombre de comunidad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              community.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeSm,
                fontWeight: FontWeight.w700,
                color: AppTheme.colorTextPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // Miembros
          Text(
            '👥 ${(community.id * 30 + 81)} miembros',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXs,
              color: AppTheme.colorTextSecondary,
            ),
          ),

          const Spacer(),

          // Botón Unirse
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Provider.of<CommunityProvider>(context, listen: false)
                        .joinCommunity(community.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Te uniste a ${community.nombre}'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.colorPrimary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Unirse',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colorPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
