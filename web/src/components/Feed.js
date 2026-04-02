import React, { useState, useEffect } from 'react';
import { CLIENT_API } from '../services/apiService';

/**
 * Componente PantallaFeed - Muestra feed de publicaciones
 * Permite ver, comentar y dar like a posts
 */
const PantallaFeed = ({ usuario }) => {
  const [posts, setPosts] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  // Cargar posts al montar el componente
  useEffect(() => {
    cargarPosts();
  }, []);

  /**
   * Cargar publicaciones desde la API
   */
  const cargarPosts = async () => {
    setCargando(true);
    setError('');

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${CLIENT_API}/posts/feed`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const datos = await response.json();
        setPosts(datos.posts || []);
      } else {
        setError('Error al cargar los posts');
      }
    } catch (error) {
      setError(`Error: ${error.message}`);
    } finally {
      setCargando(false);
    }
  };

  /**
   * Calcular tiempo transcurrido
   */
  const haceCuantoTiempo = (fecha) => {
    const ahora = new Date();
    const fechaPost = new Date(fecha);
    const diferencia = Math.floor((ahora - fechaPost) / 1000);

    if (diferencia < 60) return 'Hace unos segundos';
    if (diferencia < 3600) return `Hace ${Math.floor(diferencia / 60)}m`;
    if (diferencia < 86400) return `Hace ${Math.floor(diferencia / 3600)}h`;
    if (diferencia < 604800) return `Hace ${Math.floor(diferencia / 86400)}d`;

    return fechaPost.toLocaleDateString('es-PE');
  };

  /**
   * Dar like a un post
   */
  const darLike = async (postId) => {
    try {
      const token = localStorage.getItem('token');
      await fetch(`${CLIENT_API}/likes`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ publicacion_id: postId }),
      });

      // Recargar posts
      cargarPosts();
    } catch (error) {
      console.error('Error al dar like:', error);
    }
  };

  /**
   * Renderizar estado de carga
   */
  if (cargando) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '50vh',
          gap: '16px',
        }}
      >
        <div className="spinner"></div>
        <p style={{ color: '#9E9E9E' }}>Cargando publicaciones...</p>
      </div>
    );
  }

  /**
   * Renderizar error
   */
  if (error) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '50vh',
          gap: '16px',
        }}
      >
        <span style={{ fontSize: '48px' }}>⚠️</span>
        <p style={{ color: '#ff5252' }}>{error}</p>
        <button
          className="btn btn-primary"
          onClick={cargarPosts}
          style={{ maxWidth: '150px' }}
        >
          Reintentar
        </button>
      </div>
    );
  }

  /**
   * Renderizar estado vacío
   */
  if (posts.length === 0) {
    return (
      <div className="feed-container">
        <div className="empty-state">
          <div className="empty-state-icon">📭</div>
          <h3 className="empty-state-title">No hay posts aún</h3>
          <p className="empty-state-text">
            Sé el primero en compartir algo con tu comunidad
          </p>
          <button className="btn btn-primary">Crear primer post</button>
        </div>
      </div>
    );
  }

  /**
   * Renderizar feed
   */
  return (
    <div className="feed-container">
      {/* Encabezado */}
      <div className="feed-header">
        <h2 className="feed-title">Feed de Comunidades</h2>
        <button className="feed-create-btn" title="Crear nuevo post">
          ➕
        </button>
      </div>

      {/* Lista de posts */}
      {posts.map((post) => (
        <div key={post.id} className="post-card">
          {/* Encabezado del post */}
          <div className="post-header">
            <div className="post-author">
              <div className="post-avatar">
                {post.nombreUsuario?.charAt(0).toUpperCase() || '👤'}
              </div>
              <div className="post-info">
                <div className="post-author-name">
                  {post.nombreUsuario || 'Usuario'}
                </div>
                <div className="post-meta">
                  {post.nombreComunidad || 'Comunidad'} •{' '}
                  {haceCuantoTiempo(post.fecha)}
                </div>
              </div>
            </div>
            <div className="post-menu">⋮</div>
          </div>

          {/* Contenido del post */}
          <p className="post-content">{post.contenido}</p>

          {/* Acciones */}
          <div className="post-actions">
            <button
              className="post-action-btn"
              onClick={() => darLike(post.id)}
              title="Me gusta"
            >
              <span className="post-action-icon">❤️</span>
              <span>{post.likes || 0}</span>
            </button>
            <button className="post-action-btn" title="Comentar">
              <span className="post-action-icon">💬</span>
              <span>{post.comentarios || 0}</span>
            </button>
            <button className="post-action-btn" title="Compartir">
              <span className="post-action-icon">📤</span>
              <span>Compartir</span>
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default PantallaFeed;
