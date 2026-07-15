const validator = require('validator');

/**
 * Middleware para sanitizar input y prevenir XSS
 * Escapa caracteres HTML y elimina caracteres peligrosos
 */
const sanitizeInput = (req, res, next) => {
  if (req.body) {
    const sanitizeObject = (obj) => {
      for (const key in obj) {
        if (typeof obj[key] === 'string') {
          // Escapar HTML para prevenir XSS
          obj[key] = validator.escape(obj[key]);
          // Eliminar caracteres peligrosos adicionales
          obj[key] = validator.blacklist(obj[key], ['<', '>', '"', "'", ';', '(', ')', '{', '}']);
          // Limitar longitud para prevenir ataques de string muy largos
          if (obj[key].length > 10000) {
            obj[key] = obj[key].substring(0, 10000);
          }
        } else if (typeof obj[key] === 'object' && obj[key] !== null) {
          sanitizeObject(obj[key]);
        }
      }
    };
    sanitizeObject(req.body);
  }
  
  // También sanitizar query params
  if (req.query) {
    for (const key in req.query) {
      if (typeof req.query[key] === 'string') {
        req.query[key] = validator.escape(req.query[key]);
        req.query[key] = validator.blacklist(req.query[key], ['<', '>', '"', "'", ';']);
      }
    }
  }
  
  next();
};

module.exports = sanitizeInput;
