class Comment {
  final int id;
  final int usuarioId;
  final int publicacionId;
  final String contenido;
  final DateTime fecha;

  Comment({required this.id, required this.usuarioId, required this.publicacionId, required this.contenido, required this.fecha});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      usuarioId: json['usuario_id'],
      publicacionId: json['publicacion_id'],
      contenido: json['contenido'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }
}
