import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorEnabled = false;
  bool _loginAlerts = true;
  bool _trustedDevices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seguridad',
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
          _buildSectionHeader('Autenticación'),
          _buildSwitchTile(
            'Verificación en dos pasos',
            'Añade una capa extra de seguridad',
            PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            _twoFactorEnabled,
            (value) {
              if (value) {
                _show2FADialog();
              } else {
                setState(() => _twoFactorEnabled = value);
              }
            },
          ),
          _buildActionTile(
            'Cambiar contraseña',
            'Actualiza tu contraseña regularmente',
            PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
            () => _showChangePasswordDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Alertas de seguridad'),
          _buildSwitchTile(
            'Alertas de inicio de sesión',
            'Notificación cuando hay un nuevo inicio de sesión',
            PhosphorIcons.desktop(PhosphorIconsStyle.fill),
            _loginAlerts,
            (value) => setState(() => _loginAlerts = value),
          ),
          _buildSwitchTile(
            'Dispositivos de confianza',
            'Recordar dispositivos autorizados',
            PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
            _trustedDevices,
            (value) => setState(() => _trustedDevices = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Sesiones activas'),
          _buildSessionTile('Chrome - Windows', 'Activo ahora', true),
          _buildSessionTile('Safari - iPhone', 'Hace 2 horas', false),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar todas las sesiones'),
                  content: const Text('¿Estás seguro? Tendrás que iniciar sesión de nuevo en todos los dispositivos.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Todas las sesiones cerradas'),
                            backgroundColor: Color(0xFFB21132),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Cerrar todo'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(PhosphorIcons.signOut(PhosphorIconsStyle.fill)),
            label: const Text('Cerrar todas las sesiones'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
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

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar 2FA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
              size: 64,
              color: const Color(0xFFB21132),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escanea este código QR con tu app de autenticación',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('QR Code')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorEnabled = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('2FA activado correctamente'),
                  backgroundColor: Color(0xFFB21132),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
            ),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada'),
                  backgroundColor: Color(0xFFB21132),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
            ),
            child: const Text('Guardar'),
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

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSessionTile(String device, String lastActive, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFB21132).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xFFB21132) : Colors.grey[200]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          PhosphorIcons.desktop(PhosphorIconsStyle.fill),
          color: isCurrent ? const Color(0xFFB21132) : Colors.grey,
        ),
        title: Text(
          device,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: isCurrent ? const Color(0xFFB21132) : Colors.black,
          ),
        ),
        subtitle: Text(
          isCurrent ? 'Este dispositivo' : lastActive,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
          ),
        ),
        trailing: isCurrent
            ? Chip(
                label: const Text('Actual'),
                backgroundColor: const Color(0xFFB21132),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              )
            : null,
      ),
    );
  }
}
