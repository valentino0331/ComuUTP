const pool = require('../config/db');

exports.create = async (req, res) => {
  const { nombre, descripcion } = req.body;
  try {
    // Check if user has permission to create community
    const user = await pool.query('SELECT puede_crear_comunidad FROM usuarios WHERE id = $1', [req.user.id]);
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (!user.rows[0].puede_crear_comunidad) {
      return res.status(403).json({ 
        error: 'No tienes permiso para crear comunidades. Contacta a un administrador.',
      });
    }

    const result = await pool.query(
      'INSERT INTO comunidades (nombre, descripcion, usuario_creador_id) VALUES ($1, $2, $3) RETURNING *',
      [nombre, descripcion, req.user.id]
    );
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comunidad', `Comunidad: ${nombre}`]);
    res.status(201).json({ comunidad: result.rows[0] });
  } catch (err) {
    console.error('Error creating community:', err.message);
    res.status(500).json({ error: 'Error al crear comunidad' });
  }
};

exports.list = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM comunidades');
    res.json({ comunidades: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Error al listar comunidades' });
  }
};

exports.join = async (req, res) => {
  const { comunidad_id } = req.body;
  try {
    await pool.query('INSERT INTO miembros_comunidad (usuario_id, comunidad_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [req.user.id, comunidad_id]);
    res.json({ message: 'Unido a la comunidad' });
  } catch (err) {
    res.status(500).json({ error: 'Error al unirse a la comunidad' });
  }
};
