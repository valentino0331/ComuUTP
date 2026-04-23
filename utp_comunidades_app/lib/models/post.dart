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
  final int? comunidadCreadorId;

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
    this.comunidadCreadorId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      int parseToInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return Post(
        id: parseToInt(json['id']),
        usuarioId: parseToInt(json['usuario_id']),
        comunidadId: parseToInt(json['comunidad_id']),
        contenido: json['contenido']?.toString() ?? 'Sin contenido',
        fecha: DateTime.parse(json['fecha']?.toString() ?? DateTime.now().toIso8601String()),
        nombreUsuario: json['nombre_usuario']?.toString() ?? 'Usuario',
        nombreComunidad: json['nombre_comunidad']?.toString() ?? 'Comunidad',
        likes: parseToInt(json['likes']),
        comentarios: parseToInt(json['comentarios']),
        comunidadCreadorId: parseToInt(json['comunidad_creador_id']),
      );
    } catch (e) {
      print('Error parsing post: $e, json: $json');
      rethrow;
    }
  }
}
