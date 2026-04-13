import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _likesEnabled = true;
  bool _commentsEnabled = true;
  bool _mentionsEnabled = true;
  bool _messagesEnabled = true;
  bool _communityUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFB21132),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Canales'),
          _buildSwitchTile(
            'Notificaciones push',
            'Recibir notificaciones en tu dispositivo',
            PhosphorIcons.bell(PhosphorIconsStyle.fill),
            _pushEnabled,
            (value) => setState(() => _pushEnabled = value),
          ),
          _buildSwitchTile(
            'Correo electrónico',
            'Recibir notificaciones por email',
            PhosphorIcons.envelope(PhosphorIconsStyle.fill),
            _emailEnabled,
            (value) => setState(() => _emailEnabled = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Interacciones'),
          _buildSwitchTile(
            'Me gusta',
            'Cuando alguien da like a tu publicación',
            PhosphorIcons.heart(PhosphorIconsStyle.fill),
            _likesEnabled,
            (value) => setState(() => _likesEnabled = value),
          ),
          _buildSwitchTile(
            'Comentarios',
            'Cuando alguien comenta tu publicación',
            PhosphorIcons.chatCircleText(PhosphorIconsStyle.fill),
            _commentsEnabled,
            (value) => setState(() => _commentsEnabled = value),
          ),
          _buildSwitchTile(
            'Menciones',
            'Cuando alguien te menciona',
            PhosphorIcons.at(PhosphorIconsStyle.fill),
            _mentionsEnabled,
            (value) => setState(() => _mentionsEnabled = value),
          ),
          _buildSwitchTile(
            'Mensajes',
            'Cuando recibes un mensaje nuevo',
            PhosphorIcons.chatTeardropText(PhosphorIconsStyle.fill),
            _messagesEnabled,
            (value) => setState(() => _messagesEnabled = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Comunidades'),
          _buildSwitchTile(
            'Actualizaciones de comunidades',
            'Nuevas publicaciones en tus comunidades',
            PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
            _communityUpdates,
            (value) => setState(() => _communityUpdates = value),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración guardada'),
                  backgroundColor: Color(0xFFB21132),
                ),
              );
              Navigator.pop(context);
            },
            icon: Icon(PhosphorIcons.floppyDisk(PhosphorIconsStyle.fill)),
            label: const Text('Guardar cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB21132)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFB21132),
        ),
      ),
    );
  }
}
