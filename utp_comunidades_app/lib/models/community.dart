class Community {
  final int id;
  final String nombre;
  final String descripcion;
  final String? imagen;
  final int? miembros;
  final int? posts;
  final bool? esMiembro;
  final String? creador;
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
    this.fechaCreacion,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      miembros: json['miembros'] ?? 0,
      posts: json['posts'] ?? 0,
      esMiembro: json['esMiembro'] ?? false,
      creador: json['creador'],
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : null,
    );
  }
}
