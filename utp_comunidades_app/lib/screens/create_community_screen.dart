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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Comunidad'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                const Text(
                  'Detalles de la Comunidad',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa todos los campos para crear una comunidad exitosa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre de la Comunidad
                _buildSectionTitle('Nombre de la Comunidad'),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Programadores UTP',
                    prefixIcon: Icon(PhosphorIconsRegular.textAa, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
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
                  decoration: InputDecoration(
                    prefixIcon: Icon(PhosphorIconsRegular.list, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
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
                  decoration: InputDecoration(
                    hintText: 'Una frase que resuma el propósito de la comunidad',
                    prefixIcon: Icon(PhosphorIconsRegular.textT, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
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
                  decoration: InputDecoration(
                    hintText: 'Explica qué hace tu comunidad, quiénes son bienvenidos, y qué esperas lograr',
                    prefixIcon: Icon(PhosphorIconsRegular.notepad, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
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
                  decoration: InputDecoration(
                    hintText: '1. Sé respetuoso con los demás\n2. No compartas contenido inapropiado\n3. Participa activamente',
                    prefixIcon: Icon(PhosphorIconsRegular.shieldCheck, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
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
                  decoration: InputDecoration(
                    hintText: 'Ej: Lunes a viernes 5-6 PM, Reuniones el sábado a las 3 PM',
                    prefixIcon: Icon(PhosphorIconsRegular.clock, color: AppTheme.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Crear
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'CREAR COMUNIDAD',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
