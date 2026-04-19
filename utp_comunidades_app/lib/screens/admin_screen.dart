import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // Users search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoadingUsers = true;
  String _userError = '';

  // Stats
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;
  String _statsError = '';

  final Color _primaryColor = const Color(0xFFB21132);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUsers();
    _fetchStats();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _userError = '';
    });
    try {
      final response = await _apiService.get('/admin/usuarios', auth: true);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data;
          _filteredUsers = data;
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _userError = 'Error al cargar usuarios: \';
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _userError = 'Error: \';
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = '';
    });
    try {
      final response = await _apiService.get('/admin/stats', auth: true);
      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
          _isLoadingStats = false;
        });
      } else {
        setState(() {
          _statsError = 'Error al cargar estadísticas';
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() {
        _statsError = 'Error: \';
        _isLoadingStats = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['nombre'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _togglePermission(int userId, String field, bool value) async {
    try {
      final response = await _apiService.post(
        '/admin/update-permission',
        {
          'userId': userId,
          'field': field,
          'value': value,
        },
        auth: true,
      );
      
      if (response.statusCode == 200) {
        _fetchUsers(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso actualizado correctamente')),
        );
      } else {
        throw Exception('Error al actualizar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración UTP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(PhosphorIcons.users, color: Colors.white), text: 'Usuarios'),
            Tab(icon: Icon(PhosphorIcons.chartBar, color: Colors.white), text: 'Stats'),
            Tab(icon: Icon(PhosphorIcons.wrench, color: Colors.white), text: 'Tools'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
    if (_isLoadingUsers) return const Center(child: CircularProgressIndicator());
    if (_userError.isNotEmpty) return Center(child: Text(_userError));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              prefixIcon: const Icon(PhosphorIcons.magnifyingGlass),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _primaryColor,
                    child: Text(user['nombre']?[0].toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user['nombre'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(user['role'] ?? 'user', style: TextStyle(color: _primaryColor, fontSize: 12)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Puede crear comunidades'),
                            value: user['puede_crear_comunidad'] == 1 || user['puede_crear_comunidad'] == true,
                            activeColor: _primaryColor,
                            onChanged: (val) => _togglePermission(user['id'], 'puede_crear_comunidad', val),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {/* Ver perfil detallado */},
                                child: Text('Ver Detalle', style: TextStyle(color: _primaryColor)),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    if (_isLoadingStats) return const Center(child: CircularProgressIndicator());
    if (_statsError.isNotEmpty) return Center(child: Text(_statsError));

    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard('Total Usuarios', _stats?['total_usuarios']?.toString() ?? '0', PhosphorIcons.usersThree),
          _buildStatCard('Comunidades', _stats?['total_comunidades']?.toString() ?? '0', PhosphorIcons.users),
          _buildStatCard('Publicaciones', _stats?['total_posts']?.toString() ?? '0', PhosphorIcons.article),
          _buildStatCard('Reportes Pendientes', _stats?['total_reportes']?.toString() ?? '0', PhosphorIcons.warning, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color ?? _primaryColor),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: Icon(PhosphorIcons.trash, color: _primaryColor),
          title: const Text('Limpiar Caché'),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: Icon(PhosphorIcons.bell, color: _primaryColor),
          title: const Text('Enviar Notificación Global'),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: Icon(PhosphorIcons.database, color: _primaryColor),
          title: const Text('Backup de Base de Datos'),
          onTap: () {},
        ),
      ],
    );
  }
}
