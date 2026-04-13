import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profilePrivate = false;
  bool _hideActivity = false;
  bool _allowTagging = true;
  bool _allowMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacidad',
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
          _buildSectionHeader('Visibilidad del perfil'),
          _buildSwitchTile(
            'Perfil privado',
            'Solo tus seguidores pueden ver tu contenido',
            PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
            _profilePrivate,
            (value) => setState(() => _profilePrivate = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Actividad'),
          _buildSwitchTile(
            'Ocultar actividad',
            'No mostrar cuando estás en línea',
            PhosphorIcons.eyeSlash(PhosphorIconsStyle.fill),
            _hideActivity,
            (value) => setState(() => _hideActivity = value),
          ),
          _buildSwitchTile(
            'Permitir etiquetado',
            'Otros usuarios pueden etiquetarte en publicaciones',
            PhosphorIcons.tag(PhosphorIconsStyle.fill),
            _allowTagging,
            (value) => setState(() => _allowTagging = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Mensajes'),
          _buildSwitchTile(
            'Recibir mensajes',
            'Permitir que cualquiera te envíe mensajes',
            PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
            _allowMessages,
            (value) => setState(() => _allowMessages = value),
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
