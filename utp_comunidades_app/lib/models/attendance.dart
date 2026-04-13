class Attendance {
  final int id;
  final int usuarioId;
  final String cursoNombre;
  final DateTime fechaAsistencia;
  final String metodoVerificacion;
  final String estado;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.usuarioId,
    required this.cursoNombre,
    required this.fechaAsistencia,
    required this.metodoVerificacion,
    required this.estado,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      usuarioId: json['usuario_id'],
      cursoNombre: json['curso_nombre'],
      fechaAsistencia: DateTime.parse(json['fecha_asistencia']),
      metodoVerificacion: json['metodo_verificacion'] ?? 'evidencia',
      estado: json['estado'] ?? 'pendiente',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isApproved => estado == 'aprobada';
  bool get isPending => estado == 'pendiente';
  bool get isRejected => estado == 'rechazada';

  String get estadoTexto {
    switch (estado) {
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return 'En revisión';
    }
  }

  String get estadoColor {
    switch (estado) {
      case 'aprobada':
        return '#4CAF50';
      case 'rechazada':
        return '#F44336';
      default:
        return '#FF9800';
    }
  }
}

class AttendanceEvidence {
  final int id;
  final int asistenciaId;
  final int usuarioId;
  final String tipoEvidencia;
  final String urlEvidencia;
  final String? descripcion;
  final String estado;
  final int? revisadoPor;
  final DateTime? fechaRevision;
  final DateTime createdAt;

  AttendanceEvidence({
    required this.id,
    required this.asistenciaId,
    required this.usuarioId,
    required this.tipoEvidencia,
    required this.urlEvidencia,
    this.descripcion,
    required this.estado,
    this.revisadoPor,
    this.fechaRevision,
    required this.createdAt,
  });

  factory AttendanceEvidence.fromJson(Map<String, dynamic> json) {
    return AttendanceEvidence(
      id: json['id'],
      asistenciaId: json['asistencia_id'],
      usuarioId: json['usuario_id'],
      tipoEvidencia: json['tipo_evidencia'],
      urlEvidencia: json['url_evidencia'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'pendiente',
      revisadoPor: json['revisado_por'],
      fechaRevision: json['fecha_revision'] != null 
          ? DateTime.parse(json['fecha_revision']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get tipoTexto {
    switch (tipoEvidencia) {
      case 'foto_clase':
        return 'Foto de clase';
      case 'captura_aula':
        return 'Captura del aula';
      case 'selfie_profesor':
        return 'Selfie con profesor';
      case 'lista_asistencia':
        return 'Lista de asistencia';
      default:
        return 'Evidencia';
    }
  }
}
