import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _scheduleController = TextEditingController();
  String _selectedCategory = 'Académica';
  bool _isLoading = false;

  final List<String> _categories = [
    'Académica',
    'Deportes',
    'Arte y Cultura',
    'Tecnología',
    'Ocio',
    'Negocios',
    'Social',
    'Voluntariado'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fullDescription = '''
${_shortDescController.text}

DESCRIPCIÓN:
${_descriptionController.text}

REGLAS:
${_rulesController.text}

HORARIO:
${_scheduleController.text.isEmpty ? 'A definir' : _scheduleController.text}
''';

      final success = await Provider.of<CommunityProvider>(context, listen: false).createCommunity(
        _nameController.text.trim(),
        fullDescription.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Comunidad creada exitosamente!'),
            backgroundColor: AppTheme.colorPrimary,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la comunidad')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFB21132),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Comunidad',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFB21132),
                        const Color(0xFFD32F5A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Crear Comunidad',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completa los campos para crear tu comunidad',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre de la Comunidad
                _buildSectionTitle('Nombre de la Comunidad'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black87, fontFamily: 'Montserrat'),
                  decoration: InputDecoration(
                    hintText: 'Ej: Programadores UTP',
                    hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Montserrat'),
                    prefixIcon: Icon(PhosphorIcons.textAa(PhosphorIconsStyle.regular), color: const Color(0xFFB21132)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFB21132), width: 2),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    if (value.trim().length > 50) {
                      return 'El nombre no puede exceder 50 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Categoría
                _buildSectionTitle('Categoría'),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  style: const TextStyle(color: Colors.black87, fontFamily: 'Montserrat'),
                  decoration: InputDecoration(
                    prefixIcon: Icon(PhosphorIcons.list(PhosphorIconsStyle.regular), color: const Color(0xFFB21132)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFB21132), width: 2),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 20),

                // Descripción Corta
                _buildSectionTitle('Descripción Corta (Lema)'),
                TextFormField(
                  controller: _shortDescController,
                  maxLines: 2,
                  maxLength: 100,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Una frase que resuma el propósito de la comunidad',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(PhosphorIconsRegular.textT, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.white10,
                    filled: true,
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'La descripción corta debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Descripción Detallada
                _buildSectionTitle('Descripción Detallada'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Explica qué hace tu comunidad, quiénes son bienvenidos, y qué esperas lograr',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(PhosphorIconsRegular.notepad, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.white10,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 20) {
                      return 'La descripción debe tener al menos 20 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Reglas de la Comunidad
                _buildSectionTitle('Reglas de la Comunidad'),
                TextFormField(
                  controller: _rulesController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '1. Sé respetuoso con los demás\n2. No compartas contenido inapropiado\n3. Participa activamente',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(PhosphorIconsRegular.shieldCheck, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.white10,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Define al menos las reglas básicas de tu comunidad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Horario de Actividades (Opcional)
                _buildSectionTitle('Horario de Actividades (Opcional)'),
                TextFormField(
                  controller: _scheduleController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Ej: Lunes a viernes 5-6 PM, Reuniones el sábado a las 3 PM',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(PhosphorIconsRegular.clock, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.white10,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Crear
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFFB21132),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CREAR COMUNIDAD',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
