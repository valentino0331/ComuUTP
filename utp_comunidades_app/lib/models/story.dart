class Story {
  final int id;
  final int usuarioId;
  final String? nombreUsuario;
  final String? fotoPerfil;
  final String imagenUrl;
  final String? contenido;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  final int totalVistas;
  final bool yaVisto;

  Story({
    required this.id,
    required this.usuarioId,
    this.nombreUsuario,
    this.fotoPerfil,
    required this.imagenUrl,
    this.contenido,
    required this.fechaCreacion,
    required this.fechaExpiracion,
    this.totalVistas = 0,
    this.yaVisto = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      nombreUsuario: json['nombre_usuario'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      imagenUrl: json['imagen_url'] as String,
      contenido: json['contenido'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaExpiracion: DateTime.parse(json['fecha_expiracion'] as String),
      totalVistas: json['total_vistas'] as int? ?? 0,
      yaVisto: json['ya_visto'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre_usuario': nombreUsuario,
      'foto_perfil': fotoPerfil,
      'imagen_url': imagenUrl,
      'contenido': contenido,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_expiracion': fechaExpiracion.toIso8601String(),
      'total_vistas': totalVistas,
      'ya_visto': yaVisto,
    };
  }

  bool get isExpired => DateTime.now().isAfter(fechaExpiracion);
  
  String get timeRemaining {
    final remaining = fechaExpiracion.difference(DateTime.now());
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h restantes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m restantes';
    } else {
      return 'Expira pronto';
    }
  }
}

class StoryUser {
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoPerfil;
  final List<Story> historias;

  StoryUser({
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoPerfil,
    required this.historias,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      usuarioId: json['usuario_id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      historias: (json['historias'] as List)
          .map((h) => Story.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre_usuario': nombreUsuario,
      'foto_perfil': fotoPerfil,
      'historias': historias.map((h) => h.toJson()).toList(),
    };
  }
}

class Viewer {
  final int usuarioId;
  final String nombre;
  final String? fotoPerfil;
  final DateTime fechaVista;

  Viewer({
    required this.usuarioId,
    required this.nombre,
    this.fotoPerfil,
    required this.fechaVista,
  });

  factory Viewer.fromJson(Map<String, dynamic> json) {
    return Viewer(
      usuarioId: json['usuario_id'] as int,
      nombre: json['nombre'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      fechaVista: DateTime.parse(json['fecha_vista'] as String),
    );
  }
}
