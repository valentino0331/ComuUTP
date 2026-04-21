import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import 'dart:convert';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Comment> _comments = [];
  List<Comment> _userAddedComments = []; // Persist user comments
  bool _loading = false;
  String? _error;
  Set<int> _likedPosts = {};
  int? _currentPostId;

  List<Post> get posts => _posts;
  List<Comment> get comments => _comments;
  bool get loading => _loading;
  String? get error => _error;
  int? get currentPostId => _currentPostId;

  bool isPostLiked(int postId) => _likedPosts.contains(postId);

  int getCommentCount(int postId) {
    final userCount = _userAddedComments.where((c) => c.publicacionId == postId).length;
    return userCount;
  }

  Future<void> fetchPostsByCommunity(int comunidadId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.get('/posts/community/$comunidadId');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['publicaciones'] as List;
        _posts = data.map((p) => Post.fromJson(p)).toList();
      } else {
        _posts = [];
      }
    } catch (e) {
      _posts = [];
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<bool> createPost(int comunidadId, String contenido) async {
    final res = await ApiService.post('/posts', {
      'comunidad_id': comunidadId,
      'contenido': contenido,
    }, auth: true);
    if (res.statusCode == 201) {
      await fetchPostsByCommunity(comunidadId);
      return true;
    }
    return false;
  }

  void toggleLike(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      if (_likedPosts.contains(postId)) {
        _likedPosts.remove(postId);
        _posts[index] = Post(
          id: post.id,
          usuarioId: post.usuarioId,
          comunidadId: post.comunidadId,
          contenido: post.contenido,
          fecha: post.fecha,
          nombreUsuario: post.nombreUsuario,
          nombreComunidad: post.nombreComunidad,
          likes: (post.likes ?? 0) - 1,
          comentarios: post.comentarios,
        );
      } else {
        _likedPosts.add(postId);
        _posts[index] = Post(
          id: post.id,
          usuarioId: post.usuarioId,
          comunidadId: post.comunidadId,
          contenido: post.contenido,
          fecha: post.fecha,
          nombreUsuario: post.nombreUsuario,
          nombreComunidad: post.nombreComunidad,
          likes: (post.likes ?? 0) + 1,
          comentarios: post.comentarios,
        );
      }
      notifyListeners();
    }
  }

  void addComment(int postId, String contenido, String nombreUsuario) {
    final now = DateTime.now();
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch, // Unique ID
      usuarioId: 1,
      publicacionId: postId,
      contenido: contenido,
      fecha: now,
    );
    _userAddedComments.add(newComment);
    _comments.add(newComment);
    _comments.sort((a, b) => b.fecha.compareTo(a.fecha)); // Newest first
    
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = Post(
        id: post.id,
        usuarioId: post.usuarioId,
        comunidadId: post.comunidadId,
        contenido: post.contenido,
        fecha: post.fecha,
        nombreUsuario: post.nombreUsuario,
        nombreComunidad: post.nombreComunidad,
        likes: post.likes,
        comentarios: (post.comentarios ?? 0) + 1,
      );
    }
    notifyListeners();
  }

  void loadCommentsForPost(int postId) {
    _currentPostId = postId;
    final userComments = _userAddedComments.where((c) => c.publicacionId == postId).toList();
    _comments = userComments;
    _comments.sort((a, b) => b.fecha.compareTo(a.fecha)); // Newest first
    notifyListeners();
  }

  Future<void> fetchAllPosts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.get('/posts', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['publicaciones'] as List;
        _posts = data.map((p) => Post.fromJson(p)).toList();
      } else {
        _posts = [];
      }
    } catch (e) {
      print('Error fetching posts: $e');
      _posts = [];
    }
    
    _loading = false;
    notifyListeners();
  }

  void setFilteredPosts(List<Post> filteredPosts) {
    _posts = filteredPosts;
    notifyListeners();
  }

  Future<bool> deletePost(int postId) async {
    try {
      final res = await ApiService.delete('/posts/$postId', auth: true);
      if (res.statusCode == 200 || res.statusCode == 204) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }
}
