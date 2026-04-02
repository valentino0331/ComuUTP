import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(title: const Text('Crear publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Selecciona una comunidad'),
                value: comunidadId,
                items: communities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: (val) => setState(() => comunidadId = val),
              ),
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: '¿Qué quieres compartir?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => contenido = v,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Campo requerido',
              ),
              const SizedBox(height: 24),
              if (error != null) ...[
                Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : () {
                    if (_formKey.currentState!.validate()) createPost();
                  },
                  child: loading ? const CircularProgressIndicator() : const Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
