class Message {
  final int id;
  final int usuarioId;
  final int comunidadId;
  final String contenido;
  final DateTime fecha;

  Message({required this.id, required this.usuarioId, required this.comunidadId, required this.contenido, required this.fecha});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      usuarioId: json['usuario_id'],
      comunidadId: json['comunidad_id'],
      contenido: json['contenido'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }
}
