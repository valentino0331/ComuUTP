import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showOnlyUnread = false;

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
    } else if (diff.inHours > 0) {
      return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    } else if (diff.inMinutes > 0) {
      return 'Hace ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Ahora mismo';
    }
  }

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Notifications List
            _buildNotificationsList(),
          ],
        ),
      ),
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
            PhosphorIcons.bell(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notificaciones',
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

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        if (notificationProvider.loading) {
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

        if (notificationProvider.notifications.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.bellSlash(PhosphorIconsStyle.fill),
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando recibas notificaciones,\naparecerán aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationCard(notification, index);
              },
              childCount: notificationProvider.notifications.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    // Map notification types to icons
    IconData getIconForType(String tipo) {
      switch (tipo) {
        case 'like':
          return PhosphorIcons.heart(PhosphorIconsStyle.fill);
        case 'comentario':
          return PhosphorIcons.chatCircleText(PhosphorIconsStyle.fill);
        case 'seguir':
          return PhosphorIcons.userPlus(PhosphorIconsStyle.fill);
        case 'invitacion':
          return PhosphorIcons.envelope(PhosphorIconsStyle.fill);
        case 'publicacion':
          return PhosphorIcons.notebook(PhosphorIconsStyle.fill);
        case 'mencion':
          return PhosphorIcons.at(PhosphorIconsStyle.fill);
        case 'sistema':
          return PhosphorIcons.info(PhosphorIconsStyle.fill);
        default:
          return PhosphorIcons.bell(PhosphorIconsStyle.fill);
      }
    }
    
    // Map notification types to colors
    Color getColorForType(String tipo) {
      switch (tipo) {
        case 'like':
          return const Color(0xFFB21132);
        case 'comentario':
          return const Color(0xFF1E3A8A);
        case 'seguir':
          return const Color(0xFF059669);
        case 'invitacion':
          return const Color(0xFF7C3AED);
        case 'publicacion':
          return const Color(0xFFF59E0B);
        case 'mencion':
          return const Color(0xFFEC4899);
        case 'sistema':
          return const Color(0xFF6B7280);
        default:
          return const Color(0xFFB21132);
      }
    }
    
    final icon = getIconForType(notification.tipo);
    final color = getColorForType(notification.tipo);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${notification.titulo}: ${notification.mensaje}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titulo,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.mensaje,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.clock(PhosphorIconsStyle.regular),
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(notification.fechaCreacion),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: Colors.grey[300],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
