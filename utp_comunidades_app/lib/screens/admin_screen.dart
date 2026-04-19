import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> usuarios = [];
  bool isLoading = true;
  Map<String, dynamic> stats = {};
  late TabController _tabController;

  static const Color colorPrimario = Color(0xFFB21132);

  final _searchController = TextEditingController();
  final _communityNameController = TextEditingController();

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
    _communityNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _cargarUsuarios();
    await _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final response = await ApiService.get('/admin/stats', auth: true);
      if (response.statusCode == 200) {
        setState(() => stats = jsonDecode(response.body));
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error al cargar estadísticas');
    }
  }

  Future<void> _cargarUsuarios({String search = ''}) async {
    setState(() => isLoading = true);
    try {
      final endpoint = search.isEmpty
          ? '/admin/usuarios'
          : '/admin/usuarios?search=$search';
      final response = await ApiService.get(endpoint, auth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usuarios = data['usuarios'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnackBar('Error al cargar usuarios: $e');
    }
  }

  Future<void> _updateUserPermissions(int userId, bool canCreate, String role) async {
    try {
      final response = await ApiService.post(
        '/admin/usuarios/$userId/permisos',
        {'puede_crear_comunidad': canCreate, 'role': role},
        auth: true,
      );
      if (response.statusCode == 200) {
        _showSnackBar('Permisos actualizados exitosamente');
        _loadData();
      }
    } catch (e) {
      _showSnackBar('Error al actualizar permisos: $e');
    }
  }

  Future<void> _crearComunidad() async {
    if (_communityNameController.text.isEmpty) {
      _showSnackBar('El nombre de la comunidad es requerido');
      return;
    }
    try {
      final response = await ApiService.post(
        '/admin/comunidades',
        {'nombre': _communityNameController.text, 'descripcion': _communityNameController.text},
        auth: true,
      );
      if (response.statusCode == 201) {
        _showSnackBar('Comunidad creada exitosamente');
        _communityNameController.clear();
        _loadData();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error al crear comunidad: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    if (currentUser == null || currentUser.role != 'admin') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold),
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Acceso Denegado', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Solo administradores pueden acceder',
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: colorPrimario,
        elevation: 0,
        title: const Text('Panel de Administración',
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorPrimario)))
          : Column(
              children: [
                _buildStatsSection(),
                TabBar(
                  controller: _tabController,
                  labelColor: colorPrimario,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: colorPrimario,
                  tabs: const [
                    Tab(text: 'Usuarios'),
                    Tab(text: 'Comunidades'),
                    Tab(text: 'Herramientas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsuariosTab(),
                      _buildComunidadesTab(),
                      _buildHerramientasTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard('Usuarios', stats['totalUsuarios'] ?? 0,
                PhosphorIcons.users(PhosphorIconsStyle.bold)),
            const SizedBox(width: 12),
            _buildStatCard('Comunidades', stats['totalComunidades'] ?? 0,
                PhosphorIcons.usersThree(PhosphorIconsStyle.bold)),
            const SizedBox(width: 12),
            _buildStatCard(
                'Posts', stats['totalPosts'] ?? 0, PhosphorIcons.articleNyTimes(PhosphorIconsStyle.bold)),
            const SizedBox(width: 12),
            _buildStatCard(
                'Admins', stats['totalAdmins'] ?? 0, PhosphorIcons.shield(PhosphorIconsStyle.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorPrimario.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorPrimario.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorPrimario, size: 24),
          const SizedBox(height: 8),
          Text('$value',
              style: const TextStyle(
                  fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: colorPrimario)),
          Text(label,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildUsuariosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => _cargarUsuarios(search: value),
          ),
        ),
        Expanded(
          child: usuarios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.userMinus(PhosphorIconsStyle.bold), size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No hay usuarios',
                          style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) => _buildUsuarioCard(usuarios[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildComunidadesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Crear Comunidad', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              onPressed: _showCreateCommunityDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Comunidad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimario,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHerramientasTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.wrench(PhosphorIconsStyle.bold), size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Herramientas de Administrador', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _cargarEstadisticas,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar Estadísticas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar Datos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(dynamic usuario) {
    final isAdmin = usuario['role'] == 'admin';
    final puedeCrear = usuario['puede_crear_comunidad'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario['nombre'] ?? 'Sin nombre',
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
            Text(usuario['email'] ?? '',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Wrap(
          children: [
            if (isAdmin)
              Chip(
                label: const Text('Admin'),
                backgroundColor: colorPrimario.withOpacity(0.2),
                labelStyle: const TextStyle(color: colorPrimario, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            if (puedeCrear)
              Chip(
                label: const Text('Puede crear'),
                backgroundColor: Colors.green.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Crear comunidades',
                              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                          Text(puedeCrear ? 'Permitido' : 'No permitido',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: puedeCrear ? Colors.green : Colors.grey[600])),
                        ],
                      ),
                    ),
                    Switch(
                      value: puedeCrear,
                      onChanged: (value) =>
                          _updateUserPermissions(usuario['id'], value, isAdmin ? 'admin' : 'user'),
                      activeColor: colorPrimario,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rol de administrador',
                              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                          Text(isAdmin ? 'Es admin' : 'Usuario normal',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: isAdmin ? colorPrimario : Colors.grey[600])),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAdmin,
                      onChanged: (value) =>
                          _updateUserPermissions(usuario['id'], puedeCrear, value ? 'admin' : 'user'),
                      activeColor: colorPrimario,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Comunidad'),
        content: TextField(
          controller: _communityNameController,
          decoration: const InputDecoration(
            hintText: 'Nombre de la comunidad',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _crearComunidad();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorPrimario),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
