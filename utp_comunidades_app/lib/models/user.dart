class User {
  final int id;
  final String email;
  final String nombre;

  User({required this.id, required this.email, required this.nombre});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
    );
  }
}
