import '../models/user.dart';
import '../models/post.dart';
import '../models/community.dart';
import '../models/notification.dart';
import '../models/comment.dart';

/// Generador de datos - vacío para usar solo datos del backend
class MockData {
  
  // Usuarios - vacío, usar backend
  static List<User> getUsers() {
    return [];
  }

  // Comunidades - vacío, usar backend
  static List<Community> getCommunities() {
    return [];
  }

  // Posts - vacío, usar backend
  static List<Post> getPosts() {
    return [];
  }

  // Comentarios - vacío, usar backend
  static List<Comment> getComments() {
    return [];
  }

  // Notificaciones - vacío, usar backend
  static List<NotificationModel> getNotifications() {
    return [];
  }
}
