import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/user.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _careerController;
  
  File? _profileImage;
  File? _coverImage;
  
  final List<String> _availableInterests = [
    'Tecnología', 'Deportes', 'Música', 'Arte', 'Ciencia',
    'Lectura', 'Cine', 'Viajes', 'Gastronomía', 'Fotografía',
    'Videojuegos', 'Voluntariado', 'Emprendimiento', 'Idiomas', 'Baile'
  ];
  
  late final List<String> _selectedInterests;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user data if available
    _nameController = TextEditingController(text: widget.user?.nombre ?? '');
    _usernameController = TextEditingController(text: widget.user?.email?.split('@').first ?? '');
    _bioController = TextEditingController(text: widget.user?.biografia ?? '');
    _careerController = TextEditingController(text: widget.user?.carrera ?? '');
    _selectedInterests = [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 5) {
        _selectedInterests.add(interest);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo 5 intereses')),
        );
      }
    });
  }

  void _showImagePickerOptions(bool isProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isProfile ? 'Foto de perfil' : 'Foto de portada',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(PhosphorIcons.camera(), color: Color(0xFFB21132)),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de tomar foto próximamente')),
                  );
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.image(), color: Color(0xFFB21132)),
                title: const Text(
                  'Elegir de la galería',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de galería próximamente')),
                  );
                },
              ),
              if ((isProfile && _profileImage != null) || (!isProfile && _coverImage != null))
                ListTile(
                  leading: Icon(PhosphorIcons.trash(), color: Colors.red),
                  title: const Text(
                    'Eliminar foto',
                    style: TextStyle(fontFamily: 'Montserrat', color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      if (isProfile) {
                        _profileImage = null;
                      } else {
                        _coverImage = null;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFB21132),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            title: const Text(
              'Editar perfil',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  final success = await authProvider.updateProfile(
                    nombre: _nameController.text.trim(),
                    bio: _bioController.text.trim(),
                    carrera: _careerController.text.trim(),
                    gustos: _selectedInterests,
                  );

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perfil actualizado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${authProvider.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(false),
                    child: Container(
                      color: Colors.grey[800],
                      child: _coverImage != null
                          ? Image.file(_coverImage!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFFB21132).withOpacity(0.8),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.camera(),
                                      color: Colors.white.withOpacity(0.5),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Agregar foto de portada',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _showImagePickerOptions(true),
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _profileImage != null
                                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          PhosphorIcons.user(),
                                          size: 36,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB21132),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Nombre'),
              _buildTextField(
                controller: _nameController,
                hintText: 'Tu nombre completo',
                icon: PhosphorIcons.user(),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Nombre de usuario'),
              _buildTextField(
                controller: _usernameController,
                hintText: '@usuario',
                icon: PhosphorIcons.at(),
                prefix: '@',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Biografía'),
              _buildTextField(
                controller: _bioController,
                hintText: 'Cuéntanos sobre ti...',
                icon: PhosphorIcons.textAlignLeft(),
                maxLines: 3,
                maxLength: 150,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Carrera'),
              _buildTextField(
                controller: _careerController,
                hintText: 'Tu carrera universitaria',
                icon: PhosphorIcons.graduationCap(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(PhosphorIcons.heart(), color: const Color(0xFFB21132), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Intereses',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedInterests.length}/5',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona lo que te gusta (máx. 5)',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return ChoiceChip(
                    label: Text(
                      interest,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFB21132),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => _toggleInterest(interest),
                  );
                }).toList(),
              ),
              if (_selectedInterests.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Seleccionados:',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedInterests.map((interest) {
                    return Chip(
                      label: Text(
                        interest,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFFB21132),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () => _toggleInterest(interest),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? prefix,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFB21132), size: 22),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontFamily: 'Montserrat',
          color: Color(0xFFB21132),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFFB21132), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }
}
