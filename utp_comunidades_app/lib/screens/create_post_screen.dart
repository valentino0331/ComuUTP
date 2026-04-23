import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/post_provider.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String contenido = '';
  int? comunidadId;
  bool loading = false;
  String? error;
  File? _selectedImage;
  String? _imageFileName;
  List<dynamic> _myCommunities = [];
  bool _loadingCommunities = true;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageFileName = pickedFile.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagen seleccionada: ${pickedFile.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageFileName = null;
    });
  }

  Future<void> createPost() async {
    if (comunidadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una comunidad')));
      return;
    }
    setState(() { loading = true; error = null; });
    final success = await Provider.of<PostProvider>(context, listen: false).createPost(comunidadId!, contenido);
    setState(() { loading = false; });
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicación creada')));
    } else {
      setState(() { error = 'No se pudo crear la publicación'; });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyCommunities();
  }

  Future<void> _loadMyCommunities() async {
    setState(() => _loadingCommunities = true);
    final communities = await Provider.of<CommunityProvider>(context, listen: false).getMyCommunities();
    setState(() {
      _myCommunities = communities;
      _loadingCommunities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Crear publicación',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.x(PhosphorIconsStyle.bold),
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFB21132),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Crear publicación',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              PhosphorIcons.x(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    // Mostrar estado de carga
    if (_loadingCommunities) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFB21132)),
            SizedBox(height: 16),
            Text(
              'Cargando tus comunidades...',
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Mostrar estado vacío si no sigue ninguna comunidad
    if (_myCommunities.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                  size: 48,
                  color: const Color(0xFFB21132),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No sigues ninguna comunidad',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Únete a comunidades para poder publicar en ellas',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navegar a comunidades
                  Navigator.pushNamed(context, '/main');
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explorar comunidades'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB21132),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de comunidad
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Seleccionar comunidad',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // Badge con cantidad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB21132).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_myCommunities.length} comunidad${_myCommunities.length != 1 ? 'es' : ''}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB21132),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Selecciona una comunidad',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    value: comunidadId,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                        color: Colors.grey[400],
                      ),
                    ),
                    items: _myCommunities.map<DropdownMenuItem<int>>((c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                              size: 18,
                              color: const Color(0xFFB21132),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.nombre,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) => setState(() => comunidadId = val),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Campo de contenido
              Text(
                'Contenido',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextFormField(
                  maxLines: 8,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: '¿Qué quieres compartir con la comunidad?',
                    hintStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (v) => contenido = v,
                  validator: (v) => v != null && v.isNotEmpty ? null : 'Escribe algo para publicar',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Opciones de adjunto
              Row(
                children: [
                  _buildAttachmentButton(
                    icon: PhosphorIcons.image(PhosphorIconsStyle.regular),
                    label: 'Galería',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 12),
                  _buildAttachmentButton(
                    icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                    label: 'Cámara',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedImage != null)
                    _buildAttachmentButton(
                      icon: PhosphorIcons.trash(PhosphorIconsStyle.regular),
                      label: 'Limpiar',
                      onTap: _removeImage,
                    ),
                ],
              ),
              
              // Preview de imagen seleccionada
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _imageFileName ?? 'Imagen',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Montserrat',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Error
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error!,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Botón publicar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : () {
                    if (_formKey.currentState!.validate()) createPost();
                  },
                  icon: loading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill)),
                  label: Text(
                    loading ? 'Publicando...' : 'Publicar',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB21132),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
