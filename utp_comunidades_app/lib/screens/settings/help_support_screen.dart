import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFB21132),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar ayuda...',
                hintStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  'Centro de ayuda',
                  PhosphorIcons.bookOpen(PhosphorIconsStyle.fill),
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Chat en vivo',
                  PhosphorIcons.chatCenteredText(PhosphorIconsStyle.fill),
                  () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // FAQs
          _buildSectionHeader('Preguntas frecuentes'),
          _buildExpandableTile(
            '¿Cómo creo una comunidad?',
            'Para crear una comunidad, ve a la pestaña de comunidades y presiona el botón "+". Necesitas ser usuario premium o tener 10 asistencias verificadas.',
          ),
          _buildExpandableTile(
            '¿Cómo verifico mi asistencia?',
            'Ve a tu perfil, selecciona "Verificar asistencia" y sube una foto de tu carnet de estudiante o constancia de matrícula.',
          ),
          _buildExpandableTile(
            '¿Qué es Premium?',
            'Premium te permite crear comunidades sin verificación de asistencia, obtener un badge exclusivo y soporte prioritario.',
          ),
          _buildExpandableTile(
            '¿Cómo reporto contenido?',
            'Presiona los tres puntos en cualquier publicación y selecciona "Reportar". Nuestro equipo revisará el contenido.',
          ),
          const SizedBox(height: 24),
          // Contact
          _buildSectionHeader('Contacto'),
          _buildContactTile(
            'Email',
            'soporte@utpcomunidades.app',
            PhosphorIcons.envelope(PhosphorIconsStyle.fill),
          ),
          _buildContactTile(
            'Teléfono',
            '+51 1 234 5678',
            PhosphorIcons.phone(PhosphorIconsStyle.fill),
          ),
          _buildContactTile(
            'Horario',
            'Lun - Vie: 9am - 6pm',
            PhosphorIcons.clock(PhosphorIconsStyle.fill),
          ),
          const SizedBox(height: 32),
          // Report issue button
          ElevatedButton.icon(
            onPressed: () => _showReportIssueDialog(context),
            icon: Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill)),
            label: const Text('Reportar un problema'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: issueController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe el problema que estás experimentando...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.regular),
                  color: const Color(0xFFB21132),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Adjuntar captura'),
                ),
              ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado. Gracias por tu ayuda!'),
                  backgroundColor: Color(0xFFB21132),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFB21132).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB21132).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFB21132), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Color(0xFFB21132),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        leading: Icon(PhosphorIcons.question(PhosphorIconsStyle.fill), color: const Color(0xFFB21132)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB21132)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
