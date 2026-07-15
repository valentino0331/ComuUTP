class NotificationModel {
  final int id;
  final int usuarioId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String? imagenUrl;
  final DateTime fechaCreacion;
  final bool leida;
  final int? referenciaId;

  NotificationModel({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.imagenUrl,
    required this.fechaCreacion,
    required this.leida,
    this.referenciaId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      usuarioId: json['usuario_id'] ?? json['usuarioId'],
      tipo: json['tipo'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'],
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? json['fechaCreacion']),
      leida: json['leida'] ?? false,
      referenciaId: json['referencia_id'] ?? json['referenciaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'imagen_url': imagenUrl,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'leida': leida,
      'referencia_id': referenciaId,
    };
  }
}
