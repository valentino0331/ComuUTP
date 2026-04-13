class Follower {
  final int id;
  final int seguidorId;
  final int seguidoId;
  final String estado;
  final DateTime createdAt;
  
  // Info del usuario seguidor (para mostrar en "me siguen")
  final String? seguidorNombre;
  final String? seguidorFotoPerfil;
  final String? seguidorBiografia;
  
  // Info del usuario seguido (para mostrar en "siguiendo")
  final String? seguidoNombre;
  final String? seguidoFotoPerfil;
  final String? seguidoBiografia;

  Follower({
    required this.id,
    required this.seguidorId,
    required this.seguidoId,
    required this.estado,
    required this.createdAt,
    this.seguidorNombre,
    this.seguidorFotoPerfil,
    this.seguidorBiografia,
    this.seguidoNombre,
    this.seguidoFotoPerfil,
    this.seguidoBiografia,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'],
      seguidorId: json['seguidor_id'],
      seguidoId: json['seguido_id'],
      estado: json['estado'] ?? 'pendiente',
      createdAt: DateTime.parse(json['created_at']),
      seguidorNombre: json['seguidor_nombre'],
      seguidorFotoPerfil: json['seguidor_foto_perfil'],
      seguidorBiografia: json['seguidor_biografia'],
      seguidoNombre: json['seguido_nombre'],
      seguidoFotoPerfil: json['seguido_foto_perfil'],
      seguidoBiografia: json['seguido_biografia'],
    );
  }

  bool get isPending => estado == 'pendiente';
  bool get isAccepted => estado == 'aceptado';
  bool get isRejected => estado == 'rechazado';

  String get estadoTexto {
    switch (estado) {
      case 'aceptado':
        return 'Amigos';
      case 'pendiente':
        return 'Pendiente';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  // Si el seguidor es amigo del usuario actual (mutuo seguimiento)
  bool get isMutual => estado == 'aceptado';
}

class SharedPost {
  final int id;
  final int usuarioId;
  final int publicacionOriginalId;
  final int comunidadOrigenId;
  final String? comentarioCompartido;
  final DateTime createdAt;
  
  // Info de la publicación original
  final String? contenidoOriginal;
  final String? autorOriginal;
  final String? comunidadOrigenNombre;

  SharedPost({
    required this.id,
    required this.usuarioId,
    required this.publicacionOriginalId,
    required this.comunidadOrigenId,
    this.comentarioCompartido,
    required this.createdAt,
    this.contenidoOriginal,
    this.autorOriginal,
    this.comunidadOrigenNombre,
  });

  factory SharedPost.fromJson(Map<String, dynamic> json) {
    return SharedPost(
      id: json['id'],
      usuarioId: json['usuario_id'],
      publicacionOriginalId: json['publicacion_original_id'],
      comunidadOrigenId: json['comunidad_origen_id'],
      comentarioCompartido: json['comentario_compartido'],
      createdAt: DateTime.parse(json['created_at']),
      contenidoOriginal: json['contenido_original'],
      autorOriginal: json['autor_original'],
      comunidadOrigenNombre: json['comunidad_origen_nombre'],
    );
  }
}
