const pool = require('../config/db');

exports.create = async (req, res) => {
  const { nombre, descripcion } = req.body;
  try {
    console.log('CREATE COMMUNITY REQUEST:', { nombre, descripcion, userId: req.user.id });
    
    // Validar que los campos no estén vacíos
    if (!nombre || !descripcion) {
      return res.status(400).json({ error: 'Nombre y descripción son requeridos' });
    }

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

    // Crear la comunidad
    const result = await pool.query(
      'INSERT INTO comunidades (nombre, descripcion, usuario_creador_id) VALUES ($1, $2, $3) RETURNING *',
      [nombre, descripcion, req.user.id]
    );
    
    const comunidadId = result.rows[0].id;
    
    // Agregar al creador automáticamente como miembro
    try {
      await pool.query(
        'INSERT INTO miembros_comunidad (usuario_id, comunidad_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [req.user.id, comunidadId]
      );
      console.log('User added as member of created community');
    } catch (err) {
      console.log('Error adding user as member:', err.message);
    }
    
    // Log the action
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comunidad', `Comunidad: ${nombre}`]);
    
    console.log('COMMUNITY CREATED:', result.rows[0]);
    res.status(201).json({ comunidad: result.rows[0] });
  } catch (err) {
    console.error('Error creating community - FULL ERROR:', err);
    console.error('Error message:', err.message);
    console.error('Error code:', err.code);
    res.status(500).json({ error: 'Error al crear comunidad', details: err.message });
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
