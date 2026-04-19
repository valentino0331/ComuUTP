// Modelo de Historia (24 horas de duración)
module.exports = {
  id: Number,
  usuario_id: Number,
  imagen_url: String,
  contenido: String, // Texto adicional opcional
  fecha_creacion: Date,
  fecha_expiracion: Date, // Automáticamente 24 horas después de creación
  vistas: [
    {
      usuario_id: Number,
      fecha_vista: Date
    }
  ]
};
