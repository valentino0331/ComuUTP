import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _dbService = DatabaseService();
  final Color primaryColor = const Color(0xFFB21132);
  
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _dbService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
            Tab(icon: Icon(Icons.settings), text: 'Herramientas'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryColor))
        : TabBarView(
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
    final filteredUsers = _users.where((u) => 
      (u['nombre']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
      (u['correo']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(user['nombre']?[0].toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(user['nombre'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user['correo'] ?? ''),
                    trailing: Chip(
                      label: Text(user['role'] ?? 'user', style: const TextStyle(fontSize: 12)),
                      backgroundColor: (user['role'] == 'admin') ? Colors.amber[100] : Colors.blue[100],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Permiso para crear comunidades'),
                              value: user['puede_crear_comunidad'] ?? false,
                              activeColor: primaryColor,
                              onChanged: (bool value) async {
                                // Aquí iría la lógica de actualización
                              },
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar'),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.block, size: 18, color: Colors.red),
                                  label: const Text('Suspender', style: TextStyle(color: Colors.red)),
                                ),
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
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen General', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Usuarios', _users.length.toString(), Icons.person, Colors.blue),
              _buildStatCard('Comunidades', '12', Icons.groups, Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Eventos', '45', Icons.event, Colors.orange),
              _buildStatCard('Reportes', '3', Icons.warning, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Actividad Reciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActivityItem('Nuevo usuario registrado: Juan Perez', 'Hace 5 min'),
          _buildActivityItem('Nueva comunidad creada: Flutter Devs', 'Hace 2 horas'),
          _buildActivityItem('Reporte resuelto: Spam en General', 'Hace 1 día'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.history, color: primaryColor),
        title: Text(text),
        trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolTile('Configuración del Sistema', 'Ajustes globales de la plataforma', Icons.settings),
        _buildToolTile('Logs del Servidor', 'Ver historial de transacciones y errores', Icons.terminal),
        _buildToolTile('Gestión de Roles', 'Definir permisos personalizados', Icons.security),
        _buildToolTile('Base de Datos', 'Backup y limpieza de registros', Icons.storage),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text('Exportar Reporte Mensual (PDF)', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildToolTile(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
