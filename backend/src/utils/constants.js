/**
 * Constantes globales de la aplicación
 * Aquí se definen valores constantes usados en toda la app
 */

// Validación
const VALIDATION = {
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PASSWORD_MIN_LENGTH: 8,
  PASSWORD_REGEX: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
  USERNAME_MIN_LENGTH: 3,
  USERNAME_MAX_LENGTH: 30,
  BIO_MAX_LENGTH: 500,
  POST_TITLE_MAX_LENGTH: 200,
  POST_CONTENT_MAX_LENGTH: 50000,
  COMMENT_MAX_LENGTH: 5000,
  COMMUNITY_NAME_MAX_LENGTH: 100,
  COMMUNITY_DESC_MAX_LENGTH: 1000,
  PAYLOAD_MAX_SIZE: 10 * 1024 * 1024, // 10MB
};

// Autenticación
const AUTH = {
  JWT_EXPIRATION: '24h',
  JWT_SECRET_MIN_LENGTH: 32,
  BCRYPT_ROUNDS: 10,
  TOKEN_REFRESH_THRESHOLD: 3600000, // 1 hora en ms
};

// Rate Limiting
const RATE_LIMITS = {
  LOGIN_ATTEMPTS: 5,
  LOGIN_WINDOW_MS: 15 * 60 * 1000, // 15 minutos
  API_REQUESTS_PER_MINUTE: 100,
  API_REQUESTS_PER_HOUR: 5000,
};

// Roles de usuario
const ROLES = {
  ADMIN: 'admin',
  MODERATOR: 'moderator',
  USER: 'user',
  GUEST: 'guest'
};

// Permisos basados en rol
const PERMISSIONS = {
  [ROLES.ADMIN]: [
    'create_users',
    'edit_users',
    'delete_users',
    'ban_users',
    'manage_reports',
    'manage_communities',
    'delete_posts',
    'delete_comments',
    'view_logs'
  ],
  [ROLES.MODERATOR]: [
    'ban_users',
    'manage_reports',
    'delete_posts',
    'delete_comments'
  ],
  [ROLES.USER]: [
    'create_posts',
    'edit_own_posts',
    'delete_own_posts',
    'create_comments',
    'edit_own_comments',
    'delete_own_comments',
    'create_communities',
    'report_content'
  ],
  [ROLES.GUEST]: [
    'view_posts',
    'view_comments',
    'view_communities'
  ]
};

// Estados de usuario
const USER_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  BANNED: 'banned',
  SUSPENDED: 'suspended'
};

// Estados de post
const POST_STATUS = {
  PUBLISHED: 'published',
  DRAFT: 'draft',
  DELETED: 'deleted',
  REPORTED: 'reported'
};

// Tipos de reporte
const REPORT_TYPES = {
  SPAM: 'spam',
  HARASSMENT: 'harassment',
  HATE_SPEECH: 'hate_speech',
  MISINFORMATION: 'misinformation',
  INAPPROPRIATE_CONTENT: 'inappropriate_content',
  COMMERCIAL_SPAM: 'commercial_spam',
  OTHER: 'other'
};

// Estados de reporte
const REPORT_STATUS = {
  PENDING: 'pending',
  IN_REVIEW: 'in_review',
  RESOLVED: 'resolved',
  DISMISSED: 'dismissed'
};

// Tipos de notificación
const NOTIFICATION_TYPES = {
  LIKE: 'like',
  COMMENT: 'comment',
  REPLY: 'reply',
  BAN: 'ban',
  NEW_FOLLOWER: 'new_follower',
  POST_SHARED: 'post_shared',
  COMMUNITY_INVITE: 'community_invite',
  COMMUNITY_UPDATE: 'community_update'
};

// Mensaje de error estándar (sin exponer detalles internos)
const ERROR_MESSAGES = {
  INTERNAL_ERROR: 'Error interno del servidor',
  INVALID_INPUT: 'Entrada inválida',
  UNAUTHORIZED: 'No autorizado',
  FORBIDDEN: 'No tiene permiso para esta acción',
  NOT_FOUND: 'Recurso no encontrado',
  DUPLICATE: 'Este recurso ya existe',
  INVALID_CREDENTIALS: 'Credenciales inválidas',
  EXPIRED_TOKEN: 'Token expirado',
  INVALID_TOKEN: 'Token inválido',
  TOKEN_REQUIRED: 'Token requerido',
  USER_BANNED: 'Usuario baneado',
  USER_SUSPENDED: 'Usuario suspendido',
  COMMUNITY_NOT_FOUND: 'Comunidad no encontrada',
  POST_NOT_FOUND: 'Post no encontrado',
  COMMENT_NOT_FOUND: 'Comentario no encontrado'
};

// Códigos HTTP estándar
const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503
};

// Configuración de base de datos
const DB_CONFIG = {
  POOL_MIN: 2,
  POOL_MAX: 20,
  CONNECTION_TIMEOUT_MS: 5000,
  QUERY_TIMEOUT_MS: 30000,
  IDLE_TIMEOUT_MS: 30000
};

// Configuración de frontend (CORS)
const FRONTEND_CONFIG = {
  DEVELOPMENT_URL: 'http://localhost:3000',
  PRODUCTION_URL: process.env.FRONTEND_URL || 'https://ejemplo.com'
};

// Regexes comunes
const PATTERNS = {
  UUID: /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
  URL: /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/,
  PHONE: /^[+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/,
  SLUG: /^[a-z0-9]+(?:-[a-z0-9]+)*$/
};

// Mensajes de log
const LOG_MESSAGES = {
  SERVER_STARTED: 'Servidor iniciado correctamente',
  DB_CONNECTED: 'Conectado a la base de datos',
  DB_CONNECTION_FAILED: 'Fallo al conectar a la base de datos',
  USER_CREATED: 'Usuario creado exitosamente',
  USER_LOGIN: 'Usuario inició sesión',
  USER_LOGOUT: 'Usuario cerró sesión',
  INVALID_CREDENTIALS: 'Credenciales inválidas',
  TOKEN_GENERATED: 'Token generado',
  TOKEN_VERIFIED: 'Token verificado',
  UNAUTHORIZED_ACCESS: 'Intento de acceso no autorizado',
  POST_CREATED: 'Post creado',
  POST_DELETED: 'Post eliminado',
  COMMENT_CREATED: 'Comentario creado',
  USER_BANNED: 'Usuario baneado'
};

module.exports = {
  VALIDATION,
  AUTH,
  RATE_LIMITS,
  ROLES,
  PERMISSIONS,
  USER_STATUS,
  POST_STATUS,
  REPORT_TYPES,
  REPORT_STATUS,
  NOTIFICATION_TYPES,
  ERROR_MESSAGES,
  HTTP_STATUS,
  DB_CONFIG,
  FRONTEND_CONFIG,
  PATTERNS,
  LOG_MESSAGES
};
