import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/post_provider.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String contenido = '';
  int? comunidadId;
  bool loading = false;
  String? error;

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
  Widget build(BuildContext context) {
    final communities = Provider.of<CommunityProvider>(context).communities;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Formulario
            SliverToBoxAdapter(
              child: _buildForm(communities),
            ),
          ],
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

  Widget _buildForm(List communities) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
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
              Text(
                'Seleccionar comunidad',
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Selecciona una comunidad',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey[400],
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
                    items: communities.map<DropdownMenuItem<int>>((c) => DropdownMenuItem<int>(
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
                            Text(
                              c.nombre,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
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
                    label: 'Imagen',
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildAttachmentButton(
                    icon: PhosphorIcons.link(PhosphorIconsStyle.regular),
                    label: 'Link',
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildAttachmentButton(
                    icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                    label: 'Cámara',
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
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
