const pool = require('../config/db');

exports.create = async (req, res) => {
  const { nombre, descripcion } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO comunidades (nombre, descripcion, creador_id) VALUES ($1, $2, $3) RETURNING *',
      [nombre, descripcion, req.user.id]
    );
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comunidad', `Comunidad: ${nombre}`]);
    res.status(201).json({ comunidad: result.rows[0] });
  } catch (err) {
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
