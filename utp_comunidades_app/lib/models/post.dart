class Post {
  final int id;
  final int usuarioId;
  final int comunidadId;
  final String contenido;
  final DateTime fecha;

  Post({required this.id, required this.usuarioId, required this.comunidadId, required this.contenido, required this.fecha});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      usuarioId: json['usuario_id'],
      comunidadId: json['comunidad_id'],
      contenido: json['contenido'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }
}
