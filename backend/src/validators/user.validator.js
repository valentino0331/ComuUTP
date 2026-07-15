const Joi = require('joi');

// Validación para registro
const registerSchema = Joi.object({
  uid: Joi.string()
    .min(1)
    .max(128)
    .required()
    .messages({
      'string.empty': 'Firebase UID es requerido',
      'string.min': 'Firebase UID debe tener al menos 1 caracter',
      'string.max': 'Firebase UID no puede exceder 128 caracteres',
      'any.required': 'Firebase UID es requerido'
    }),
  email: Joi.string()
    .email()
    .required()
    .pattern(/@utp\.edu\.pe$/)
    .messages({
      'string.email': 'Email inválido',
      'string.pattern.base': 'Solo se permiten correos @utp.edu.pe',
      'any.required': 'Email es requerido'
    }),
  nombre: Joi.string()
    .min(2)
    .max(120)
    .required()
    .messages({
      'string.empty': 'Nombre es requerido',
      'string.min': 'Nombre debe tener al menos 2 caracteres',
      'string.max': 'Nombre no puede exceder 120 caracteres',
      'any.required': 'Nombre es requerido'
    }),
  apellido: Joi.string()
    .max(120)
    .optional()
    .allow('')
    .messages({
      'string.max': 'Apellido no puede exceder 120 caracteres'
    }),
  carrera: Joi.string()
    .max(100)
    .optional()
    .allow('')
    .messages({
      'string.max': 'Carrera no puede exceder 100 caracteres'
    }),
  ciclo: Joi.number()
    .integer()
    .min(1)
    .max(10)
    .optional()
    .messages({
      'number.base': 'Ciclo debe ser un número',
      'number.min': 'Ciclo debe ser al menos 1',
      'number.max': 'Ciclo no puede exceder 10'
    })
});

// Validación para login
const loginSchema = Joi.object({
  uid: Joi.string()
    .optional()
    .allow(''),
  email: Joi.string()
    .email()
    .optional()
    .allow('')
    .messages({
      'string.email': 'Email inválido'
    })
}).xor('uid', 'email')
  .messages({
    'object.xor': 'Debe proporcionar UID o email (no ambos)'
  });

// Validación para crear comunidad
const createCommunitySchema = Joi.object({
  nombre: Joi.string()
    .min(3)
    .max(120)
    .required()
    .messages({
      'string.empty': 'Nombre es requerido',
      'string.min': 'Nombre debe tener al menos 3 caracteres',
      'string.max': 'Nombre no puede exceder 120 caracteres',
      'any.required': 'Nombre es requerido'
    }),
  descripcion: Joi.string()
    .min(10)
    .max(500)
    .required()
    .messages({
      'string.empty': 'Descripción es requerida',
      'string.min': 'Descripción debe tener al menos 10 caracteres',
      'string.max': 'Descripción no puede exceder 500 caracteres',
      'any.required': 'Descripción es requerida'
    }),
  categoria: Joi.string()
    .optional()
    .allow('')
});

// Validación para crear post
const createPostSchema = Joi.object({
  comunidad_id: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      'number.base': 'ID de comunidad debe ser un número',
      'number.positive': 'ID de comunidad debe ser positivo',
      'any.required': 'ID de comunidad es requerido'
    }),
  contenido: Joi.string()
    .min(1)
    .max(5000)
    .required()
    .messages({
      'string.empty': 'Contenido es requerido',
      'string.min': 'Contenido no puede estar vacío',
      'string.max': 'Contenido no puede exceder 5000 caracteres',
      'any.required': 'Contenido es requerido'
    })
});

// Validación para actualizar perfil
const updateProfileSchema = Joi.object({
  nombre: Joi.string()
    .min(2)
    .max(120)
    .required()
    .messages({
      'string.empty': 'Nombre es requerido',
      'string.min': 'Nombre debe tener al menos 2 caracteres',
      'string.max': 'Nombre no puede exceder 120 caracteres',
      'any.required': 'Nombre es requerido'
    }),
  bio: Joi.string()
    .max(500)
    .optional()
    .allow('')
    .messages({
      'string.max': 'Biografía no puede exceder 500 caracteres'
    }),
  carrera: Joi.string()
    .max(100)
    .optional()
    .allow('')
    .messages({
      'string.max': 'Carrera no puede exceder 100 caracteres'
    }),
  gustos: Joi.array()
    .items(Joi.string().max(50))
    .max(5)
    .optional()
    .messages({
      'array.max': 'Máximo 5 intereses permitidos'
    })
});

// Middleware de validación
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });
    
    if (error) {
      const errors = error.details.map(detail => detail.message);
      return res.status(400).json({ 
        error: 'Validación fallida', 
        details: errors 
      });
    }
    
    req.body = value;
    next();
  };
};

module.exports = {
  registerSchema,
  loginSchema,
  createCommunitySchema,
  createPostSchema,
  updateProfileSchema,
  validate
};
