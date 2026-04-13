import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class AllEvidencesScreen extends StatefulWidget {
  const AllEvidencesScreen({super.key});

  @override
  State<AllEvidencesScreen> createState() => _AllEvidencesScreenState();
}

class _AllEvidencesScreenState extends State<AllEvidencesScreen> {
  String _selectedFilter = 'todas';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      final estado = _selectedFilter == 'todas' ? null : _selectedFilter;
      await attendanceProvider.fetchAllEvidences(authProvider.token!, estado: estado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final evidences = attendanceProvider.allEvidences;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todas las Evidencias',
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
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'todas', PhosphorIcons.list(PhosphorIconsStyle.fill)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes', 'pendiente', PhosphorIcons.hourglass(PhosphorIconsStyle.fill)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aprobadas', 'aprobada', PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rechazadas', 'rechazada', PhosphorIcons.xCircle(PhosphorIconsStyle.fill)),
                ],
              ),
            ),
          ),
          // List
          Expanded(
            child: attendanceProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFB21132)))
                : evidences.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: const Color(0xFFB21132),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: evidences.length,
                          itemBuilder: (context, index) {
                            final evidence = evidences[index];
                            return _buildEvidenceCard(evidence);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _loadData();
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: const Color(0xFFB21132).withOpacity(0.2),
      checkmarkColor: const Color(0xFFB21132),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.folderOpen(PhosphorIconsStyle.fill),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay evidencias${_selectedFilter != 'todas' ? ' en este filtro' : ''}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(dynamic evidence) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (evidence.estado) {
      case 'aprobada':
        statusColor = Colors.green;
        statusText = 'Aprobada';
        statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
        break;
      case 'rechazada':
        statusColor = Colors.red;
        statusText = 'Rechazada';
        statusIcon = PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = PhosphorIcons.hourglass(PhosphorIconsStyle.fill);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(evidence.urlEvidencia),
              fit: BoxFit.cover,
            ),
          ),
          child: evidence.urlEvidencia.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_not_supported),
                )
              : null,
        ),
        title: Text(
          'Evidencia #${evidence.id}',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Usuario: ${evidence.usuarioId} • ${evidence.tipoTexto}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Chip(
          avatar: Icon(statusIcon, size: 16, color: Colors.white),
          label: Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          backgroundColor: statusColor,
          padding: EdgeInsets.zero,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 12),
                // Details
                _buildDetailRow('Tipo', evidence.tipoTexto),
                _buildDetailRow('Estado', statusText, color: statusColor),
                _buildDetailRow('Fecha envío', _formatDate(evidence.createdAt)),
                if (evidence.descripcion != null)
                  _buildDetailRow('Descripción', evidence.descripcion!),
                if (evidence.fechaRevision != null) ...[
                  _buildDetailRow('Revisado', _formatDate(evidence.fechaRevision!)),
                  if (evidence.revisadoPor != null)
                    _buildDetailRow('Revisado por', 'Admin #${evidence.revisadoPor}'),
                ],
                const SizedBox(height: 12),
                // Actions for pending
                if (evidence.estado == 'pendiente')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(evidence.id),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
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
