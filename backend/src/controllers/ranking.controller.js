// filepath: backend/src/controllers/ranking.controller.js
const pool = require('../config/db');

// Obtener ranking general (top 100)
exports.getRankingGeneral = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      `SELECT * FROM ranking_general LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    const countResult = await pool.query('SELECT COUNT(*) FROM ranking_general');

    res.json({
      ranking: result.rows,
      total: parseInt(countResult.rows[0].count),
    });
  } catch (err) {
    console.error('Error al obtener ranking general:', err);
    res.status(500).json({ error: 'Error al obtener ranking' });
  }
};

// Obtener ranking por comunidad
exports.getRankingComunidad = async (req, res) => {
  try {
    const { comunidad_id } = req.params;
    const limit = parseInt(req.query.limit) || 100;
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      `SELECT * FROM ranking_por_comunidad WHERE comunidad_id = $1 LIMIT $2 OFFSET $3`,
      [comunidad_id, limit, offset]
    );

    const countResult = await pool.query(
      'SELECT COUNT(*) FROM ranking_por_comunidad WHERE comunidad_id = $1',
      [comunidad_id]
    );

    res.json({
      ranking: result.rows,
      total: parseInt(countResult.rows[0].count),
    });
  } catch (err) {
    console.error('Error al obtener ranking por comunidad:', err);
    res.status(500).json({ error: 'Error al obtener ranking' });
  }
};

// Obtener ranking de una liga específica
exports.getRankingLiga = async (req, res) => {
  try {
    const { liga_id } = req.params;
    const limit = parseInt(req.query.limit) || 100;
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      `SELECT 
        rl.usuario_id,
        rl.posicion,
        rl.puntos_totales,
        rl.duelos_jugados,
        rl.duelos_ganados,
        rl.tasa_victoria,
        u.nombre,
        u.foto_perfil,
        u.email
       FROM ranking_ligas rl
       JOIN usuarios u ON rl.usuario_id = u.id
       WHERE rl.liga_id = $1
       ORDER BY rl.posicion ASC
       LIMIT $2 OFFSET $3`,
      [liga_id, limit, offset]
    );

    const countResult = await pool.query(
      'SELECT COUNT(*) FROM ranking_ligas WHERE liga_id = $1',
      [liga_id]
    );

    res.json({
      ranking: result.rows,
      total: parseInt(countResult.rows[0].count),
    });
  } catch (err) {
    console.error('Error al obtener ranking de liga:', err);
    res.status(500).json({ error: 'Error al obtener ranking' });
  }
};

// Obtener mi posición en una liga
exports.getMiPosicion = async (req, res) => {
  try {
    const { liga_id } = req.params;
    const usuario_id = req.user.id;

    const result = await pool.query(
      `SELECT 
        rl.usuario_id,
        rl.posicion,
        rl.puntos_totales,
        rl.duelos_jugados,
        rl.duelos_ganados,
        rl.tasa_victoria,
        u.nombre,
        u.foto_perfil
       FROM ranking_ligas rl
       JOIN usuarios u ON rl.usuario_id = u.id
       WHERE rl.liga_id = $1 AND rl.usuario_id = $2`,
      [liga_id, usuario_id]
    );

    if (result.rows.length === 0) {
      return res.json({
        posicion: null,
        mensaje: 'No participas en esta liga aún',
      });
    }

    res.json({ posicion: result.rows[0] });
  } catch (err) {
    console.error('Error al obtener mi posición:', err);
    res.status(500).json({ error: 'Error al obtener posición' });
  }
};

// Obtener insignias del usuario en una liga
exports.getMisInsignias = async (req, res) => {
  try {
    const usuario_id = req.user.id;

    const result = await pool.query(
      `SELECT 
        i.id,
        i.nombre,
        i.descripcion,
        i.icono_url,
        i.tipo,
        ui.fecha_obtenida
       FROM usuario_insignias ui
       JOIN insignias i ON ui.insignia_id = i.id
       WHERE ui.usuario_id = $1
       ORDER BY ui.fecha_obtenida DESC`,
      [usuario_id]
    );

    res.json({ insignias: result.rows });
  } catch (err) {
    console.error('Error al obtener insignias:', err);
    res.status(500).json({ error: 'Error al obtener insignias' });
  }
};

// Obtener estadísticas del usuario
exports.getMisEstadisticas = async (req, res) => {
  try {
    const usuario_id = req.user.id;

    // Estadísticas generales
    const statsResult = await pool.query(
      `SELECT 
        COUNT(DISTINCT liga_id) as ligas_participadas,
        SUM(puntos_totales) as puntos_totales,
        SUM(duelos_jugados) as duelos_jugados,
        SUM(duelos_ganados) as duelos_ganados,
        ROUND(AVG(tasa_victoria)::NUMERIC, 2) as tasa_victoria_promedio
       FROM ranking_ligas
       WHERE usuario_id = $1`,
      [usuario_id]
    );

    // Mis duelos recientes
    const duelosResult = await pool.query(
      `SELECT * FROM duelos 
       WHERE (usuario1_id = $1 OR usuario2_id = $1)
       AND estado = 'finalizado'
       ORDER BY fecha_fin DESC
       LIMIT 10`,
      [usuario_id]
    );

    // Mis insignias
    const insigniasResult = await pool.query(
      `SELECT COUNT(*) as total FROM usuario_insignias WHERE usuario_id = $1`,
      [usuario_id]
    );

    res.json({
      estadisticas: statsResult.rows[0],
      duelos_recientes: duelosResult.rows,
      insignias_totales: parseInt(insigniasResult.rows[0].total),
    });
  } catch (err) {
    console.error('Error al obtener estadísticas:', err);
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
};
