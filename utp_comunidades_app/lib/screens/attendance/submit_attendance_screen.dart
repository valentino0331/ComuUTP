import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class SubmitAttendanceScreen extends StatefulWidget {
  const SubmitAttendanceScreen({super.key});

  @override
  State<SubmitAttendanceScreen> createState() => _SubmitAttendanceScreenState();
}

class _SubmitAttendanceScreenState extends State<SubmitAttendanceScreen> {
  File? _selectedImage;
  String? _selectedType;
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  final List<Map<String, dynamic>> _evidenceTypes = [
    {
      'value': 'foto_clase',
      'label': 'Foto de clase',
      'icon': PhosphorIcons.student(PhosphorIconsStyle.fill),
      'description': 'Foto donde se vea el aula y alumnos',
    },
    {
      'value': 'captura_aula',
      'label': 'Captura del aula',
      'icon': PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill),
      'description': 'Foto del pizarrón o proyector',
    },
    {
      'value': 'selfie_profesor',
      'label': 'Selfie con profesor',
      'icon': PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
      'description': 'Foto junto al docente de la clase',
    },
    {
      'value': 'lista_asistencia',
      'label': 'Lista de asistencia',
      'icon': PhosphorIcons.listChecks(PhosphorIconsStyle.fill),
      'description': 'Captura de la lista firmada',
    },
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEvidence() async {
    if (_selectedImage == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una imagen y tipo de evidencia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    final success = await attendanceProvider.submitEvidence(
      token: authProvider.token!,
      imageFile: _selectedImage!,
      tipoEvidencia: _selectedType!,
      descripcion: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia enviada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceProvider.error ?? 'Error al enviar evidencia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final remaining = attendanceProvider.remainingAttendances;
    final approved = attendanceProvider.approvedAttendancesCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verificar Asistencias',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFB21132),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB21132), Color(0xFFE83E8C)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progreso de verificación',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$approved de 6 asistencias aprobadas',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: approved / 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    remaining > 0
                        ? 'Necesitas $remaining asistencias más para crear comunidades'
                        : '¡Felicidades! Ya puedes crear comunidades',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image selector
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedImage != null ? const Color(0xFFB21132) : Colors.grey[300]!,
                    width: _selectedImage != null ? 2 : 1,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.camera(PhosphorIconsStyle.fill),
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Toca para subir evidencia',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Evidence type selector
            Text(
              'Tipo de evidencia',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ..._evidenceTypes.map((type) => _buildTypeOption(type)),
            const SizedBox(height: 24),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción opcional',
                hintText: 'Añade detalles sobre esta evidencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFB21132)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: attendanceProvider.isLoading ? null : _submitEvidence,
                icon: attendanceProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill)),
                label: Text(attendanceProvider.isLoading ? 'Enviando...' : 'Enviar evidencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB21132),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(Map<String, dynamic> type) {
    final isSelected = _selectedType == type['value'];
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB21132).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFB21132) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              type['icon'],
              color: isSelected ? const Color(0xFFB21132) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['label'],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFFB21132) : Colors.black,
                    ),
                  ),
                  Text(
                    type['description'],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFB21132),
              ),
          ],
        ),
      ),
    );
  }
}
