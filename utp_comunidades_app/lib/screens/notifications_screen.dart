import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: notificationProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? const Center(child: Text('No hay notificaciones'))
              : ListView.builder(
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.deepPurple),
                        title: Text(notificationProvider.notifications[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
