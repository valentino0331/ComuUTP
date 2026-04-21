import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import 'package:utp_comunidades_app/services/api_service.dart';
import 'package:utp_comunidades_app/theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

// Gradient colors for different stat types
final Map<String, LinearGradient> _statGradients = {
  'users': LinearGradient(
    colors: [const Color(0xFF6366F1).withOpacity(0.3), const Color(0xFF4F46E5).withOpacity(0.1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'communities': LinearGradient(
    colors: [const Color(0xFF10B981).withOpacity(0.3), const Color(0xFF059669).withOpacity(0.1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'posts': LinearGradient(
    colors: [const Color(0xFFF59E0B).withOpacity(0.3), const Color(0xFFD97706).withOpacity(0.1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'reports': LinearGradient(
    colors: [const Color(0xFFEF4444).withOpacity(0.3), const Color(0xFFDC2626).withOpacity(0.1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
};

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  bool _isLoading = false;
  final Map<String, int> _stats = {
    'users': 0,
    'communities': 0,
    'posts': 0,
    'reports': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final usersResponse = await ApiService.get('/admin/usuarios', auth: true);
      if (usersResponse.statusCode == 200) {
        final data = jsonDecode(usersResponse.body);
        final List<dynamic> users = data['usuarios'] ?? [];
        
        if (mounted) {
          setState(() {
            _users = users;
            _stats['users'] = users.length;
            _stats['communities'] = data['total_comunidades'] ?? 0;
            _stats['posts'] = data['total_posts'] ?? 0;
            _stats['reports'] = data['total_reportes'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserRole(String userId, String currentRole) async {
    try {
      final newRole = currentRole == 'admin' ? 'user' : 'admin';
      
      await ApiService.patch('/admin/usuarios/$userId', {'role': newRole}, auth: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario actualizado a $newRole'),
          backgroundColor: AppTheme.colorPrimary,
        ),
      );
      
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showRoleSelectionDialog(
    String userId,
    String currentRole,
    bool currentPuedeCrearComunidad,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Seleccionar Rol',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption(
              context,
              'Usuario Normal',
              'Sin permisos especiales',
              currentRole == 'user' && !currentPuedeCrearComunidad,
              () async {
                Navigator.pop(context);
                await ApiService.patch('/admin/usuarios/$userId', {
                  'role': 'user',
                  'puede_crear_comunidad': false,
                }, auth: true);
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              context,
              'Crear Comunidades',
              'Permiso para crear 1 comunidad',
              currentPuedeCrearComunidad && currentRole != 'admin',
              () async {
                Navigator.pop(context);
                await ApiService.patch('/admin/usuarios/$userId', {
                  'role': 'user',
                  'puede_crear_comunidad': true,
                }, auth: true);
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              context,
              'Administrador',
              'Acceso total al sistema',
              currentRole == 'admin',
              () async {
                Navigator.pop(context);
                await ApiService.patch('/admin/usuarios/$userId', {
                  'role': 'admin',
                  'puede_crear_comunidad': true,
                }, auth: true);
                _loadData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.colorPrimary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.colorPrimary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.colorPrimary : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppTheme.colorPrimary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isSelected ? AppTheme.colorPrimary : Colors.black87,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel de Administración',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido, Administrador',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.colorPrimary,
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: AppTheme.colorPrimary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.users, size: 18),
                      const SizedBox(width: 8),
                      const Text('Usuarios'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.chartBar, size: 18),
                      const SizedBox(width: 8),
                      const Text('Estadísticas'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.wrench, size: 18),
                      const SizedBox(width: 8),
                      const Text('Herramientas'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildStatsTab(),
          _buildToolsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _users.where((user) {
      final name = (user['nombre'] ?? user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final searchTerm = _searchController.text.toLowerCase();
      return name.contains(searchTerm) || email.contains(searchTerm);
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios por nombre o correo...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Montserrat',
              ),
              prefixIcon: Icon(
                PhosphorIconsRegular.magnifyingGlass,
                color: AppTheme.colorPrimary,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.colorPrimary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              PhosphorIconsRegular.users,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay usuarios',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final String nombre = user['nombre'] ?? user['name'] ?? 'Sin nombre';
                        final String email = user['email'] ?? '';
                        final String role = user['role'] ?? 'user';
                        final String id = user['id']?.toString() ?? '';
                        final bool puedeCrearComunidad = user['puede_crear_comunidad'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.colorPrimary.withOpacity(0.8),
                                      AppTheme.colorPrimary.withOpacity(0.4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: role == 'admin'
                                              ? const Color(0xFFB21132).withOpacity(0.15)
                                              : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          role == 'admin' ? '👑 Admin' : '👤 Usuario',
                                          style: TextStyle(
                                            color: role == 'admin'
                                                ? const Color(0xFFB21132)
                                                : Colors.grey[700],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (puedeCrearComunidad)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '✨ Creator',
                                            style: TextStyle(
                                              color: Color(0xFF10B981),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Container(
                                      width: 200,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.colorPrimary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              PhosphorIconsRegular.shieldCheck,
                                              color: AppTheme.colorPrimary,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Cambiar rol',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () => _showRoleSelectionDialog(
                                      id,
                                      role,
                                      puedeCrearComunidad,
                                    ),
                                  ),
                                ],
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    PhosphorIconsRegular.dotsThreeVertical,
                                    color: AppTheme.colorPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Estadísticas del Sistema',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen general de tu comunidad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                'Usuarios',
                _stats['users'].toString(),
                PhosphorIconsRegular.users,
                const Color(0xFF6366F1),
                'usuarios',
              ),
              _buildStatCard(
                'Comunidades',
                _stats['communities'].toString(),
                PhosphorIconsRegular.users,
                const Color(0xFF10B981),
                'communities',
              ),
              _buildStatCard(
                'Publicaciones',
                _stats['posts'].toString(),
                PhosphorIconsRegular.fileText,
                const Color(0xFFF59E0B),
                'posts',
              ),
              _buildStatCard(
                'Reportes',
                _stats['reports'].toString(),
                PhosphorIconsRegular.flag,
                const Color(0xFFEF4444),
                'reports',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // System Info Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.info,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Información del Sistema',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Versión', '1.0.0'),
                const SizedBox(height: 12),
                _buildInfoRow('Estado', '✓ Activo', Colors.green),
                const SizedBox(height: 12),
                _buildInfoRow('Base de Datos', '🔐 PostgreSQL'),
                const SizedBox(height: 12),
                _buildInfoRow('Última actualización', 'Hoy'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String key,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1.5,
          ),
          gradient: _statGradients[key],
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '↑ 12%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendNotificationToAll() async {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Notificación a Todos'),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escribe el mensaje a enviar...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colorPrimary),
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                try {
                  final res = await ApiService.post(
                    '/notifications/broadcast',
                    {'mensaje': messageController.text},
                    auth: true,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificación enviada a todos los usuarios'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Herramientas de Administración',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tu comunidad y usuarios',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),

          // Tools Grid
          _buildToolCard(
            'Gestión de Reportes',
            'Ver y responder reportes de usuarios',
            PhosphorIconsRegular.flag,
            const Color(0xFFEF4444),
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Módulo de reportes en desarrollo'),
                backgroundColor: Color(0xFFEF4444),
              ),
            ),
          ),
          _buildToolCard(
            'Análisis de Comunidades',
            'Ver detalles y métricas de comunidades',
            PhosphorIconsRegular.chartPie,
            const Color(0xFF8B5CF6),
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Total: ${_stats['communities']} comunidades activas',
                ),
                backgroundColor: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          _buildToolCard(
            'Logs del Sistema',
            'Revisar historial de actividades',
            PhosphorIconsRegular.list,
            const Color(0xFF3B82F6),
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logs del sistema disponibles'),
                backgroundColor: Color(0xFF3B82F6),
              ),
            ),
          ),
          _buildToolCard(
            'Configuración',
            'Ajustar configuración del sistema',
            PhosphorIconsRegular.gear,
            const Color(0xFF6B7280),
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuración del sistema'),
                backgroundColor: Color(0xFF6B7280),
              ),
            ),
          ),
          _buildToolCard(
            'Enviar Notificación',
            'Notificar a todos los usuarios',
            PhosphorIconsRegular.bell,
            const Color(0xFFFCD34D),
            _sendNotificationToAll,
          ),
          _buildToolCard(
            'Copias de Seguridad',
            'Crear y descargar backups',
            PhosphorIconsRegular.cloudArrowDown,
            const Color(0xFF06B6D4),
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Última copia: Hoy a las 2:30 AM'),
                backgroundColor: Color(0xFF06B6D4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  PhosphorIconsRegular.caretRight,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
