import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';
import '../models/post.dart';

class PantallaFeed extends StatefulWidget {
  const PantallaFeed({super.key});

  @override
  State<PantallaFeed> createState() => _PantallaFeedState();
}

class _PantallaFeedState extends State<PantallaFeed> {
  @override
  void initState() {
    super.initState();
    // Cargar posts al iniciar
    Future.delayed(Duration.zero, () {
      context.read<PostProvider>().obtenerPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Comunidades'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () =>
                Navigator.of(context).pushNamed('/create_post'),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, proveedorPosts, _) {
          if (proveedorPosts.cargando) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.colorPrimary),
              ),
            );
          }

          if (proveedorPosts.error != null) {
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
                  Text(
                    'Error: ${proveedorPosts.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => proveedorPosts.obtenerPosts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (proveedorPosts.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppTheme.colorGris,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay posts aún',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.colorGris,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/create_post'),
                    child: const Text('Crear primer post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => proveedorPosts.obtenerPosts(),
            color: AppTheme.colorPrimary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: proveedorPosts.posts.length,
              itemBuilder: (context, indice) {
                final post = proveedorPosts.posts[indice];
                return TarjetaPost(post: post);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Tarjeta de publicación
class TarjetaPost extends StatelessWidget {
  final Post post;

  const TarjetaPost({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/post_detail',
        arguments: post.id,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado (Usuario y Comunidad)
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusStandard),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre y Comunidad
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.nombreUsuario ?? 'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.colorNegro,
                          ),
                        ),
                        Text(
                          '${post.nombreComunidad ?? 'Comunidad'} • ${_hace(post.fecha ?? DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.colorGris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menú
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reportar',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined,
                                size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Reportar'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (valor) {
                      if (valor == 'reportar') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post reportado'),
                            backgroundColor: AppTheme.colorPrimary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contenido
              Text(
                post.contenido ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.colorNegro,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Acciones (Like, Comentarios)
              Row(
                children: [
                  // Like
                  Expanded(
                    child: _BotónAcción(
                      icono: Icons.favorite_outline,
                      etiqueta: '${post.likes ?? 0}',
                      onTap: () {
                        // Agregar like
                      },
                    ),
                  ),
                  // Comentarios
                  Expanded(
                    child: _BotónAcción(
                      icono: Icons.comment_outlined,
                      etiqueta: '${post.comentarios ?? 0}',
                      onTap: () => Navigator.of(context).pushNamed(
                        '/post_detail',
                        arguments: post.id,
                      ),
                    ),
                  ),
                  // Compartir
                  Expanded(
                    child: _BotónAcción(
                      icono: Icons.share_outlined,
                      etiqueta: 'Compartir',
                      onTap: () {
                        // Compartir
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calcular hace cuánto tiempo
  String _hace(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inSeconds < 60) return 'Hace unos segundos';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes}m';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours}h';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays}d';
    if (diferencia.inDays < 30) return 'Hace ${(diferencia.inDays / 7).floor()}w';

    return 'Hace ${(diferencia.inDays / 30).floor()}m';
  }
}

/// Botón de acción (Like, Comentario, etc)
class _BotónAcción extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _BotónAcción({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 20,
              color: AppTheme.colorGris,
            ),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.colorGris,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
