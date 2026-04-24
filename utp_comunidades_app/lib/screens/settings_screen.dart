import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Configuraciones de preferencias
  bool _notificacionesActivas = true;
  bool _emailNotificaciones = true;
  bool _notificacionesMenciones = true;
  bool _modoDark = false;
  bool _privacidadPerfilPublico = true;
  bool _privacidadMostrarEmail = false;
  String _idioma = 'Español';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      setState(() {
        _notificacionesActivas = user.notificacionesActivas ?? true;
        _emailNotificaciones = user.emailNotificaciones ?? true;
        _notificacionesMenciones = user.notificacionesMenciones ?? true;
        _modoDark = user.modoOscuro ?? false;
        _privacidadPerfilPublico = user.privacidadPerfilPublico ?? true;
        _privacidadMostrarEmail = user.privacidadMostrarEmail ?? false;
        _idioma = user.idioma ?? 'Español';
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _loading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final success = await ApiService.post(
      '/users/edit',
      {
        'nombre': user?.nombre ?? '',
        'notificaciones_activas': _notificacionesActivas,
        'email_notificaciones': _emailNotificaciones,
        'notificaciones_menciones': _notificacionesMenciones,
        'modo_oscuro': _modoDark,
        'privacidad_perfil_publico': _privacidadPerfilPublico,
        'privacidad_mostrar_email': _privacidadMostrarEmail,
        'idioma': _idioma,
      },
      auth: true,
    );
    setState(() => _loading = false);
    if (success.statusCode == 200) {
      // Actualizar modelo en provider
      await authProvider.restoreSession();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar preferencias')),
      );
    }
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
            children: [
              if (_loading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
              ],
              // Notificaciones removidas - usar pestaña de notificaciones en bottom nav
              // Apariencia
              _buildSectionCard(
                title: 'Apariencia',
                icon: PhosphorIcons.palette(PhosphorIconsStyle.fill),
                children: [
                  _buildSwitchTile(
                    icon: PhosphorIcons.moon(PhosphorIconsStyle.fill),
                    title: 'Modo oscuro',
                    subtitle: 'Cambiar tema de la app',
                    value: _modoDark,
                    onChanged: (v) {
                      setState(() => _modoDark = v);
                      _savePreferences();
                    },
                  ),
                  _buildNavigationTile(
                    icon: PhosphorIcons.translate(PhosphorIconsStyle.fill),
                    title: 'Idioma',
                    subtitle: _idioma,
                    onTap: () async {
                      await _showLanguageSelector();
                      _savePreferences();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Cuenta
              _buildSectionCard(
                title: 'Cuenta',
                icon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                children: [
                  _buildNavigationTile(
                    icon: PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
                    title: 'Cambiar contraseña',
                    subtitle: 'Actualizar tu contraseña',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  _buildNavigationTile(
                    icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                    title: 'Privacidad',
                    subtitle: 'Configuración de privacidad',
                    onTap: () async {
                      await _showPrivacySettings();
                      _savePreferences();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Acerca de
              _buildSectionCard(
                title: 'Acerca de',
                icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
                children: [
                  _buildInfoTile(
                    icon: PhosphorIcons.appWindow(PhosphorIconsStyle.fill),
                    title: 'Versión de la app',
                    value: '1.0.0',
                  ),
                  _buildInfoTile(
                    icon: PhosphorIcons.fileText(PhosphorIconsStyle.fill),
                    title: 'Términos de servicio',
                    value: 'Ver',
                    onTap: () => _showTermsDialog(),
                  ),
                  _buildInfoTile(
                    icon: PhosphorIcons.shield(PhosphorIconsStyle.fill),
                    title: 'Política de privacidad',
                    value: 'Ver',
                    onTap: () => _showPrivacyPolicyDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildSettingsContent(),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB21132).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFB21132),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[400],
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFB21132),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[400],
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: Icon(
        PhosphorIcons.caretRight(PhosphorIconsStyle.fill),
        color: Colors.grey[300],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[400],
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: const Color(0xFFB21132),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  // Dialog methods
  void _showMentionsSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Notificaciones de menciones',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text(
                  'Recibir notificaciones',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Cuando alguien te mencione en un comentario',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
                value: _notificacionesMenciones,
                activeColor: const Color(0xFFB21132),
                onChanged: (v) {
                  setState(() => _notificacionesMenciones = v);
                  this.setState(() {});
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['Español', 'English', 'Português'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccionar idioma',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...languages.map((lang) => ListTile(
              title: Text(
                lang,
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
              trailing: _idioma == lang
                  ? const Icon(Icons.check, color: Color(0xFFB21132))
                  : null,
              onTap: () {
                setState(() => _idioma = lang);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Idioma cambiado a $lang')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Icono
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB21132).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFFB21132),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa tu contraseña actual y la nueva',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Campos de contraseña con estilo moderno
                    _buildPasswordField(
                      controller: currentPassController,
                      label: 'Contraseña actual',
                      icon: Icons.lock_clock,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: newPassController,
                      label: 'Nueva contraseña',
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: confirmPassController,
                      label: 'Confirmar contraseña',
                      icon: Icons.lock_person,
                    ),
                    const SizedBox(height: 24),
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB21132),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final user = authProvider.firebaseUser;
                              if (newPassController.text != confirmPassController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Las contraseñas no coinciden')),
                                );
                                return;
                              }
                              if (newPassController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor ingresa la nueva contraseña')),
                                );
                                return;
                              }
                              if (user == null || user.email == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Usuario no autenticado')),
                                );
                                return;
                              }
                              try {
                                // Reautenticación
                                final cred = firebase.EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: currentPassController.text,
                                );
                                await user.reauthenticateWithCredential(cred);
                                await user.updatePassword(newPassController.text);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Contraseña actualizada correctamente')),
                                );
                              } on firebase.FirebaseAuthException catch (e) {
                                String msg = 'Error al cambiar contraseña';
                                if (e.code == 'wrong-password') {
                                  msg = 'Contraseña actual incorrecta';
                                } else if (e.code == 'weak-password') {
                                  msg = 'La nueva contraseña es muy débil';
                                } else if (e.code == 'requires-recent-login') {
                                  msg = 'Por seguridad, inicia sesión de nuevo.';
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            },
                            child: const Text(
                              'Cambiar',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFB21132), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Configuración de privacidad',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text(
                  'Perfil público',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Cualquiera puede ver tu perfil',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
                value: _privacidadPerfilPublico,
                activeColor: const Color(0xFFB21132),
                onChanged: (v) {
                  setState(() => _privacidadPerfilPublico = v);
                  this.setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text(
                  'Mostrar email',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Otros usuarios pueden ver tu correo',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
                value: _privacidadMostrarEmail,
                activeColor: const Color(0xFFB21132),
                onChanged: (v) {
                  setState(() => _privacidadMostrarEmail = v);
                  this.setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Términos de servicio',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Bienvenido a UTP Comunidades. Al usar esta aplicación, aceptas:\n\n'
            '1. Respetar a todos los miembros de la comunidad\n'
            '2. No compartir contenido ofensivo o inapropiado\n'
            '3. No hacer spam ni publicidad no autorizada\n'
            '4. Mantener la privacidad de otros usuarios\n'
            '5. Usar la plataforma solo para fines educativos y comunitarios\n\n'
            'El incumplimiento de estos términos puede resultar en la suspensión de tu cuenta.',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Política de privacidad',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'En UTP Comunidades valoramos tu privacidad:\n\n'
            '• Solo recopilamos datos necesarios para el funcionamiento de la app\n'
            '• Tu información no se comparte con terceros\n'
            '• Puedes eliminar tu cuenta en cualquier momento\n'
            '• Usamos medidas de seguridad para proteger tus datos\n'
            '• Las contraseñas están encriptadas\n\n'
            'Para más información contacta a soporte@utp.edu.pe',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
  }
}
