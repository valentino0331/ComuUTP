class Community {
  final int id;
  final String nombre;
  final String descripcion;
  final String? imagen;
  final int? miembros;
  final int? posts;
  final bool? esMiembro;
  final String? creador;
  final int? usuarioCreadorId;
  final DateTime? fechaCreacion;

  Community({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imagen,
    this.miembros,
    this.posts,
    this.esMiembro,
    this.creador,
    this.usuarioCreadorId,
    this.fechaCreacion,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return Community(
      id: parseToInt(json['id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? '',
      imagen: json['imagen'],
      miembros: parseToInt(json['total_miembros'] ?? json['miembros']),
      posts: parseToInt(json['total_posts'] ?? json['posts']),
      esMiembro: parseBool(json['es_miembro'] ?? json['esMiembro']),
      creador: json['creador'],
      usuarioCreadorId: parseToInt(json['usuario_creador_id']),
      fechaCreacion: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : (json['fechaCreacion'] != null ? DateTime.parse(json['fechaCreacion'].toString()) : null),
    );
  }
}
