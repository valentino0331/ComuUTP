const pool = require('../config/db');

// Dar o quitar reacción a una publicación
exports.toggleReaction = async (req, res) => {
  const { publicacion_id, tipo } = req.body;
  const usuario_id = req.user.id;

  try {
    // Verificar si ya existe una reacción
    const existingReaction = await pool.query(
      'SELECT id, tipo FROM reacciones WHERE usuario_id = $1 AND publicacion_id = $2',
      [usuario_id, publicacion_id]
    );

    if (existingReaction.rows.length > 0) {
      // Si es el mismo tipo, eliminar la reacción (toggle off)
      if (existingReaction.rows[0].tipo === tipo) {
        await pool.query(
          'DELETE FROM reacciones WHERE id = $1',
          [existingReaction.rows[0].id]
        );
        return res.json({ action: 'removed', tipo: null });
      } else {
        // Si es diferente tipo, actualizar la reacción
        await pool.query(
          'UPDATE reacciones SET tipo = $1 WHERE id = $2',
          [tipo, existingReaction.rows[0].id]
        );
        return res.json({ action: 'updated', tipo });
      }
    } else {
      // Si no existe, crear nueva reacción
      await pool.query(
        'INSERT INTO reacciones (usuario_id, publicacion_id, tipo) VALUES ($1, $2, $3) RETURNING *',
        [usuario_id, publicacion_id, tipo]
      );
      return res.json({ action: 'added', tipo });
    }
  } catch (err) {
    console.error('Error al procesar reacción:', err.message);
    res.status(500).json({ error: 'Error al procesar reacción' });
  }
};

// Obtener reacciones de una publicación
exports.getPostReactions = async (req, res) => {
  const { publicacion_id } = req.params;

  try {
    const result = await pool.query(
      `SELECT 
        r.tipo,
        COUNT(*) as count,
        u.nombre as usuario_nombre,
        u.foto_perfil as usuario_foto
       FROM reacciones r
       JOIN usuarios u ON r.usuario_id = u.id
       WHERE r.publicacion_id = $1
       GROUP BY r.tipo, u.nombre, u.foto_perfil
       ORDER BY r.tipo`,
      [publicacion_id]
    );

    // Agrupar por tipo
    const reactionsByType = {};
    result.rows.forEach(row => {
      if (!reactionsByType[row.tipo]) {
        reactionsByType[row.tipo] = {
          tipo: row.tipo,
          count: 0,
          usuarios: []
        };
      }
      reactionsByType[row.tipo].count += parseInt(row.count);
      reactionsByType[row.tipo].usuarios.push({
        nombre: row.usuario_nombre,
        foto_perfil: row.usuario_foto
      });
    });

    res.json({ reacciones: Object.values(reactionsByType) });
  } catch (err) {
    console.error('Error al obtener reacciones:', err.message);
    res.status(500).json({ error: 'Error al obtener reacciones' });
  }
};

// Obtener reacción del usuario actual en una publicación
exports.getUserReaction = async (req, res) => {
  const { publicacion_id } = req.params;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'SELECT tipo FROM reacciones WHERE usuario_id = $1 AND publicacion_id = $2',
      [usuario_id, publicacion_id]
    );

    if (result.rows.length > 0) {
      res.json({ tipo: result.rows[0].tipo });
    } else {
      res.json({ tipo: null });
    }
  } catch (err) {
    console.error('Error al obtener reacción del usuario:', err.message);
    res.status(500).json({ error: 'Error al obtener reacción del usuario' });
  }
};
