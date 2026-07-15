// filepath: utp_comunidades_app/lib/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  final int? ligaId;

  const RankingScreen({super.key, this.ligaId});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.ligaId != null) {
        Provider.of<RankingProvider>(context, listen: false)
            .fetchRankingLiga(widget.ligaId!);
      } else {
        Provider.of<RankingProvider>(context, listen: false).fetchRankingGeneral();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingProvider>(
      builder: (context, rankingProvider, _) {
        if (rankingProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (rankingProvider.ranking.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.trophyFill,
                  size: 64,
                  color: AppTheme.colorSecondary,
                ),
                const SizedBox(height: 16),
                const Text('Sin datos de ranking'),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Fondo gradiente
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimaryToCyan,
              ),
            ),
            // Contenido
            CustomScrollView(
              slivers: [
                // Mi posición (destacada al inicio)
                if (rankingProvider.miPosicion != null)
                  SliverToBoxAdapter(
                    child: _buildMiPosicion(rankingProvider.miPosicion!),
                  ),
                // Ranking list
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final usuario = rankingProvider.ranking[index];
                        final isMio = index == 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RankingItemWidget(
                            usuario: usuario,
                            index: index,
                            isMio: isMio,
                          ),
                        );
                      },
                      childCount: rankingProvider.ranking.length,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiPosicion(usuario) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colorAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.starFill,
                    color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tu Posición',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '#${usuario.posicion}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Posición',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${usuario.puntosTotales}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Puntos',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${usuario.duelosGanados}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Victorias',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingItemWidget extends StatelessWidget {
  final usuario;
  final int index;
  final bool isMio;

  const _RankingItemWidget({
    required this.usuario,
    required this.index,
    required this.isMio,
  });

  @override
  Widget build(BuildContext context) {
    final posicion = usuario.posicion;
    Color getColorPosicion() {
      if (posicion == 1) return const Color(0xFFFFD700); // Oro
      if (posicion == 2) return const Color(0xFFC0C0C0); // Plata
      if (posicion == 3) return const Color(0xFFCD7F32); // Bronce
      return AppTheme.colorSecondary;
    }

    String getMedal() {
      if (posicion == 1) return '🥇';
      if (posicion == 2) return '🥈';
      if (posicion == 3) return '🥉';
      return '';
    }

    return Container(
      decoration: BoxDecoration(
        color: isMio ? Colors.white.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMio
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Posición / Medal
            if (getMedal().isNotEmpty)
              Text(
                getMedal(),
                style: const TextStyle(fontSize: 28),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.colorPrimaryLight.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '#${posicion}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.colorPrimary,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // Avatar y nombre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isMio ? Colors.white : AppTheme.colorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.swordLight,
                        size: 12,
                        color: isMio ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${usuario.duelosJugados} duelos',
                        style: TextStyle(
                          fontSize: 11,
                          color: isMio ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        PhosphorIcons.checkLight,
                        size: 12,
                        color: isMio ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${usuario.duelosGanados}W',
                        style: TextStyle(
                          fontSize: 11,
                          color: isMio ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Puntos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getColorPosicion().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${usuario.puntosTotales} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: getColorPosicion(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
