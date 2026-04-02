/**
 * Servicio de API - Cliente HTTP para UTP Comunidades Web
 * Centraliza todas las llamadas a la API del backend
 */

// URL base de la API (ajusta según tu entorno)
export const CLIENT_API = 'http://localhost:3000/api';

// Timeout por defecto (5 segundos)
const TIMEOUT = 5000;

/**
 * Realizar una solicitud HTTP con manejo de errores
 */
export async function solicitudHTTP(
  endpoint,
  opciones = {}
) {
  const urlCompleta = `${CLIENT_API}${endpoint}`;
  const token = localStorage.getItem('token');

  const opcionesFinales = {
    ...opciones,
    headers: {
      'Content-Type': 'application/json',
      ...opciones.headers,
    },
  };

  // Agregar token si existe
  if (token && !opcionesFinales.headers['Authorization']) {
    opcionesFinales.headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    const respuesta = await Promise.race([
      fetch(urlCompleta, opcionesFinales),
      new Promise((_, reject) =>
        setTimeout(
          () => reject(new Error('Tiempo de espera agotado')),
          TIMEOUT
        )
      ),
    ]);

    const datos = await respuesta.json().catch(() => ({}));

    if (!respuesta.ok) {
      throw new Error(
        datos.mensaje || `Error ${respuesta.status}: ${respuesta.statusText}`
      );
    }

    return { exito: true, datos };
  } catch (error) {
    return { exito: false, error: error.message };
  }
}

/**
 * Servicios de Autenticación
 */
export const serviciosAuth = {
  /**
   * Registrar nuevo usuario
   */
  async registrarse(email, nombreCompleto, contrasena) {
    return solicitudHTTP('/auth/register', {
      method: 'POST',
      body: JSON.stringify({
        email: email.trim(),
        nombre: nombreCompleto.trim(),
        password: contrasena,
      }),
    });
  },

  /**
   * Iniciar sesión
   */
  async iniciarSesion(email, contrasena) {
    return solicitudHTTP('/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        email: email.trim(),
        password: contrasena,
      }),
    });
  },

  /**
   * Obtener datos del usuario actual
   */
  async obtenerUsuarioActual() {
    return solicitudHTTP('/auth/me');
  },

  /**
   * Cerrar sesión
   */
  async cerrarSesion() {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    return { exito: true };
  },
};

/**
 * Servicios de Comunidades
 */
export const serviciosComunidades = {
  /**
   * Obtener todas las comunidades
   */
  async obtenerTodas() {
    return solicitudHTTP('/communities');
  },

  /**
   * Crear nueva comunidad
   */
  async crear(nombre, descripcion) {
    return solicitudHTTP('/communities', {
      method: 'POST',
      body: JSON.stringify({
        nombre: nombre.trim(),
        descripcion: descripcion.trim(),
      }),
    });
  },

  /**
   * Unirse a una comunidad
   */
  async unirse(comunidadId) {
    return solicitudHTTP('/communities/join', {
      method: 'POST',
      body: JSON.stringify({ comunidad_id: comunidadId }),
    });
  },

  /**
   * Obtener miembros de una comunidad
   */
  async obtenerMiembros(comunidadId) {
    return solicitudHTTP(`/communities/${comunidadId}/members`);
  },
};

/**
 * Servicios de Publicaciones
 */
export const serviciosPublicaciones = {
  /**
   * Obtener feed de publicaciones
   */
  async obtenerFeed() {
    return solicitudHTTP('/posts/feed');
  },

  /**
   * Obtener publicaciones de una comunidad
   */
  async obtenerPorComunidad(comunidadId) {
    return solicitudHTTP(`/posts/community/${comunidadId}`);
  },

  /**
   * Crear nueva publicación
   */
  async crear(comunidadId, contenido) {
    return solicitudHTTP('/posts', {
      method: 'POST',
      body: JSON.stringify({
        comunidad_id: comunidadId,
        contenido: contenido.trim(),
      }),
    });
  },

  /**
   * Obtener publicación por ID
   */
  async obtenerPorId(postId) {
    return solicitudHTTP(`/posts/${postId}`);
  },

  /**
   * Eliminar publicación
   */
  async eliminar(postId) {
    return solicitudHTTP(`/posts/${postId}`, {
      method: 'DELETE',
    });
  },
};

/**
 * Servicios de Comentarios
 */
export const serviciosComentarios = {
  /**
   * Obtener comentarios de una publicación
   */
  async obtenerPorPost(postId) {
    return solicitudHTTP(`/comments/post/${postId}`);
  },

  /**
   * Crear comentario
   */
  async crear(postId, contenido) {
    return solicitudHTTP('/comments', {
      method: 'POST',
      body: JSON.stringify({
        publicacion_id: postId,
        contenido: contenido.trim(),
      }),
    });
  },

  /**
   * Eliminar comentario
   */
  async eliminar(comentarioId) {
    return solicitudHTTP(`/comments/${comentarioId}`, {
      method: 'DELETE',
    });
  },
};

/**
 * Servicios de Likes
 */
export const serviciosLikes = {
  /**
   * Dar like a una publicación
   */
  async darLike(postId) {
    return solicitudHTTP('/likes', {
      method: 'POST',
      body: JSON.stringify({ publicacion_id: postId }),
    });
  },

  /**
   * Quitar like de una publicación
   */
  async quitarLike(postId) {
    return solicitudHTTP(`/likes/${postId}`, {
      method: 'DELETE',
    });
  },
};

/**
 * Servicios de Notificaciones
 */
export const serviciosNotificaciones = {
  /**
   * Obtener notificaciones del usuario
   */
  async obtener() {
    return solicitudHTTP('/notifications');
  },

  /**
   * Marcar notificación como leída
   */
  async marcarLeida(notificacionId) {
    return solicitudHTTP(`/notifications/${notificacionId}/read`, {
      method: 'PATCH',
    });
  },
};

/**
 * Servicios de Reportes
 */
export const serviciosReportes = {
  /**
   * Reportar contenido
   */
  async reportar(tipo, referenciaId, motivo) {
    return solicitudHTTP('/reports', {
      method: 'POST',
      body: JSON.stringify({
        tipo,
        referencia_id: referenciaId,
        motivo: motivo.trim(),
      }),
    });
  },
};
