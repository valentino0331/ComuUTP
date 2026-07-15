const pool = require('../config/db');

// Crear una nueva historia
exports.create = async (req, res) => {
  const { imagen_url, contenido } = req.body;
  const usuario_id = req.user.id;
  
  try {
    // Calcular fecha de expiración (24 horas)
    const fecha_creacion = new Date();
    const fecha_expiracion = new Date(fecha_creacion.getTime() + 24 * 60 * 60 * 1000);

    const result = await pool.query(
      `INSERT INTO historias (usuario_id, imagen_url, contenido, fecha_creacion, fecha_expiracion) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [usuario_id, imagen_url, contenido, fecha_creacion, fecha_expiracion]
    );

    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [usuario_id, 'crear_historia', `Historia creada por ${usuario_id}`]
    );

    res.status(201).json({ historia: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear historia' });
  }
};

// Obtener historias de amigos (solo las vigentes - no expiradas)
exports.getFriendsStories = async (req, res) => {
  const usuario_id = req.user.id;
  
  try {
    // Primero obtener lista de amigos del usuario
    const friendsResult = await pool.query(
      `SELECT amigo_id FROM amistades 
       WHERE usuario_id = $1 AND estado = 'aceptada'
       UNION
       SELECT usuario_id FROM amistades 
       WHERE amigo_id = $1 AND estado = 'aceptada'`,
      [usuario_id]
    );

    const amigosIds = friendsResult.rows.map(row => row.amigo_id || row.usuario_id);

    if (amigosIds.length === 0) {
      return res.json({ historias: [] });
    }

    // Obtener historias vigentes de los amigos
    const storiesResult = await pool.query(
      `SELECT 
        h.id,
        h.usuario_id,
        h.imagen_url,
        h.contenido,
        h.fecha_creacion,
        h.fecha_expiracion,
        u.nombre as nombre_usuario,
        u.foto_perfil,
        (SELECT COUNT(*) FROM historia_vistas WHERE historia_id = h.id) as total_vistas,
        EXISTS(SELECT 1 FROM historia_vistas WHERE historia_id = h.id AND usuario_id = $1) as ya_visto
       FROM historias h
       JOIN usuarios u ON h.usuario_id = u.id
       WHERE h.usuario_id = ANY($2::int[])
       AND h.fecha_expiracion > NOW()
       ORDER BY h.fecha_creacion DESC`,
      [usuario_id, amigosIds]
    );

    // Organizar historias por usuario
    const historiasAgrupadas = {};
    storiesResult.rows.forEach(historia => {
      if (!historiasAgrupadas[historia.usuario_id]) {
        historiasAgrupadas[historia.usuario_id] = {
          usuario_id: historia.usuario_id,
          nombre_usuario: historia.nombre_usuario,
          foto_perfil: historia.foto_perfil,
          historias: []
        };
      }
      historiasAgrupadas[historia.usuario_id].historias.push(historia);
    });

    res.json({ historias: Object.values(historiasAgrupadas) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener historias' });
  }
};

// Marcar una historia como vista
exports.markAsViewed = async (req, res) => {
  const { historia_id } = req.body;
  const usuario_id = req.user.id;

  try {
    // Verificar si ya fue vista
    const existeVista = await pool.query(
      'SELECT * FROM historia_vistas WHERE historia_id = $1 AND usuario_id = $2',
      [historia_id, usuario_id]
    );

    if (existeVista.rows.length === 0) {
      await pool.query(
        'INSERT INTO historia_vistas (historia_id, usuario_id, fecha_vista) VALUES ($1, $2, NOW())',
        [historia_id, usuario_id]
      );
    }

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al marcar historia como vista' });
  }
};

// Obtener quiénes vieron una historia (solo el propietario puede verlo)
exports.getViewers = async (req, res) => {
  const { historia_id } = req.params;
  const usuario_id = req.user.id;

  try {
    // Verificar que sea el propietario
    const historia = await pool.query(
      'SELECT * FROM historias WHERE id = $1',
      [historia_id]
    );

    if (historia.rows.length === 0) {
      return res.status(404).json({ error: 'Historia no encontrada' });
    }

    if (historia.rows[0].usuario_id !== usuario_id) {
      return res.status(403).json({ error: 'No autorizado' });
    }

    // Obtener vistas
    const vistas = await pool.query(
      `SELECT 
        hv.usuario_id,
        hv.fecha_vista,
        u.nombre,
        u.foto_perfil
       FROM historia_vistas hv
       JOIN usuarios u ON hv.usuario_id = u.id
       WHERE hv.historia_id = $1
       ORDER BY hv.fecha_vista DESC`,
      [historia_id]
    );

    res.json({ vistas: vistas.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener vistas' });
  }
};

// Eliminar historia (solo propietario o después de expiración)
exports.delete = async (req, res) => {
  const { historia_id } = req.params;
  const usuario_id = req.user.id;

  try {
    const historia = await pool.query(
      'SELECT * FROM historias WHERE id = $1',
      [historia_id]
    );

    if (historia.rows.length === 0) {
      return res.status(404).json({ error: 'Historia no encontrada' });
    }

    if (historia.rows[0].usuario_id !== usuario_id) {
      return res.status(403).json({ error: 'No autorizado' });
    }

    await pool.query('DELETE FROM historias WHERE id = $1', [historia_id]);
    await pool.query('DELETE FROM historia_vistas WHERE historia_id = $1', [historia_id]);

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al eliminar historia' });
  }
};

// Limpiar historias expiradas (se ejecuta periódicamente)
exports.cleanExpired = async (req, res) => {
  try {
    await pool.query(
      'DELETE FROM historias WHERE fecha_expiracion < NOW()'
    );
    res.json({ success: true, message: 'Historias expiradas eliminadas' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al limpiar historias' });
  }
};
