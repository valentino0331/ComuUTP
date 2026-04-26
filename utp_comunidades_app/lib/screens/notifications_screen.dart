import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/notification_provider.dart';
import '../providers/friendship_provider.dart';
import '../models/notification.dart';
import '../theme/app_theme.dart';
import 'friend_requests_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.userPlus(), color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FriendRequestsScreen(),
                ),
              );
            },
          ),
          if (notificationProvider.notifications.isNotEmpty)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Marcar todo como leído'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Todas las notificaciones marcadas como leídas!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Limpiar todo'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Notificaciones eliminadas!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      body: notificationProvider.loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.colorPrimary),
              ),
            )
          : notificationProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: AppTheme.colorTextSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay notificaciones',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.colorTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuando recibas notificaciones, aparecerán aquí',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.colorTextSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    if (notificationProvider.notifications.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                'Hoy',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.colorPrimary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${notificationProvider.notifications.length} nuevas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.colorPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification =
                              notificationProvider.notifications[index];
                          return _buildNotificationItem(
                            context,
                            notification,
                            index,
                          );
                        },
                        childCount:
                            notificationProvider.notifications.length,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    int index,
  ) {
    final iconData = _getNotificationIcon(index);
    final color = _getNotificationColor(index);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notificación: $notification'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.colorSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.colorBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hace ${index + 1} ${index == 0 ? 'minuto' : 'minutos'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.colorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(int index) {
    final icons = [
      Icons.favorite_outline,
      Icons.chat_bubble_outline,
      Icons.person_add_outlined,
      Icons.notification_important_outlined,
      Icons.trending_up,
    ];
    return icons[index % icons.length];
  }

  Color _getNotificationColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      AppTheme.colorPrimary,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}
