// filepath: backend/src/controllers/liga.controller.js
const pool = require('../config/db');

// Obtener todas las ligas
exports.getLigas = async (req, res) => {
  try {
    const communityId = req.query.comunidad_id;
    let query = `SELECT * FROM ligas WHERE estado = 'activa'`;
    const params = [];

    if (communityId) {
      query += ` AND comunidad_id = $${params.length + 1}`;
      params.push(communityId);
    }

    query += ` ORDER BY fecha_inicio DESC`;

    const result = await pool.query(query, params);
    res.json({ ligas: result.rows });
  } catch (err) {
    console.error('Error al obtener ligas:', err);
    res.status(500).json({ error: 'Error al obtener ligas' });
  }
};

// Obtener detalle de una liga
exports.getLiga = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM ligas WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Liga no encontrada' });
    }

    res.json({ liga: result.rows[0] });
  } catch (err) {
    console.error('Error al obtener liga:', err);
    res.status(500).json({ error: 'Error al obtener liga' });
  }
};

// Crear nueva liga (solo admin o creador de comunidad)
exports.createLiga = async (req, res) => {
  try {
    const { nombre, descripcion, comunidad_id, tipo, fecha_fin, premio_descripcion } = req.body;
    const usuario_id = req.user.id;

    // Verificar permisos
    if (comunidad_id) {
      const comunidad = await pool.query(
        'SELECT usuario_creador_id FROM comunidades WHERE id = $1',
        [comunidad_id]
      );
      if (comunidad.rows.length === 0) {
        return res.status(404).json({ error: 'Comunidad no encontrada' });
      }
      if (comunidad.rows[0].usuario_creador_id !== usuario_id && req.user.role !== 'admin') {
        return res.status(403).json({ error: 'No tienes permiso para crear ligas en esta comunidad' });
      }
    } else if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Solo admins pueden crear ligas globales' });
    }

    const result = await pool.query(
      `INSERT INTO ligas (nombre, descripcion, comunidad_id, tipo, fecha_fin, premio_descripcion, creador_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [nombre, descripcion, comunidad_id || null, tipo || 'general', fecha_fin, premio_descripcion, usuario_id]
    );

    // Log
    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [usuario_id, 'crear_liga', `Liga: ${nombre}`]
    );

    res.status(201).json({ liga: result.rows[0] });
  } catch (err) {
    console.error('Error al crear liga:', err);
    res.status(500).json({ error: 'Error al crear liga' });
  }
};

// Actualizar liga
exports.updateLiga = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, descripcion, estado, fecha_fin, premio_descripcion } = req.body;
    const usuario_id = req.user.id;

    // Verificar permisos
    const liga = await pool.query('SELECT creador_id FROM ligas WHERE id = $1', [id]);
    if (liga.rows.length === 0) {
      return res.status(404).json({ error: 'Liga no encontrada' });
    }

    if (liga.rows[0].creador_id !== usuario_id && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'No tienes permiso para editar esta liga' });
    }

    const result = await pool.query(
      `UPDATE ligas SET nombre = $1, descripcion = $2, estado = $3, fecha_fin = $4, premio_descripcion = $5, updated_at = NOW()
       WHERE id = $6 RETURNING *`,
      [nombre, descripcion, estado, fecha_fin, premio_descripcion, id]
    );

    res.json({ liga: result.rows[0] });
  } catch (err) {
    console.error('Error al actualizar liga:', err);
    res.status(500).json({ error: 'Error al actualizar liga' });
  }
};

// Obtener miembros/participantes de una liga
exports.getLigaParticipantes = async (req, res) => {
  try {
    const { id } = req.params;
    const limit = parseInt(req.query.limit) || 100;
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      `SELECT 
        rl.usuario_id,
        u.nombre,
        u.foto_perfil,
        rl.puntos_totales,
        rl.duelos_jugados,
        rl.duelos_ganados,
        rl.tasa_victoria,
        rl.posicion
      FROM ranking_ligas rl
      JOIN usuarios u ON rl.usuario_id = u.id
      WHERE rl.liga_id = $1
      ORDER BY rl.posicion ASC
      LIMIT $2 OFFSET $3`,
      [id, limit, offset]
    );

    const countResult = await pool.query(
      'SELECT COUNT(*) FROM ranking_ligas WHERE liga_id = $1',
      [id]
    );

    res.json({
      participantes: result.rows,
      total: parseInt(countResult.rows[0].count),
    });
  } catch (err) {
    console.error('Error al obtener participantes:', err);
    res.status(500).json({ error: 'Error al obtener participantes' });
  }
};
