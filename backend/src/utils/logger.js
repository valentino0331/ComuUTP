const pool = require('../config/db');
const fs = require('fs');
const path = require('path');

// Niveles de log
const LOG_LEVELS = {
  ERROR: 'ERROR',
  WARN: 'WARN',
  INFO: 'INFO',
  DEBUG: 'DEBUG'
};

// Obtener nivel de log configurado
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const LEVEL_PRIORITY = {
  'debug': 0,
  'info': 1,
  'warn': 2,
  'error': 3
};

// Crear directorio de logs si no existe
const logsDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

/**
 * Formatea un mensaje de log con timestamp y nivel
 * @param {string} level - Nivel de log (ERROR, WARN, INFO, DEBUG)
 * @param {string} module - Módulo desde donde se llama
 * @param {string} message - Mensaje principal
 * @param {object} details - Detalles adicionales
 * @returns {string} Mensaje formateado
 */
const formatLog = (level, module, message, details = {}) => {
  const timestamp = new Date().toISOString();
  const detailsStr = Object.keys(details).length > 0 
    ? ` ${JSON.stringify(details)}`
    : '';
  
  return `[${timestamp}] [${level}] [${module}]${message ? ': ' + message : ''}${detailsStr}`;
};

/**
 * Escribe log en archivo
 * @param {string} level - Nivel de log
 * @param {string} message - Mensaje formateado
 */
const writeToFile = (level, message) => {
  try {
    const filename = path.join(logsDir, `${level.toLowerCase()}.log`);
    const allLogFile = path.join(logsDir, 'all.log');
    
    fs.appendFileSync(filename, message + '\n');
    fs.appendFileSync(allLogFile, message + '\n');
  } catch (err) {
    console.error('Error escribiendo log a archivo:', err.message);
  }
};

/**
 * Registra log en base de datos
 * @param {number} userId - ID del usuario
 * @param {string} action - Acción realizada
 * @param {string} description - Descripción de la acción
 * @param {string} level - Nivel de log
 * @param {object} metadata - Metadatos adicionales
 */
const logToDatabase = async (userId, action, description, level = 'INFO', metadata = {}) => {
  try {
    const query = `
      INSERT INTO logs_sistema (usuario_id, accion, descripcion, nivel, metadata, tipo_evento)
      VALUES ($1, $2, $3, $4, $5, $6)
      ON CONFLICT DO NOTHING
    `;
    
    await pool.query(query, [
      userId || null,
      action,
      description,
      level,
      JSON.stringify(metadata),
      'system'
    ]);
  } catch (err) {
    // No fallar si hay error en BD, pero registrar en archivo
    console.error('Error guardando log en BD:', err.message);
    writeToFile('ERROR', formatLog('ERROR', 'Logger', 'Error saving to DB', { error: err.message }));
  }
};

/**
 * Registra evento de seguridad
 * @param {string} eventType - Tipo de evento (LOGIN, UNAUTHORIZED_ACCESS, etc)
 * @param {object} details - Detalles del evento
 */
const logSecurityEvent = async (eventType, details = {}) => {
  const message = formatLog('WARN', 'SecurityEvent', eventType, details);
  console.warn(message);
  writeToFile('WARN', message);
  
  // Registrar en BD si es crítico
  if (['UNAUTHORIZED_ACCESS', 'INVALID_CREDENTIALS', 'BRUTE_FORCE_ATTEMPT', 'PRIVILEGE_ESCALATION'].includes(eventType)) {
    await logToDatabase(
      details.userId || null,
      eventType,
      `Security event: ${eventType}`,
      'WARN',
      details
    );
  }
};

/**
 * Logger - Función principal
 * @param {string} level - Nivel de log (debug, info, warn, error)
 * @param {string} module - Nombre del módulo/controlador
 * @param {string} message - Mensaje a loguear
 * @param {object} data - Datos adicionales
 */
const logger = {
  debug(module, message, data = {}) {
    if (LEVEL_PRIORITY[LOG_LEVEL.toLowerCase()] <= LEVEL_PRIORITY['debug']) {
      const logMsg = formatLog('DEBUG', module, message, data);
      console.log(logMsg);
      writeToFile('DEBUG', logMsg);
    }
  },

  info(module, message, data = {}) {
    if (LEVEL_PRIORITY[LOG_LEVEL.toLowerCase()] <= LEVEL_PRIORITY['info']) {
      const logMsg = formatLog('INFO', module, message, data);
      console.log(logMsg);
      writeToFile('INFO', logMsg);
    }
  },

  warn(module, message, data = {}) {
    if (LEVEL_PRIORITY[LOG_LEVEL.toLowerCase()] <= LEVEL_PRIORITY['warn']) {
      const logMsg = formatLog('WARN', module, message, data);
      console.warn(logMsg);
      writeToFile('WARN', logMsg);
    }
  },

  error(module, message, error = null, data = {}) {
    const errorMsg = error?.message || error || 'Unknown error';
    const stack = error?.stack || '';
    const logMsg = formatLog('ERROR', module, message, { 
      error: errorMsg,
      ...data
    });
    
    console.error(logMsg);
    if (stack) {
      console.error('Stack:', stack);
      writeToFile('ERROR', stack);
    }
    writeToFile('ERROR', logMsg);
  },

  /**
   * Log de evento de usuario (auditoría)
   */
  async audit(userId, action, details = {}, status = 'success') {
    const message = formatLog('INFO', 'Audit', action, { userId, status, ...details });
    console.log(message);
    writeToFile('info', message);
    
    // Guardar en BD para auditoría
    await logToDatabase(userId, action, `${action} - ${status}`, 'INFO', details);
  },

  /**
   * Log seguridad
   */
  async security(eventType, details = {}) {
    await logSecurityEvent(eventType, details);
  },

  /**
   * Log de errores críticos con alertas
   */
  async critical(module, message, error = null) {
    const logMsg = formatLog('ERROR', module, `🚨 CRITICAL: ${message}`, { 
      error: error?.message || error
    });
    console.error(logMsg);
    writeToFile('ERROR', logMsg);
    
    // TODO: Aquí se podría enviar alerta a Slack, email, etc.
    // await sendAlert(logMsg);
  }
};

// Mantener función legacy para compatibilidad
exports.log = async (usuario_id, accion, descripcion) => {
  await logToDatabase(usuario_id, accion, descripcion, 'INFO');
};

// Exportar logger completo
exports.logger = logger;
exports.logSecurityEvent = logSecurityEvent;
module.exports = exports;
