exports.validateRegister = (req, res, next) => {
  const { email, password, nombre } = req.body;
  if (!email || !password || !nombre) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }
  if (!email.endsWith('@utp.edu.pe')) {
    return res.status(400).json({ error: 'Solo se permiten correos @utp.edu.pe' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
  }
  next();
};

exports.validateLogin = (req, res, next) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña requeridos' });
  }
  next();
};
