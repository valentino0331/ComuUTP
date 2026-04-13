class Story {
  final int id;
  final int usuarioId;
  final String? nombreUsuario;
  final String? fotoPerfil;
  final String tipoContenido; // 'imagen', 'video', 'texto'
  final String? urlContenido;
  final String? textoContenido;
  final String? colorFondo;
  final DateTime createdAt;
  final DateTime expiraAt;
  final int viewCount;
  final bool hasViewed;

  Story({
    required this.id,
    required this.usuarioId,
    this.nombreUsuario,
    this.fotoPerfil,
    required this.tipoContenido,
    this.urlContenido,
    this.textoContenido,
    this.colorFondo,
    required this.createdAt,
    required this.expiraAt,
    this.viewCount = 0,
    this.hasViewed = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombreUsuario: json['nombre_usuario'],
      fotoPerfil: json['foto_perfil'],
      tipoContenido: json['tipo_contenido'] ?? 'imagen',
      urlContenido: json['url_contenido'],
      textoContenido: json['texto_contenido'],
      colorFondo: json['color_fondo'],
      createdAt: DateTime.parse(json['created_at']),
      expiraAt: DateTime.parse(json['expira_at']),
      viewCount: json['view_count'] ?? 0,
      hasViewed: json['has_viewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre_usuario': nombreUsuario,
      'foto_perfil': fotoPerfil,
      'tipo_contenido': tipoContenido,
      'url_contenido': urlContenido,
      'texto_contenido': textoContenido,
      'color_fondo': colorFondo,
      'created_at': createdAt.toIso8601String(),
      'expira_at': expiraAt.toIso8601String(),
      'view_count': viewCount,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiraAt);
  
  String get timeRemaining {
    final remaining = expiraAt.difference(DateTime.now());
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h restantes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m restantes';
    } else {
      return 'Expira pronto';
    }
  }
}
