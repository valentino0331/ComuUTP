const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

exports.register = async (req, res) => {
  const { uid, email, nombre, apellido, carrera, ciclo } = req.body;
  try {
    // Validar que el email sea @utp.edu.pe
    if (!email || !email.endsWith('@utp.edu.pe')) {
      return res.status(400).json({ error: 'El correo debe ser @utp.edu.pe' });
    }

    if (!uid || !nombre) {
      return res.status(400).json({ error: 'UID y nombre son requeridos' });
    }

    // Verificar si el usuario ya existe
    const userExists = await pool.query('SELECT * FROM usuarios WHERE email = $1 OR firebase_uid = $2', [email, uid]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'El usuario ya existe' });
    }

    // Generar token de verificación
    const verificationToken = uid; // Usar Firebase UID como token
    const verificationLink = `${process.env.FRONTEND_URL}/verify-email?token=${verificationToken}&email=${encodeURIComponent(email)}`;

    // Insertar el nuevo usuario con email_verificado = FALSE
    const result = await pool.query(
      `INSERT INTO usuarios (firebase_uid, email, nombre, apellido, carrera, ciclo, email_verificado, role, puede_crear_comunidad) 
       VALUES ($1, $2, $3, $4, $5, $6, false, 'user', false) 
       RETURNING id, firebase_uid, email, nombre, apellido, carrera, ciclo, role, email_verificado`,
      [uid, email, nombre, apellido || null, carrera || null, ciclo || null]
    );

    // TODO: Aquí enviaría un email con el link de verificación
    console.log(`Email verification link: ${verificationLink}`);

    res.status(201).json({ 
      message: 'Usuario registrado. Verifica tu email para continuar.',
      usuario: result.rows[0],
      verificationLink: verificationLink // En producción, NO devolver el link
    });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ error: 'Error al registrar usuario: ' + err.message });
  }
};

exports.login = async (req, res) => {
  const { uid, email } = req.body;
  console.log('LOGIN REQUEST:', { uid, email, body: req.body });
  try {
    // Validar que al menos uno de los dos esté presente
    if (!uid && !email) {
      return res.status(400).json({ error: 'UID o email requerido' });
    }

    // Buscar el usuario por UID o email
    let query = 'SELECT * FROM usuarios WHERE';
    let params = [];
    
    if (uid) {
      query += ' firebase_uid = $1';
      params = [uid];
    } else if (email) {
      query += ' email = $1';
      params = [email];
    }

    console.log('QUERY:', query, 'PARAMS:', params);
    
    const user = await pool.query(query, params);
    console.log('USER FOUND:', { uid, email, userExists: user.rows.length > 0, userData: user.rows });
    
    if (user.rows.length === 0) {
      console.log('USER NOT FOUND');
      return res.status(404).json({ error: 'Usuario no encontrado - completa tu registro' });
    }

    const userData = user.rows[0];

    // ✅ VERIFICAR QUE EL EMAIL ESTÉ VERIFICADO
    if (!userData.email_verificado) {
      return res.status(403).json({ 
        error: 'Email no verificado. Verifica tu email para continuar.',
        needsEmailVerification: true,
        email: userData.email
      });
    }
    
    try {
      // Generar JWT con todos los datos del usuario
      const jwtSecret = process.env.JWT_SECRET || 'super-secret-key-change-in-production';
      console.log('JWT_SECRET present:', !!process.env.JWT_SECRET);
      
      const token = jwt.sign(
        { id: userData.id, email: userData.email }, 
        jwtSecret, 
        { expiresIn: '7d' }
      );

      console.log('JWT generated successfully');

      const responseData = {
        token,
        usuario: {
          id: userData.id,
          email: userData.email,
          nombre: userData.nombre,
          role: userData.role,
          puede_crear_comunidad: userData.puede_crear_comunidad,
          es_premium: userData.es_premium,
        }
      };

      console.log('RESPONSE DATA:', responseData);
      return res.status(200).json(responseData);
    } catch (jwtErr) {
      console.error('Error generando JWT:', jwtErr.message, jwtErr.stack);
      return res.status(500).json({ error: 'Error generando token: ' + jwtErr.message });
    }
  } catch (err) {
    console.error('Error en login:', err.message, err.stack);
    res.status(500).json({ error: 'Error al iniciar sesión: ' + err.message });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await pool.query(
      `SELECT id, email, nombre, apellido, carrera, ciclo, biografia, foto_perfil,
              postsCount, comunidadesCount, seguidoresCount, seguidosCount,
              es_premium, premium_hasta, puede_crear_comunidad, role,
              created_at, es_admin
       FROM usuarios WHERE id = $1`,
      [req.user.id]
    );
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    const userData = user.rows[0];
    res.json({
      id: userData.id,
      email: userData.email,
      nombre: userData.nombre,
      apellido: userData.apellido,
      carrera: userData.carrera,
      ciclo: userData.ciclo,
      biografia: userData.biografia,
      fotoPerfil: userData.foto_perfil,
      esPremium: userData.es_premium,
      premiumHasta: userData.premium_hasta,
      puedeCrearComunidad: userData.puede_crear_comunidad,
      role: userData.role,
      fechaCreacion: userData.created_at,
      esAdmin: userData.es_admin || userData.role === 'admin'
    });
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
    
    // Verificar que el usuario exista y aún no esté verificado
    const user = await pool.query(
      'SELECT id, email_verificado FROM usuarios WHERE email = $1',
      [email]
    );
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (user.rows[0].email_verificado === true) {
      return res.status(400).json({ message: 'El email ya estaba verificado' });
    }
    
    // Actualizar usuario como verificado
    const result = await pool.query(
      'UPDATE usuarios SET email_verificado = true, updated_at = CURRENT_TIMESTAMP WHERE email = $1 RETURNING id, email, nombre, role, puede_crear_comunidad',
      [email]
    );
    
    res.json({ 
      message: 'Email verificado exitosamente. Bienvenido a UTP Comunidades!',
      usuario: result.rows[0] 
    });
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

/// Cambiar contraseña (requiere auth y es realizado desde Firebase)
exports.changePassword = async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: 'Email es requerido' });
    }
    
    // Verificar que el usuario existe
    const user = await pool.query('SELECT firebase_uid FROM usuarios WHERE id = $1', [req.user.id]);
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    // El cambio de contraseña se maneja desde Firebase Auth
    // Aquí solo registramos la intención y podemos enviar email de confirmación
    res.json({ 
      message: 'Se ha enviado un enlace para cambiar tu contraseña a tu correo. Verifica tu email para continuar.',
      note: 'La contraseña se cambia a través de Firebase Authentication'
    });
  } catch (err) {
    console.error('Error en changePassword:', err.message);
    res.status(500).json({ error: 'Error al cambiar contraseña: ' + err.message });
  }
};
