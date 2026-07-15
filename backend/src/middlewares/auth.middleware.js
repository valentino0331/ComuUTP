const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

const authenticate = async (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token requerido' });
  try {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      throw new Error('JWT_SECRET no configurado');
    }
    const decoded = jwt.verify(token, jwtSecret);
    
    // Verificar sesión única
    if (decoded.sessionId) {
      const userResult = await pool.query('SELECT session_id FROM usuarios WHERE id = $1', [decoded.id]);
      if (userResult.rows.length > 0 && userResult.rows[0].session_id !== decoded.sessionId) {
        return res.status(401).json({ 
          error: 'Sesión expirada', 
          message: 'Tu sesión ha sido iniciada en otro dispositivo.' 
        });
      }
    }

    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido' });
  }
};

module.exports = { authenticate };
