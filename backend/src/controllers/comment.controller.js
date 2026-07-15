const pool = require('../config/db');

exports.create = async (req, res) => {
  const { publicacion_id, contenido } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO comentarios (usuario_id, publicacion_id, contenido) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, publicacion_id, contenido]
    );
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comentario', `Comentario en publicación ${publicacion_id}`]);
    res.status(201).json({ comentario: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al crear comentario' });
  }
};

exports.delete = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;

  try {
    // Verificar que el comentario existe
    const comment = await pool.query(
      'SELECT usuario_id FROM comentarios WHERE id = $1',
      [id]
    );

    if (comment.rows.length === 0) {
      return res.status(404).json({ error: 'Comentario no encontrado' });
    }

    // Verificar permisos: autor o admin
    const isAuthor = comment.rows[0].usuario_id === userId;
    const isAdmin = req.user.role === 'admin';

    if (!isAuthor && !isAdmin) {
      return res.status(403).json({ error: 'No tienes permiso para eliminar este comentario' });
    }

    // Eliminar el comentario
    await pool.query('DELETE FROM comentarios WHERE id = $1', [id]);

    // Log de acción
    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [userId, 'eliminar_comentario', `Comentario ${id} eliminado`]
    );

    res.json({ message: 'Comentario eliminado' });
  } catch (err) {
    console.error('Error al eliminar comentario:', err);
    res.status(500).json({ error: 'Error al eliminar comentario' });
  }
};

exports.update = async (req, res) => {
  const { id } = req.params;
  const { contenido } = req.body;
  const userId = req.user.id;

  try {
    // Verificar que el comentario existe
    const comment = await pool.query(
      'SELECT usuario_id FROM comentarios WHERE id = $1',
      [id]
    );

    if (comment.rows.length === 0) {
      return res.status(404).json({ error: 'Comentario no encontrado' });
    }

    // Verificar permisos: solo el autor puede editar
    if (comment.rows[0].usuario_id !== userId) {
      return res.status(403).json({ error: 'No tienes permiso para editar este comentario' });
    }

    // Actualizar el comentario
    const result = await pool.query(
      'UPDATE comentarios SET contenido = $1, actualizado_en = NOW() WHERE id = $2 RETURNING *',
      [contenido, id]
    );

    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [userId, 'editar_comentario', `Comentario ${id} actualizado`]
    );

    res.json({ comentario: result.rows[0], message: 'Comentario actualizado' });
  } catch (err) {
    console.error('Error al actualizar comentario:', err);
    res.status(500).json({ error: 'Error al actualizar comentario' });
  }
};
