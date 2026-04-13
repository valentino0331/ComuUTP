import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import 'pending_evidences_screen.dart';
import 'all_evidences_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await attendanceProvider.fetchAdminStats(authProvider.token!);
      await attendanceProvider.fetchPendingEvidences(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final stats = attendanceProvider.stats;
    final pendingCount = attendanceProvider.pendingEvidences.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFB21132),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFB21132),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB21132), Color(0xFFE83E8C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenido, Administrador',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Gestiona evidencias y usuarios',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Pendientes',
                      PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
                      pendingCount.toString(),
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PendingEvidencesScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Todas',
                      PhosphorIcons.listDashes(PhosphorIconsStyle.fill),
                      stats['total_evidences']?.toString() ?? '0',
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllEvidencesScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Text(
                'Estadísticas',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    'Usuarios',
                    stats['total_users']?.toString() ?? '0',
                    PhosphorIcons.users(PhosphorIconsStyle.fill),
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Comunidades',
                    stats['total_communities']?.toString() ?? '0',
                    PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Evidencias',
                    stats['total_evidences']?.toString() ?? '0',
                    PhosphorIcons.fileImage(PhosphorIconsStyle.fill),
                    Colors.purple,
                  ),
                  _buildStatCard(
                    'Aprobadas',
                    stats['approved_evidences']?.toString() ?? '0',
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pending evidences preview
              if (pendingCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Evidencias Pendientes',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PendingEvidencesScreen()),
                      ),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...attendanceProvider.pendingEvidences.take(3).map((evidence) {
                  return _buildPendingEvidenceCard(evidence);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingEvidenceCard(dynamic evidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.fileImage(PhosphorIconsStyle.fill),
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evidencia #${evidence.id}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Usuario ID: ${evidence.usuarioId}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: const Text('Pendiente'),
            backgroundColor: Colors.orange,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
