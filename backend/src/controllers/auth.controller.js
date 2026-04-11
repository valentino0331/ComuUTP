const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/db');
const emailService = require('../services/email.service');
require('dotenv').config();

/**
 * Registro de usuario con Firebase Auth + Neon
 * El usuario ya fue creado en Firebase, aquí guardamos los datos en Neon
 */
exports.register = async (req, res) => {
  const { uid, email, nombre, apellido, carrera, ciclo } = req.body;
  
  try {
    // Validar campos requeridos
    if (!uid || !email || !nombre) {
      return res.status(400).json({ error: 'UID, email y nombre son requeridos' });
    }
    
    // Validar que el email sea @utp.edu.pe
    if (!email.endsWith('@utp.edu.pe')) {
      return res.status(400).json({ error: 'El correo debe ser @utp.edu.pe' });
    }

    // Verificar si el usuario ya existe por firebase_uid
    const userExists = await pool.query('SELECT * FROM usuarios WHERE firebase_uid = $1', [uid]);
    if (userExists.rows.length > 0) {
      return res.status(409).json({ error: 'El usuario ya existe en la base de datos' });
    }
    
    // Verificar si el email ya existe
    const emailExists = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (emailExists.rows.length > 0) {
      return res.status(409).json({ error: 'El correo ya está registrado' });
    }

    // Insertar el nuevo usuario con Firebase UID (email ya verificado por Firebase)
    const result = await pool.query(
      `INSERT INTO usuarios (firebase_uid, email, nombre, apellido, carrera, ciclo, email_verificado) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING id, firebase_uid, email, nombre, apellido, carrera, ciclo`,
      [uid, email, nombre, apellido || null, carrera || null, ciclo || null, true]
    );

    res.status(201).json({ 
      message: 'Usuario registrado exitosamente',
      usuario: result.rows[0]
    });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ error: 'Error al registrar usuario: ' + err.message });
  }
};

/**
 * Login con Firebase UID
 * Verifica que el usuario exista en Neon y retorna sus datos
 * El token de autenticación real viene de Firebase
 */
exports.login = async (req, res) => {
  const { uid, email } = req.body;
  
  console.log('LOGIN REQUEST:', { uid, email });
  
  try {
    // Validar campos
    if (!uid) {
      return res.status(400).json({ error: 'Firebase UID es requerido' });
    }
    
    if (email && !email.endsWith('@utp.edu.pe')) {
      return res.status(400).json({ error: 'El correo debe ser @utp.edu.pe' });
    }

    // Buscar usuario por firebase_uid
    const user = await pool.query(
      'SELECT id, firebase_uid, email, nombre, apellido, carrera, ciclo, es_premium, puede_crear_comunidad FROM usuarios WHERE firebase_uid = $1',
      [uid]
    );
    
    console.log('USER FOUND:', { uid, userExists: user.rows.length > 0 });
    
    if (user.rows.length === 0) {
      console.log('USER NOT FOUND - Need to register first');
      return res.status(404).json({ 
        error: 'Usuario no encontrado',
        code: 'USER_NOT_FOUND',
        message: 'El usuario existe en Firebase pero no en Neon. Complete el registro.'
      });
    }

    // Generar JWT interno para sesiones backend
    const token = jwt.sign(
      { id: user.rows[0].id, firebase_uid: user.rows[0].firebase_uid, email: user.rows[0].email }, 
      process.env.JWT_SECRET, 
      { expiresIn: '7d' }
    );

    res.json({ 
      token,
      usuario: user.rows[0]
    });
  } catch (err) {
    console.error('Error en login:', err.message);
    res.status(500).json({ error: 'Error al iniciar sesión: ' + err.message });
  }
};

/**
 * Obtener datos del usuario actual
 */
exports.me = async (req, res) => {
  try {
    const user = await pool.query(
      'SELECT id, firebase_uid, email, nombre, apellido, carrera, ciclo, es_premium, puede_crear_comunidad FROM usuarios WHERE id = $1', 
      [req.user.id]
    );
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.json({ usuario: user.rows[0] });
  } catch (err) {
    console.error('Error en me:', err.message);
    res.status(500).json({ error: 'Error al obtener usuario: ' + err.message });
  }
};

