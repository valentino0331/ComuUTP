class PremiumSubscription {
  final int id;
  final int usuarioId;
  final double monto;
  final String metodoPago;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? comprobantePagoUrl;
  final DateTime createdAt;

  PremiumSubscription({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    this.comprobantePagoUrl,
    required this.createdAt,
  });

  factory PremiumSubscription.fromJson(Map<String, dynamic> json) {
    return PremiumSubscription(
      id: json['id'],
      usuarioId: json['usuario_id'],
      monto: (json['monto'] ?? 50.0).toDouble(),
      metodoPago: json['metodo_pago'] ?? 'tarjeta',
      estado: json['estado'] ?? 'activa',
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      comprobantePagoUrl: json['comprobante_pago_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isActive => estado == 'activa' && DateTime.now().isBefore(fechaFin);
  bool get isExpired => DateTime.now().isAfter(fechaFin);
  bool get isCancelled => estado == 'cancelada';

  String get metodoPagoTexto {
    switch (metodoPago) {
      case 'tarjeta':
        return '💳 Tarjeta';
      case 'yape':
        return '📱 Yape';
      case 'plin':
        return '📱 Plin';
      case 'transferencia':
        return '🏦 Transferencia';
      default:
        return metodoPago;
    }
  }

  String get tiempoRestante {
    final remaining = fechaFin.difference(DateTime.now());
    if (remaining.inDays > 30) {
      return '${(remaining.inDays / 30).floor()} meses restantes';
    } else if (remaining.inDays > 0) {
      return '${remaining.inDays} días restantes';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} horas restantes';
    } else {
      return 'Expira hoy';
    }
  }
}

class PremiumPlan {
  final String nombre;
  final double precio;
  final String duracion;
  final List<String> beneficios;
  final String? descripcion;

  const PremiumPlan({
    required this.nombre,
    required this.precio,
    required this.duracion,
    required this.beneficios,
    this.descripcion,
  });

  static const List<PremiumPlan> planes = [
    PremiumPlan(
      nombre: 'Mensual',
      precio: 50.0,
      duracion: '1 mes',
      descripcion: 'Ideal para probar todas las funciones premium',
      beneficios: [
        '✅ Crear comunidades ilimitadas',
        '✅ Sin necesidad de verificar asistencias',
        '✅ Insignia premium en perfil',
        '✅ Historias destacadas',
        '✅ Soporte prioritario',
      ],
    ),
    PremiumPlan(
      nombre: 'Semestre',
      precio: 250.0,
      duracion: '6 meses',
      descripcion: 'Ahorra 50 soles con el plan semestral',
      beneficios: [
        '✅ Todo lo del plan mensual',
        '✅ 2 meses GRATIS',
        '✅ Acceso anticipado a nuevas funciones',
        '✅ Badge exclusivo de fundador',
      ],
    ),
    PremiumPlan(
      nombre: 'Anual',
      precio: 450.0,
      duracion: '12 meses',
      descripcion: 'La mejor opción - Ahorra 150 soles',
      beneficios: [
        '✅ Todo lo del plan semestral',
        '✅ 3 meses GRATIS',
        '✅ Invitaciones especiales a eventos',
        '✅ Posibilidad de ser moderador',
        '✅ Analytics de tu perfil',
      ],
    ),
  ];
}
