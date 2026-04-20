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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.colorPrimary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.colorPrimary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.users),
                      const SizedBox(width: 8),
                      const Text('Usuarios'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.chartBar),
                      const SizedBox(width: 8),
                      const Text('Estadísticas'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.wrench),
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
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios por nombre o correo...',
              prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: AppTheme.colorPrimary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsRegular.users, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No hay usuarios', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final String nombre = user['nombre'] ?? user['name'] ?? 'Sin nombre';
                        final String email = user['email'] ?? '';
                        final String role = user['role'] ?? 'user';
                        final String id = user['id']?.toString() ?? '';
                        final bool puedeCrearComunidad = user['puede_crear_comunidad'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.colorPrimary,
                              child: Text(
                                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(email, style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: role == 'admin' ? AppTheme.colorPrimary : Colors.grey,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        role == 'admin' ? 'Administrador' : 'Usuario',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (puedeCrearComunidad)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Crea comunidades',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        role == 'admin'
                                            ? PhosphorIconsRegular.shieldCheck
                                            : PhosphorIconsRegular.shield,
                                        color: AppTheme.colorPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Cambiar rol'),
                                    ],
                                  ),
                                  onTap: () => _showRoleSelectionDialog(
                                    id,
                                    role,
                                    puedeCrearComunidad,
                                  ),
                                ),
                              ],
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
          const Text(
            'Estadísticas del Sistema',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Usuarios',
                _stats['users'].toString(),
                PhosphorIconsRegular.users,
                Colors.blue,
              ),
              _buildStatCard(
                'Comunidades',
                _stats['communities'].toString(),
                PhosphorIconsRegular.users,
                Colors.green,
              ),
              _buildStatCard(
                'Publicaciones',
                _stats['posts'].toString(),
                PhosphorIconsRegular.fileText,
                Colors.orange,
              ),
              _buildStatCard(
                'Reportes',
                _stats['reports'].toString(),
                PhosphorIconsRegular.flag,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Información del Sistema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 8),
                  Text('Versión: 1.0.0', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text('Estado: Activo', style: TextStyle(fontSize: 14, color: Colors.green)),
                  SizedBox(height: 8),
                  Text('Última actualización: Hoy', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
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
          const Text(
            'Herramientas de Administración',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            'Gestión de Reportes',
            'Ver y responder reportes de usuarios',
            PhosphorIconsRegular.flag,
            Colors.red,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Módulo de reportes en desarrollo')),
            ),
          ),
          _buildToolCard(
            'Análisis de Comunidades',
            'Ver detalles y métricas de comunidades',
            PhosphorIconsRegular.chartPie,
            Colors.purple,
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Total: ${_stats['communities']} comunidades activas')),
            ),
          ),
          _buildToolCard(
            'Logs del Sistema',
            'Revisar historial de actividades',
            PhosphorIconsRegular.list,
            Colors.indigo,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logs del sistema disponibles')),
            ),
          ),
          _buildToolCard(
            'Configuración',
            'Ajustar configuración del sistema',
            PhosphorIconsRegular.gear,
            Colors.grey,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuración del sistema')),
            ),
          ),
          _buildToolCard(
            'Enviar Notificación',
            'Notificar a todos los usuarios',
            PhosphorIconsRegular.bell,
            Colors.amber,
            _sendNotificationToAll,
          ),
          _buildToolCard(
            'Copias de Seguridad',
            'Crear y descargar backups',
            PhosphorIconsRegular.cloudArrowDown,
            Colors.cyan,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Última copia: Hoy a las 2:30 AM')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Icon(PhosphorIconsRegular.caretRight, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
