// filepath: utp_comunidades_app/lib/screens/ligas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/liga_provider.dart';
import '../providers/community_provider.dart';
import 'ranking_screen.dart';
import 'duelo_screen.dart';

class LigasScreen extends StatefulWidget {
  const LigasScreen({super.key});

  @override
  State<LigasScreen> createState() => _LigasScreenState();
}

class _LigasScreenState extends State<LigasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LigaProvider>(context, listen: false).fetchLigas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligas de Conocimiento'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.colorSecondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(PhosphorIcons.swordLight), text: 'Ligas'),
            Tab(icon: Icon(PhosphorIcons.trophyLight), text: 'Mi Ranking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LigasListView(),
          RankingScreen(),
        ],
      ),
    );
  }
}

class _LigasListView extends StatelessWidget {
  const _LigasListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<LigaProvider>(
      builder: (context, ligaProvider, _) {
        if (ligaProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ligaProvider.ligas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.smileyXFill,
                  size: 64,
                  color: AppTheme.colorSecondary,
                ),
                const SizedBox(height: 16),
                const Text('No hay ligas disponibles'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ligaProvider.fetchLigas();
                  },
                  child: const Text('Recargar'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ligaProvider.ligas.length,
          itemBuilder: (context, index) {
            final liga = ligaProvider.ligas[index];
            return _LigaCard(liga: liga);
          },
        );
      },
    );
  }
}

class _LigaCard extends StatelessWidget {
  final Liga;

  const _LigaCard({required this.Liga});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _showLigaDetails(context, Liga),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientPrimaryToCyan,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colorPrimary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decoración de fondo
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Liga.nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (Liga.descripcion != null)
                                Text(
                                  Liga.descripcion!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Liga.tipo == '1v1'
                                ? PhosphorIcons.swordLight
                                : PhosphorIcons.trophyLight,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Estado y participantes
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            Liga.estado.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.playLight,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Jugar Ahora',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  void _showLigaDetails(BuildContext context, liga) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liga.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (liga.descripcion != null)
                    Text(
                      liga.descripcion!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _buscarOponente(context, liga);
                      },
                      icon: const Icon(PhosphorIcons.swordLight),
                      label: const Text('Desafiar Rival'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Ir a ranking
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Ranking de Liga'),
                            content: Text('${liga.nombre} - Por implementar'),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(PhosphorIcons.trophyLight),
                      label: const Text('Ver Ranking'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buscarOponente(BuildContext context, liga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Oponente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlassLight),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    child: Text('U${index + 1}'),
                  ),
                  title: Text('Usuario ${index + 1}'),
                  subtitle: const Text('150 puntos'),
                  onTap: () {
                    Navigator.pop(context);
                    // Iniciar duelo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DueloScreen(
                          dueloId: index + 1,
                          opponentName: 'Usuario ${index + 1}',
                          tema: liga.nombre,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
