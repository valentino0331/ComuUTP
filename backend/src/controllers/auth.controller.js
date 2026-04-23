const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
const emailService = require('../services/email.service');
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

    // NOTA: El email de verificación se envía desde Firebase Auth (gratis e ilimitado)
    // No enviamos email desde aquí para evitar límites de SendGrid
    
    res.status(201).json({ 
      message: 'Usuario registrado. Revisa tu correo para verificar tu cuenta.',
      usuario: result.rows[0],
      emailSent: true, // Firebase lo envía automáticamente
    });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ error: 'Error al registrar usuario: ' + err.message });
  }
};

exports.login = async (req, res) => {
  let { uid, email } = req.body;
  try {
    // Validar que al menos uno de los dos esté presente
    if (!uid && !email) {
      return res.status(400).json({ error: 'UID o email requerido' });
    }

    // Si se proporciona email y no contiene @, agregar @utp.edu.pe
    if (email && !email.includes('@')) {
      email = email + '@utp.edu.pe';
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
    
    const user = await pool.query(query, params);
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado - completa tu registro' });
    }

    const userData = user.rows[0];

    // NOTA: La verificación de email la hace Firebase Auth en el frontend
    // El backend confía en que Firebase ya verificó el email
    // Actualizamos email_verificado a true automáticamente
    if (!userData.email_verificado) {
      await pool.query(
        'UPDATE usuarios SET email_verificado = true WHERE id = $1',
        [userData.id]
      );
      userData.email_verificado = true;
    }
    
    try {
      // Generar JWT con todos los datos del usuario
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        throw new Error('JWT_SECRET no configurado');
      }
      
      const token = jwt.sign(
        { id: userData.id, email: userData.email }, 
        jwtSecret, 
        { expiresIn: '7d' }
      );

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
    const userResult = await pool.query(
      'SELECT id, nombre, firebase_uid, email_verificado FROM usuarios WHERE email = $1', 
      [email]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    
    const user = userResult.rows[0];
    
    // Si ya está verificado, no reenviar
    if (user.email_verificado) {
      return res.status(400).json({ error: 'El email ya está verificado' });
    }
    
    // Reenviar email de verificación
    const emailSent = await emailService.sendVerificationEmail(email, user.nombre, user.firebase_uid);
    
    if (!emailSent) {
      return res.status(500).json({ error: 'No se pudo enviar el email. Intenta más tarde.' });
    }
    
    res.json({ 
      message: 'Email de verificación reenviado a ' + email,
      nota: 'Revisa tu bandeja de entrada y carpeta de spam'
    });
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
