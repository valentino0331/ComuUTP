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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.colorPrimary,
                AppTheme.colorPrimary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              community.nombre.isNotEmpty
                  ? community.nombre[0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          community.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              community.descripcion,
              style: TextStyle(
                color: AppTheme.colorTextSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (community.miembros != null || community.posts != null)
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 12,
                    color: AppTheme.colorTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${community.miembros ?? 0} miembros',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.article_outlined,
                    size: 12,
                    color: AppTheme.colorTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${community.posts ?? 0} posts',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.colorTextSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.check, size: 18),
                  SizedBox(width: 8),
                  Text('Unirme'),
                ],
              ),
              onTap: () async {
                final success = await Provider.of<CommunityProvider>(
                        context,
                        listen: false)
                    .joinCommunity(community.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Te uniste a la comunidad'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Compartir'),
                ],
              ),
            ),
          ],
          offset: const Offset(0, 40),
          child: const Icon(Icons.more_vert, size: 18),
        ),
        onTap: onTap,
      ),
    );
  }
}
