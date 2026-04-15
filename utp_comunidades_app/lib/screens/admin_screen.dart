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

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> usuarios = [];
  bool isLoading = true;
  int totalUsuarios = 0;
  
  static const Color colorPrimario = Color(0xFFB21132);

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final response = await ApiService.get('/admin/usuarios');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usuarios = data['data'] ?? [];
          totalUsuarios = usuarios.length;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
  }

  Future<void> _otorgarPermiso(int usuarioId, String permiso) async {
    try {
      final response = await ApiService.post('/admin/usuarios/$usuarioId/permisos', {
        'permiso': permiso,
        'valor': true,
      }, auth: true);
      
      if (response.statusCode == 200) {
        _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso otorgado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al otorgar permiso: $e')),
        );
      }
    }
  }

  Future<void> _revocarPermiso(int usuarioId, String permiso) async {
    try {
      final response = await ApiService.post('/admin/usuarios/$usuarioId/permisos', {
        'permiso': permiso,
        'valor': false,
      }, auth: true);
      
      if (response.statusCode == 200) {
        _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso revocado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al revocar permiso: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.lockKey(PhosphorIconsStyle.bold),
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No autenticado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Necesitas autenticarte para acceder',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
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
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorPrimario),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Estadísticas
                SliverToBoxAdapter(
                  child: _buildStatsSection(),
                ),
                
                // Lista de usuarios
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Gestión de Usuarios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final usuario = usuarios[index];
                      return _buildUsuarioCard(usuario);
                    },
                    childCount: usuarios.length,
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      PhosphorIcons.users(PhosphorIconsStyle.bold),
                      color: colorPrimario,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalUsuarios',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usuarios',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: Colors.grey[200],
                ),
                Column(
                  children: [
                    Icon(
                      PhosphorIcons.check(PhosphorIconsStyle.bold),
                      color: colorPrimario,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${usuarios.where((u) => u['puedeCrearComunidad'] == true).length}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Con permiso',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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

  Widget _buildUsuarioCard(dynamic usuario) {
    final puedeCrearComunidad = usuario['puedeCrearComunidad'] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorPrimario.withOpacity(0.2),
                  child: Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.bold),
                    color: colorPrimario,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario['email'] ?? 'Sin email',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: puedeCrearComunidad
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    puedeCrearComunidad
                        ? PhosphorIcons.check(PhosphorIconsStyle.bold)
                        : PhosphorIcons.x(PhosphorIconsStyle.bold),
                    color: puedeCrearComunidad ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    puedeCrearComunidad
                        ? 'Puede crear comunidades'
                        : 'No puede crear comunidades',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: puedeCrearComunidad ? Colors.green : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!puedeCrearComunidad)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _otorgarPermiso(usuario['id'], 'crear_comunidad'),
                      icon: const Icon(Icons.check),
                      label: const Text('Otorgar permiso'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _revocarPermiso(usuario['id'], 'crear_comunidad'),
                      icon: const Icon(Icons.close),
                      label: const Text('Revocar permiso'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
