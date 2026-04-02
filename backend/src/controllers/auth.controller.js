const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

exports.register = async (req, res) => {
  const { email, password, nombre } = req.body;
  try {
    const userExists = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'El usuario ya existe' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO usuarios (email, password, nombre) VALUES ($1, $2, $3) RETURNING id, email, nombre',
      [email, hashedPassword, nombre]
    );
    res.status(201).json({ user: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }
    const valid = await bcrypt.compare(password, user.rows[0].password);
    if (!valid) {
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }
    const token = jwt.sign({ id: user.rows[0].id, email: user.rows[0].email }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await pool.query('SELECT id, email, nombre FROM usuarios WHERE id = $1', [req.user.id]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.json({ user: user.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener usuario' });
  }
};
