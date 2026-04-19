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
  final String? role; // 'user' or 'admin'
  final DateTime? fechaCreacion;
  final bool esAdmin;

  // Preferencias y privacidad
  final bool? notificacionesActivas;
  final bool? emailNotificaciones;
  final bool? notificacionesMenciones;
  final bool? modoOscuro;
  final bool? privacidadPerfilPublico;
  final bool? privacidadMostrarEmail;
  final String? idioma;

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
    this.role,
    this.fechaCreacion,
    this.esAdmin = false,
    this.notificacionesActivas,
    this.emailNotificaciones,
    this.notificacionesMenciones,
    this.modoOscuro,
    this.privacidadPerfilPublico,
    this.privacidadMostrarEmail,
    this.idioma,
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
      role: json['role'] ?? 'user',
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : null,
      esAdmin: (json['role'] == 'admin') || (json['es_admin'] ?? json['esAdmin'] ?? false),
      notificacionesActivas: json['notificaciones_activas'],
      emailNotificaciones: json['email_notificaciones'],
      notificacionesMenciones: json['notificaciones_menciones'],
      modoOscuro: json['modo_oscuro'],
      privacidadPerfilPublico: json['privacidad_perfil_publico'],
      privacidadMostrarEmail: json['privacidad_mostrar_email'],
      idioma: json['idioma'],
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
      'role': role,
      'notificaciones_activas': notificacionesActivas,
      'email_notificaciones': emailNotificaciones,
      'notificaciones_menciones': notificacionesMenciones,
      'modo_oscuro': modoOscuro,
      'privacidad_perfil_publico': privacidadPerfilPublico,
      'privacidad_mostrar_email': privacidadMostrarEmail,
      'idioma': idioma,
    };
  }
}
