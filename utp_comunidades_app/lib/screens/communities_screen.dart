import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';

class CommunitiesScreen extends StatefulWidget {
  final List<Community> communities;
  const CommunitiesScreen({super.key, required this.communities});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombreComunidad = '';
  String descripcionComunidad = '';
  bool creando = false;

  Future<void> createCommunity() async {
    setState(() { creando = true; });
    final success = await Provider.of<CommunityProvider>(context, listen: false)
        .createCommunity(nombreComunidad, descripcionComunidad);
    setState(() { creando = false; });
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comunidad creada')));
    }
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nueva comunidad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => nombreComunidad = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => descripcionComunidad = v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: creando ? null : () {
                    if (_formKey.currentState!.validate()) createCommunity();
                  },
                  child: creando ? const CircularProgressIndicator() : const Text('Crear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communities = Provider.of<CommunityProvider>(context).communities;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: communities.isEmpty
          ? const Center(child: Text('No hay comunidades'))
          : ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, i) {
                final c = communities[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.descripcion),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Provider.of<CommunityProvider>(context, listen: false).joinCommunity(c.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Te uniste a la comunidad')));
                      },
                      child: const Text('Unirse'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
