import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(post.contenido, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Por usuario ${post.usuarioId} • ${post.fecha.toString().split('.')[0]}', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: onTap,
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
        },
      ),
    );
  }
}