/**
 * Verificar email con token
 */
exports.verifyEmail = async (req, res) => {
  const { token } = req.query;
  
  if (!token) {
    return res.status(400).json({ error: 'Token de verificación requerido' });
  }
  
  try {
    // Buscar token válido
    const tokenResult = await pool.query(
      `SELECT vt.*, u.email, u.nombre, u.id as user_id 
       FROM verification_tokens vt
       JOIN usuarios u ON vt.usuario_id = u.id
       WHERE vt.token = $1 AND vt.expira_at > CURRENT_TIMESTAMP`,
      [token]
    );
    
    if (tokenResult.rows.length === 0) {
      return res.status(400).json({ error: 'Token inválido o expirado' });
    }
    
    const { user_id, email, nombre } = tokenResult.rows[0];
    
    // Marcar email como verificado
    await pool.query(
      'UPDATE usuarios SET email_verificado = true WHERE id = $1',
      [user_id]
    );
    
    // Eliminar token usado
    await pool.query(
      'DELETE FROM verification_tokens WHERE token = $1',
      [token]
    );
    
    // Enviar email de bienvenida
    await emailService.sendWelcomeEmail(email, nombre);
    
    res.json({ 
      message: 'Email verificado exitosamente',
      verified: true
    });
  } catch (err) {
    console.error('Error verificando email:', err.message);
    res.status(500).json({ error: 'Error al verificar email: ' + err.message });
  }
};

/**
 * Reenviar email de verificación
 */
exports.resendVerification = async (req, res) => {
  const { email } = req.body;
  
  if (!email) {
    return res.status(400).json({ error: 'Email requerido' });
  }
  
  try {
    // Buscar usuario por email
    const userResult = await pool.query(
      'SELECT * FROM usuarios WHERE email = $1',
      [email]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    const user = userResult.rows[0];
    
    // Si ya está verificado
    if (user.email_verificado) {
      return res.status(400).json({ error: 'Email ya verificado' });
    }
    
    // Eliminar token anterior si existe
    await pool.query(
      'DELETE FROM verification_tokens WHERE usuario_id = $1',
      [user.id]
    );
    
    // Generar nuevo token
    const verificationToken = uuidv4();
    
    await pool.query(
      `INSERT INTO verification_tokens (usuario_id, token, expira_at) 
       VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '24 hours')`,
      [user.id, verificationToken]
    );
    
    // Reenviar email
    await emailService.sendVerificationEmail(email, user.nombre, verificationToken);
    
    res.json({ 
      message: 'Email de verificación reenviado'
    });
  } catch (err) {
    console.error('Error reenviando verificación:', err.message);
    res.status(500).json({ error: 'Error al reenviar: ' + err.message });
  }
};

/**
 * Sincronizar usuario de Firebase con Neon
 * Si el usuario no existe en Neon, lo crea
 */
exports.syncUser = async (req, res) => {
  const { uid, email, nombre, apellido, carrera, ciclo } = req.body;
  
  try {
    // Buscar si el usuario ya existe
    const existingUser = await pool.query('SELECT * FROM usuarios WHERE firebase_uid = $1', [uid]);
    
    if (existingUser.rows.length > 0) {
      // Usuario existe, actualizar datos si es necesario
      return res.json({ 
        message: 'Usuario ya existe',
        usuario: existingUser.rows[0]
      });
    }
    
    // Crear nuevo usuario
    const result = await pool.query(
      `INSERT INTO usuarios (firebase_uid, email, nombre, apellido, carrera, ciclo, email_verificado) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING id, firebase_uid, email, nombre, apellido, carrera, ciclo`,
      [uid, email, nombre, apellido || null, carrera || null, ciclo || null, true]
    );
    
    res.status(201).json({
      message: 'Usuario sincronizado exitosamente',
      usuario: result.rows[0]
    });
  } catch (err) {
    console.error('Error en syncUser:', err.message);
    res.status(500).json({ error: 'Error al sincronizar usuario: ' + err.message });
  }
};
