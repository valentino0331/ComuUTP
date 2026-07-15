import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import 'dart:convert';

class StoryProvider with ChangeNotifier {
  List<StoryUser> _friendsStories = [];
  bool _loading = false;
  String? _error;
  StoryUser? _currentUserStories;

  List<StoryUser> get friendsStories => _friendsStories;
  bool get loading => _loading;
  String? get error => _error;
  StoryUser? get currentUserStories => _currentUserStories;

  // Obtener historias de amigos
  Future<void> fetchFriendsStories() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.get('/stories/friends', auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final historias = data['historias'] as List;
        _friendsStories =
            historias.map((h) => StoryUser.fromJson(h)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar historias';
        _friendsStories = [];
      }
    } catch (e) {
      _error = 'Error de conexión';
      _friendsStories = [];
    }

    _loading = false;
    notifyListeners();
  }

  // Crear historia
  Future<bool> createStory(String imagenUrl, {String? contenido}) async {
    try {
      final res = await ApiService.post(
        '/stories/create',
        {
          'imagen_url': imagenUrl,
          if (contenido != null) 'contenido': contenido,
        },
        auth: true,
      );

      if (res.statusCode == 201) {
        // Recargar historias
        await fetchFriendsStories();
        return true;
      } else {
        _error = 'Error al crear historia';
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión';
      return false;
    }
  }

  // Marcar historia como vista
  Future<bool> markStoryAsViewed(int storyId) async {
    try {
      final res = await ApiService.post(
        '/stories/mark-viewed',
        {'historia_id': storyId},
        auth: true,
      );

      if (res.statusCode == 200) {
        // Actualizar la historia en la lista
        for (var user in _friendsStories) {
          final storyIndex =
              user.historias.indexWhere((s) => s.id == storyId);
          if (storyIndex != -1) {
            final story = user.historias[storyIndex];
            user.historias[storyIndex] = Story(
              id: story.id,
              usuarioId: story.usuarioId,
              nombreUsuario: story.nombreUsuario,
              fotoPerfil: story.fotoPerfil,
              imagenUrl: story.imagenUrl,
              contenido: story.contenido,
              fechaCreacion: story.fechaCreacion,
              fechaExpiracion: story.fechaExpiracion,
              totalVistas: story.totalVistas + 1,
              yaVisto: true,
            );
            notifyListeners();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      _error = 'Error al marcar como vista';
      return false;
    }
  }

  // Obtener quiénes vieron mi historia
  Future<List<Viewer>> getStoryViewers(int storyId) async {
    try {
      final res = await ApiService.get(
        '/stories/viewers/$storyId',
        auth: true,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final vistas = data['vistas'] as List;
        return vistas.map((v) => Viewer.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      _error = 'Error al obtener vistas';
      return [];
    }
  }

  // Eliminar historia
  Future<bool> deleteStory(int storyId) async {
    try {
      final res = await ApiService.delete(
        '/stories/$storyId',
        auth: true,
      );

      if (res.statusCode == 200) {
        // Remover de la lista
        for (var user in _friendsStories) {
          user.historias.removeWhere((s) => s.id == storyId);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al eliminar historia';
      return false;
    }
  }
}
