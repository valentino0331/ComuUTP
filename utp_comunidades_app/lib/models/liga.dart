// filepath: utp_comunidades_app/lib/models/liga.dart
class Liga {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? comunidadId;
  final String tipo;
  final String estado;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String? premioDescripcion;

  Liga({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.comunidadId,
    required this.tipo,
    required this.estado,
    required this.fechaInicio,
    this.fechaFin,
    this.premioDescripcion,
  });

  factory Liga.fromJson(Map<String, dynamic> json) {
    return Liga(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      comunidadId: json['comunidad_id'] as int?,
      tipo: json['tipo'] as String? ?? 'general',
      estado: json['estado'] as String? ?? 'activa',
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin'] as String) : null,
      premioDescripcion: json['premio_descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'comunidad_id': comunidadId,
      'tipo': tipo,
      'estado': estado,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'premio_descripcion': premioDescripcion,
    };
  }
}

class Duelo {
  final int id;
  final int ligaId;
  final int usuario1Id;
  final int usuario2Id;
  final String? tema;
  final String estado;
  final int puntosUsuario1;
  final int puntosUsuario2;
  final int? ganadorId;
  final DateTime fechaInicio;
  final DateTime? fechaFin;

  Duelo({
    required this.id,
    required this.ligaId,
    required this.usuario1Id,
    required this.usuario2Id,
    this.tema,
    required this.estado,
    required this.puntosUsuario1,
    required this.puntosUsuario2,
    this.ganadorId,
    required this.fechaInicio,
    this.fechaFin,
  });

  factory Duelo.fromJson(Map<String, dynamic> json) {
    return Duelo(
      id: json['id'] as int,
      ligaId: json['liga_id'] as int,
      usuario1Id: json['usuario1_id'] as int,
      usuario2Id: json['usuario2_id'] as int,
      tema: json['tema'] as String?,
      estado: json['estado'] as String,
      puntosUsuario1: json['puntos_usuario1'] as int? ?? 0,
      puntosUsuario2: json['puntos_usuario2'] as int? ?? 0,
      ganadorId: json['ganador_id'] as int?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin'] as String) : null,
    );
  }
}

class RankingUsuario {
  final int usuarioId;
  final String nombre;
  final String? fotoPerfil;
  final int posicion;
  final int puntosTotales;
  final int duelosJugados;
  final int duelosGanados;
  final double tasaVictoria;
  final List<String>? insignias;

  RankingUsuario({
    required this.usuarioId,
    required this.nombre,
    this.fotoPerfil,
    required this.posicion,
    required this.puntosTotales,
    required this.duelosJugados,
    required this.duelosGanados,
    required this.tasaVictoria,
    this.insignias,
  });

  factory RankingUsuario.fromJson(Map<String, dynamic> json) {
    return RankingUsuario(
      usuarioId: json['usuario_id'] as int,
      nombre: json['nombre'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      posicion: json['posicion'] as int,
      puntosTotales: json['puntos_totales'] as int,
      duelosJugados: json['duelos_jugados'] as int,
      duelosGanados: json['duelos_ganados'] as int,
      tasaVictoria: (json['tasa_victoria'] as num?)?.toDouble() ?? 0.0,
      insignias: (json['insignias'] as List?)?.cast<String>(),
    );
  }
}
