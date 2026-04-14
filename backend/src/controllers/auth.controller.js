const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

exports.register = async (req, res) => {
  const { email, password, nombre } = req.body;
  try {
    // Validar que el email sea @utp.edu.pe
    if (!email || !email.endsWith('@utp.edu.pe')) {
      return res.status(400).json({ error: 'El correo debe ser @utp.edu.pe' });
    }

    // Verificar si el usuario ya existe
    const userExists = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'El usuario ya existe' });
    }

    // Hashear la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insertar el nuevo usuario
    const result = await pool.query(
      'INSERT INTO usuarios (email, password, nombre) VALUES ($1, $2, $3) RETURNING id, email, nombre',
      [email, hashedPassword, nombre]
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

exports.login = async (req, res) => {
  const { email, password } = req.body;
  console.log('LOGIN REQUEST:', { email, password, body: req.body });
  try {
    // Validar que el email sea @utp.edu.pe
    if (!email || !email.endsWith('@utp.edu.pe')) {
      console.log('EMAIL VALIDATION FAILED:', email);
      return res.status(400).json({ error: 'El correo debe ser @utp.edu.pe' });
    }

    // Buscar el usuario
    const user = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    console.log('USER FOUND:', { email, userExists: user.rows.length > 0, userData: user.rows });
    if (user.rows.length === 0) {
      console.log('USER NOT FOUND - Returning 400');
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }

    // Verificar contraseña
    console.log('COMPARING PASSWORD - stored:', user.rows[0].password, 'provided:', password);
    const valid = await bcrypt.compare(password, user.rows[0].password);
    console.log('PASSWORD VALID:', valid);
    if (!valid) {
      console.log('PASSWORD INVALID - Returning 400');
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }

    // Generar JWT
    const token = jwt.sign(
      { id: user.rows[0].id, email: user.rows[0].email }, 
      process.env.JWT_SECRET, 
      { expiresIn: '7d' }
    );

    res.json({ 
      token,
      usuario: {
        id: user.rows[0].id,
        email: user.rows[0].email,
        nombre: user.rows[0].nombre
      }
    });
  } catch (err) {
    console.error('Error en login:', err.message);
    res.status(500).json({ error: 'Error al iniciar sesión: ' + err.message });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await pool.query(
      `SELECT id, email, nombre, apellido, carrera, ciclo, biografia, fotoPerfil,
              postsCount, comunidadesCount, seguidoresCount, seguidosCount,
              esPremium, premiumHasta, puedeCrearComunidad, asistenciasVerificadas,
              fechaCreacion, esAdmin
       FROM usuarios WHERE id = $1`,
      [req.user.id]
    );
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.json(user.rows[0]);
  } catch (err) {
    console.error('Error en me:', err.message);
    res.status(500).json({ error: 'Error al obtener usuario: ' + err.message });
  }
};

/// Sincronizar usuario entre Firebase y Neon
exports.syncUser = async (req, res) => {
  try {
    const { uid, email, nombre } = req.body;
    
    if (!uid || !email) {
      return res.status(400).json({ error: 'UID y email son requeridos' });
    }
    
    // Verificar si existe en Neon
    const userExists = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email]);
    
    if (userExists.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado, completa tu registro' });
    }
    
    res.json({ usuario: userExists.rows[0] });
  } catch (err) {
    console.error('Error en syncUser:', err.message);
    res.status(500).json({ error: 'Error al sincronizar usuario: ' + err.message });
  }
};

/// Verificar email (para links de verificación)
exports.verifyEmail = async (req, res) => {
  try {
    const { email } = req.query;
    
    if (!email) {
      return res.status(400).json({ error: 'Email es requerido' });
    }
    
    // Actualizar usuario como verificado
    const result = await pool.query(
      'UPDATE usuarios SET emailVerified = true WHERE email = $1 RETURNING id, email, nombre',
      [email]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    res.json({ message: 'Email verificado exitosamente', usuario: result.rows[0] });
  } catch (err) {
    console.error('Error en verifyEmail:', err.message);
    res.status(500).json({ error: 'Error al verificar email: ' + err.message });
  }
};

/// Reenviar email de verificación
exports.resendVerification = async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: 'Email es requerido' });
    }
    
    // Verificar que usuario existe
    const userExists = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    
    if (userExists.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    // Aquí iría la lógica para reenviar el email (usando email.service.js)
    res.json({ message: 'Email de verificación reenviado a ' + email });
  } catch (err) {
    console.error('Error en resendVerification:', err.message);
    res.status(500).json({ error: 'Error al reenviar email: ' + err.message });
  }
};
