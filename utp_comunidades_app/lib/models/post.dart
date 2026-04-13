class Post {
  final int id;
  final int usuarioId;
  final int comunidadId;
  final String contenido;
  final DateTime fecha;
  final String? nombreUsuario;
  final String? nombreComunidad;
  final int? likes;
  final int? comentarios;

  Post({
    required this.id,
    required this.usuarioId,
    required this.comunidadId,
    required this.contenido,
    required this.fecha,
    this.nombreUsuario,
    this.nombreComunidad,
    this.likes,
    this.comentarios,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      usuarioId: json['usuario_id'],
      comunidadId: json['comunidad_id'],
      contenido: json['contenido'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      nombreUsuario: json['nombre_usuario'] ?? 'Usuario',
      nombreComunidad: json['nombre_comunidad'] ?? 'Comunidad',
      likes: json['likes'] ?? 0,
      comentarios: json['comentarios'] ?? 0,
    );
  }
}
