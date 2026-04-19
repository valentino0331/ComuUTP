const pool = require('../config/db');

// Middleware to check if user is admin
exports.checkIsAdmin = async (req, res, next) => {
  try {
    const user = await pool.query('SELECT role FROM usuarios WHERE id = $1', [req.user.id]);
    if (user.rows.length === 0 || user.rows[0].role !== 'admin') {
      return res.status(403).json({ error: 'Solo administradores pueden acceder' });
    }
    next();
  } catch (err) {
    res.status(500).json({ error: 'Error al verificar permisos' });
  }
};

// Get all users with pagination and search
exports.getAllUsers = async (req, res) => {
  try {
    const { search, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT id, email, nombre, role, puede_crear_comunidad, es_premium, email_verificado, created_at FROM usuarios';
    let countQuery = 'SELECT COUNT(*) FROM usuarios';
    const params = [];

    if (search) {
      const searchTerm = `%${search}%`;
      query += ' WHERE email ILIKE $1 OR nombre ILIKE $1';
      countQuery += ' WHERE email ILIKE $1 OR nombre ILIKE $1';
      params.push(searchTerm);
    }

    query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(limit, offset);

    const [usersResult, countResult] = await Promise.all([
      pool.query(query, params),
      pool.query(countQuery, search ? [params[0]] : []),
    ]);

    res.json({
      usuarios: usersResult.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(parseInt(countResult.rows[0].count) / limit),
    });
  } catch (err) {
    console.error('Error fetching users:', err.message);
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
};

// Get single user
exports.getUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await pool.query(
      'SELECT id, email, nombre, role, puede_crear_comunidad, es_premium, email_verificado, created_at FROM usuarios WHERE id = $1',
      [userId]
    );

    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({ usuario: user.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener usuario' });
  }
};

// Update user permissions
exports.updateUserPermissions = async (req, res) => {
  try {
    const { userId } = req.params;
    const { puede_crear_comunidad, role } = req.body;

    // Validate role
    if (role && !['user', 'admin'].includes(role)) {
      return res.status(400).json({ error: 'Rol inválido' });
    }

    // Build dynamic update query
    const updates = [];
    const params = [];
    let paramCount = 1;

    if (puede_crear_comunidad !== undefined) {
      updates.push(`puede_crear_comunidad = $${paramCount}`);
      params.push(puede_crear_comunidad);
      paramCount++;
    }

    if (role !== undefined) {
      updates.push(`role = $${paramCount}`);
      params.push(role);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No hay campos para actualizar' });
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    params.push(userId);

    const result = await pool.query(
      `UPDATE usuarios SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING id, email, nombre, role, puede_crear_comunidad, es_premium, email_verificado, created_at`,
      params
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({
      message: 'Permisos actualizados exitosamente',
      usuario: result.rows[0],
    });
  } catch (err) {
    console.error('Error updating user permissions:', err.message);
    res.status(500).json({ error: 'Error al actualizar permisos' });
  }
};

// Create community (admin helper - creates community without permission check)
exports.createCommunityAdmin = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre de la comunidad es requerido' });
    }

    const result = await pool.query(
      'INSERT INTO comunidades (nombre, descripcion, usuario_creador_id) VALUES ($1, $2, $3) RETURNING *',
      [nombre, descripcion || '', req.user.id]
    );

    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [req.user.id, 'crear_comunidad_admin', `Comunidad: ${nombre}`]
    );

    res.status(201).json({
      message: 'Comunidad creada exitosamente',
      comunidad: result.rows[0],
    });
  } catch (err) {
    console.error('Error creating community:', err.message);
    res.status(500).json({ error: 'Error al crear comunidad' });
  }
};

// Create post (admin helper - can create for any community)
exports.createPostAdmin = async (req, res) => {
  try {
    const { comunidad_id, contenido } = req.body;

    if (!contenido) {
      return res.status(400).json({ error: 'El contenido es requerido' });
    }

    if (!comunidad_id) {
      return res.status(400).json({ error: 'El ID de la comunidad es requerido' });
    }

    // Verify community exists
    const community = await pool.query('SELECT id FROM comunidades WHERE id = $1', [comunidad_id]);
    if (community.rows.length === 0) {
      return res.status(404).json({ error: 'Comunidad no encontrada' });
    }

    const result = await pool.query(
      'INSERT INTO publicaciones (usuario_id, comunidad_id, contenido) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, comunidad_id, contenido]
    );

    res.status(201).json({
      message: 'Post creado exitosamente',
      post: result.rows[0],
    });
  } catch (err) {
    console.error('Error creating post:', err.message);
    res.status(500).json({ error: 'Error al crear post' });
  }
};

// Get admin dashboard stats
exports.getAdminStats = async (req, res) => {
  try {
    const [usersCount, communitiesCount, postsCount, adminUsersCount] = await Promise.all([
      pool.query('SELECT COUNT(*) FROM usuarios'),
      pool.query('SELECT COUNT(*) FROM comunidades'),
      pool.query('SELECT COUNT(*) FROM publicaciones'),
      pool.query("SELECT COUNT(*) FROM usuarios WHERE role = 'admin'"),
    ]);

    res.json({
      totalUsuarios: parseInt(usersCount.rows[0].count),
      totalComunidades: parseInt(communitiesCount.rows[0].count),
      totalPosts: parseInt(postsCount.rows[0].count),
      totalAdmins: parseInt(adminUsersCount.rows[0].count),
    });
  } catch (err) {
    console.error('Error fetching stats:', err.message);
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
};
