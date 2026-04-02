class Community {
  final int id;
  final String nombre;
  final String descripcion;

  Community({required this.id, required this.nombre, required this.descripcion});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}
