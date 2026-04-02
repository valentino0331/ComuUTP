import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/comment_provider.dart';
import '../providers/like_provider.dart';
import '../providers/report_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool liked = false;
  String? reportReason;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false).fetchComments(widget.post.id);
    });
  }

  Future<void> addComment() async {
    if (_commentController.text.isEmpty) return;
    final success = await Provider.of<CommentProvider>(context, listen: false)
        .createComment(widget.post.id, _commentController.text);
    if (success && mounted) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario agregado')));
    }
  }

  Future<void> likePost() async {
    final success = await Provider.of<LikeProvider>(context, listen: false).likePost(widget.post.id);
    if (success && mounted) {
      setState(() => liked = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Like agregado')));
    }
  }

  Future<void> reportPost() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar publicación'),
        content: TextField(
          onChanged: (v) => reportReason = v,
          decoration: const InputDecoration(labelText: 'Motivo del reporte'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (reportReason != null && reportReason!.isNotEmpty) {
                final success = await Provider.of<ReportProvider>(context, listen: false)
                    .reportContent('publicacion', widget.post.id, reportReason!);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado')));
                }
              }
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicación'),
        actions: [
          IconButton(icon: const Icon(Icons.flag), onPressed: reportPost),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario ${widget.post.usuarioId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(widget.post.contenido, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
                        onPressed: likePost,
                      ),
                      const SizedBox(width: 8),
                      Text(liked ? '1 like' : '0 likes'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          commentProvider.loading
              ? const Center(child: CircularProgressIndicator())
              : commentProvider.comments.isEmpty
                  ? const Text('No hay comentarios aún')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentProvider.comments.length,
                      itemBuilder: (context, i) {
                        final comment = commentProvider.comments[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Usuario ${comment.usuarioId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(comment.contenido),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Agregar comentario',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: addComment,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
