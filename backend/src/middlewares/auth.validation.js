exports.validateRegister = (req, res, next) => {
  const { uid, email, nombre } = req.body;
  if (!uid || !email || !nombre) {
    return res.status(400).json({ error: 'Firebase UID, email y nombre son obligatorios' });
  }
  if (!email.endsWith('@utp.edu.pe')) {
    return res.status(400).json({ error: 'Solo se permiten correos @utp.edu.pe' });
  }
  next();
};

exports.validateLogin = (req, res, next) => {
  const { uid, email } = req.body;
  console.log('VALIDATE LOGIN MIDDLEWARE:', { uid, email, body: req.body });
  if (!uid) {
    console.log('VALIDATION FAILED - Missing uid');
    return res.status(400).json({ error: 'Firebase UID requerido' });
  }
  next();
};
