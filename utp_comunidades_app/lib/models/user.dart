class User {
  final int id;
  final String email;
  final String nombre;
  final String? apellido;
  final String? carrera;
  final int? ciclo;
  final String? biografia;
  final String? fotoPerfil;
  final int? postsCount;
  final int? comunidadesCount;
  final int? seguidoresCount;
  final int? seguidosCount;
  final bool esPremium;
  final DateTime? premiumHasta;
  final bool puedeCrearComunidad;
  final int? asistenciasVerificadas;
  final DateTime? fechaCreacion;
  final bool esAdmin;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellido,
    this.carrera,
    this.ciclo,
    this.biografia,
    this.fotoPerfil,
    this.postsCount,
    this.comunidadesCount,
    this.seguidoresCount,
    this.seguidosCount,
    this.esPremium = false,
    this.premiumHasta,
    this.puedeCrearComunidad = false,
    this.asistenciasVerificadas,
    this.fechaCreacion,
    this.esAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      carrera: json['carrera'],
      ciclo: json['ciclo'],
      biografia: json['biografia'],
      fotoPerfil: json['foto_perfil'] ?? json['fotoPerfil'],
      postsCount: json['posts_count'] ?? json['postsCount'] ?? 0,
      comunidadesCount: json['comunidades_count'] ?? json['comunidadesCount'] ?? 0,
      seguidoresCount: json['seguidores_count'] ?? json['seguidoresCount'] ?? 0,
      seguidosCount: json['seguidos_count'] ?? json['seguidosCount'] ?? 0,
      esPremium: json['es_premium'] ?? json['esPremium'] ?? false,
      premiumHasta: json['premium_hasta'] != null 
          ? DateTime.parse(json['premium_hasta']) 
          : null,
      puedeCrearComunidad: json['puede_crear_comunidad'] ?? json['puedeCrearComunidad'] ?? false,
      asistenciasVerificadas: json['asistencias_verificadas'] ?? json['asistenciasVerificadas'] ?? 0,
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : null,
      esAdmin: json['es_admin'] ?? json['esAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'carrera': carrera,
      'ciclo': ciclo,
      'biografia': biografia,
      'foto_perfil': fotoPerfil,
      'posts_count': postsCount,
      'comunidades_count': comunidadesCount,
      'seguidores_count': seguidoresCount,
      'seguidos_count': seguidosCount,
      'es_premium': esPremium,
      'premium_hasta': premiumHasta?.toIso8601String(),
      'puede_crear_comunidad': puedeCrearComunidad,
      'asistencias_verificadas': asistenciasVerificadas,
    };
  }
}
