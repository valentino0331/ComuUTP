import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StoryCreatorScreen extends StatefulWidget {
  const StoryCreatorScreen({super.key});

  @override
  State<StoryCreatorScreen> createState() => _StoryCreatorScreenState();
}

class _StoryCreatorScreenState extends State<StoryCreatorScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (pickedFile != null) {
        // En una app real, aquí procesaríamos el video
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video seleccionado (30s max)')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar contenido',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB21132).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    PhosphorIcons.camera,
                    color: Color(0xFFB21132),
                  ),
                ),
                title: const Text(
                  'Cámara',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Tomar una foto',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    PhosphorIcons.image,
                    color: Colors.blue,
                  ),
                ),
                title: const Text(
                  'Galería de fotos',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Seleccionar de tu galería',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    PhosphorIcons.videoCamera,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Máximo 30 segundos',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _publishStory() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen primero')),
      );
      return;
    }

    // Aquí iría la lógica para publicar la historia
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historia publicada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB21132),
              ),
            )
          : _selectedImage == null
              ? _buildSelectionView()
              : _buildPreviewView(),
    );
  }

  Widget _buildSelectionView() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const Spacer(),
                const Text(
                  'Tu Historia',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          const Spacer(),

          // Icono grande
          Icon(
            PhosphorIcons.imageSquare,
            size: 120,
            color: Colors.grey[800],
          ),

          const SizedBox(height: 24),

          Text(
            'Comparte un momento',
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Montserrat',
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Selecciona una foto o video',
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
              fontSize: 14,
            ),
          ),

          const Spacer(),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(PhosphorIcons.camera),
                  label: const Text('Tomar foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB21132),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showMediaOptions,
                  icon: const Icon(PhosphorIcons.image),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen seleccionada
        Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),

        // Overlay oscuro en la parte superior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() => _selectedImage = null);
                    },
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  // Botón de stickers/texto (simulado)
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Agregar texto/stickers - Próximamente')),
                      );
                    },
                    icon: const Icon(
                      PhosphorIcons.sticker,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Botón de dibujo (simulado)
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dibujar - Próximamente')),
                      );
                    },
                    icon: const Icon(
                      PhosphorIcons.pencilSimple,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Input de caption en la parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // TextField para caption
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Agregar descripción...',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón de publicar
                  ElevatedButton.icon(
                    onPressed: _publishStory,
                    icon: const Icon(PhosphorIcons.paperPlaneRight),
                    label: const Text('Publicar historia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB21132),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
