import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;
  String _selectedCategory = 'Académica';
  bool _isPrivate = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Académica',
    'Deportes',
    'Arte y Cultura',
    'Tecnología',
    'Ocio',
    'Negocios',
    'Otros'
  ];

  static const Color colorPrimario = Color(0xFFB21132);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _rulesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorPrimario,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Icon(
            PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Crear Comunidad',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildCard(
              title: 'Información básica',
              icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
              child: Column(
                children: [
                  // Avatar selector
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorPrimario.withOpacity(0.1),
                            border: Border.all(
                              color: colorPrimario,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                            size: 50,
                            color: colorPrimario,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorPrimario,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              PhosphorIcons.camera(PhosphorIconsStyle.regular),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre de la comunidad',
                    hint: 'Ej: Desarrollo Web',
                    icon: PhosphorIcons.usersThree(PhosphorIconsStyle.regular),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'El nombre es necesario';
                      if (v.length < 3) return 'Mínimo 3 caracteres';
                      if (v.length > 50) return 'Máximo 50 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Descripción',
                    hint: 'Cuéntanos sobre tu comunidad',
                    icon: PhosphorIcons.textAlignLeft(PhosphorIconsStyle.regular),
                    maxLines: 4,
                    maxLength: 300,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'La descripción es necesaria';
                      if (v.length < 10) return 'Mínimo 10 caracteres';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Configuración',
              icon: PhosphorIcons.gear(PhosphorIconsStyle.fill),
              child: Column(
                children: [
                  // Categoría
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  // Privacidad
                  _buildPrivacySwitch(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Reglas (opcional)',
              icon: PhosphorIcons.scroll(PhosphorIconsStyle.fill),
              child: _buildTextField(
                controller: _rulesController,
                label: 'Reglas de la comunidad',
                hint: 'Define las reglas de tu comunidad',
                icon: PhosphorIcons.listBullets(PhosphorIconsStyle.regular),
                maxLines: 4,
                maxLength: 500,
              ),
            ),
            const SizedBox(height: 16),
            _buildTermsBanner(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Montserrat'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: colorPrimario),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorPrimario, width: 1),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.fill), color: colorPrimario),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.black87,
          ),
          items: _categories.map((cat) => DropdownMenuItem(
            value: cat,
            child: Row(
              children: [
                Icon(PhosphorIcons.folder(PhosphorIconsStyle.regular), color: colorPrimario, size: 20),
                const SizedBox(width: 8),
                Text(cat),
              ],
            ),
          )).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v ?? 'Académica'),
        ),
      ),
    );
  }

  Widget _buildPrivacySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isPrivate ? PhosphorIcons.lockKey(PhosphorIconsStyle.fill) : PhosphorIcons.globe(PhosphorIconsStyle.fill),
                color: colorPrimario,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comunidad privada',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPrivate
                        ? 'Solo puedes citar a miembros'
                        : 'Cualquiera puede unirse',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isPrivate,
            onChanged: (v) => setState(() => _isPrivate = v),
            activeColor: colorPrimario,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorPrimario.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: colorPrimario, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTermsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Al crear esta comunidad, aceptas nuestros términos de servicio y reglas de comunidad.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular)),
            label: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createCommunity,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(PhosphorIcons.check(PhosphorIconsStyle.bold)),
            label: Text(
              _isLoading ? 'Creando...' : 'Crear Comunidad',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimario,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createCommunity() async {
    if (_formKey.currentState!.validate()) {
      // Verificar asistencias o premium
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      final user = authProvider.user;
      final canCreate = user?.esPremium == true || 
                        attendanceProvider.canCreateCommunity ||
                        (user?.puedeCrearComunidad == true);
      
      if (!canCreate) {
        final remaining = attendanceProvider.remainingAttendances;
        _showNeedAttendancesDialog(remaining);
        return;
      }
      
      setState(() => _isLoading = true);
      try {
        final success = await Provider.of<CommunityProvider>(context, listen: false)
            .createCommunity(
              _nameController.text,
              _descriptionController.text,
            );

        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Comunidad creada exitosamente!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al crear la comunidad'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNeedAttendancesDialog(int remaining) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.fill), color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Asistencias requeridas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Necesitas 6 asistencias verificadas para crear una comunidad.',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 8),
            Text(
              'Te faltan $remaining asistencias.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ve a tu perfil y selecciona "Verificar asistencias" para subir tus evidencias.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/submit_attendance');
            },
            icon: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)),
            label: const Text('Verificar asistencias'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB21132),
            ),
          ),
        ],
      ),
    );
  }
}
