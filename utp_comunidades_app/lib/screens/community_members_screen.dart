import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';

class PantallaMiembrosComunidad extends StatefulWidget {
  final int comunidadId;
  final String nombreComunidad;

  const PantallaMiembrosComunidad({
    super.key,
    required this.comunidadId,
    required this.nombreComunidad,
  });

  @override
  State<PantallaMiembrosComunidad> createState() =>
      _PantallaMiembrosComunidadState();
}

class _PantallaMiembrosComunidadState extends State<PantallaMiembrosComunidad> {
  late Future<List<Map<String, dynamic>>> _miembrosFuture;

  @override
  void initState() {
    super.initState();
    _miembrosFuture = context
        .read<CommunityProvider>()
        .getMembersOfCommunity(widget.comunidadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _miembrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.colorRojoUTP),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text('Error al cargar miembros'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _miembrosFuture = context
                            .read<CommunityProvider>()
                            .getMembersOfCommunity(widget.comunidadId);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final miembros = snapshot.data ?? [];

          if (miembros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.colorGris,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay miembros aún',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.colorGris,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: miembros.length,
            itemBuilder: (context, index) {
              final miembro = miembros[index];
              final nombre = miembro['nombre'] ?? 'Usuario';
              final email = miembro['email'] ?? '';
              final esCreador = miembro['es_creador'] ?? false;

              return _TarjetaMiembro(
                nombre: nombre,
                email: email,
                esCreador: esCreador,
              );
            },
          );
        },
      ),
    );
  }
}

/// Tarjeta individual de miembro
class _TarjetaMiembro extends StatelessWidget {
  final String nombre;
  final String email;
  final bool esCreador;

  const _TarjetaMiembro({
    required this.nombre,
    required this.email,
    required this.esCreador,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.colorRojoUTP,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '👤',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del miembro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.colorNegro,
                        ),
                      ),
                      if (esCreador) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.colorRojoUTP,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Creador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.colorGris,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Icono de información
            const Icon(
              Icons.info_outline,
              color: AppTheme.colorGris,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
