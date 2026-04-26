import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';
import '../screens/community_detail_screen.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap;
  const CommunityCard({super.key, required this.community, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityDetailScreen(community: community),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.colorPrimary,
                        AppTheme.colorPrimary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.colorPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      community.nombre.isNotEmpty
                          ? community.nombre[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        community.descripcion,
                        style: TextStyle(
                          color: AppTheme.colorTextSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (community.miembros != null || community.posts != null)
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: AppTheme.colorTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${community.miembros ?? 0} miembros',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.colorTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.article_outlined,
                              size: 14,
                              color: AppTheme.colorTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${community.posts ?? 0} posts',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.colorTextSecondary,
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
      ),
    );
  }
}
