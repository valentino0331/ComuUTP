import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class PendingEvidencesScreen extends StatefulWidget {
  const PendingEvidencesScreen({super.key});

  @override
  State<PendingEvidencesScreen> createState() => _PendingEvidencesScreenState();
}

class _PendingEvidencesScreenState extends State<PendingEvidencesScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await attendanceProvider.fetchPendingEvidences(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final evidences = attendanceProvider.pendingEvidences;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Evidencias Pendientes',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFB21132),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFB21132),
        child: attendanceProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFB21132)))
            : evidences.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: evidences.length,
                    itemBuilder: (context, index) {
                      final evidence = evidences[index];
                      return _buildEvidenceCard(evidence);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay evidencias pendientes',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todas las evidencias han sido revisadas',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(dynamic evidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              evidence.urlEvidencia,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Chip(
                      label: Text(evidence.tipoTexto),
                      backgroundColor: const Color(0xFFB21132).withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFFB21132),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: const Text('Pendiente'),
                      backgroundColor: Colors.orange,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Info
                Text(
                  'Usuario ID: ${evidence.usuarioId}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (evidence.descripcion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    evidence.descripcion!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Enviado: ${_formatDate(evidence.createdAt)}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(evidence.id),
                        icon: const Icon(Icons.close),
                        label: const Text('Rechazar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveEvidence(evidence.id),
                        icon: const Icon(Icons.check),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRejectDialog(int evidenceId) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar evidencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de rechazar esta evidencia?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Explica por qué se rechaza...',
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
              _rejectEvidence(evidenceId, commentController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveEvidence(int evidenceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    final success = await attendanceProvider.reviewEvidence(
      token: authProvider.token!,
      evidenceId: evidenceId,
      approve: true,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia aprobada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectEvidence(int evidenceId, String? comment) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    final success = await attendanceProvider.reviewEvidence(
      token: authProvider.token!,
      evidenceId: evidenceId,
      approve: false,
      comentario: comment?.isNotEmpty == true ? comment : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia rechazada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
