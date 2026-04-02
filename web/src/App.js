import React, { useState, useEffect } from 'react';
import PantallaInicio from './components/SplashScreen';
import PantallaLogin from './components/Login';
import PantallaFeed from './components/Feed';
import './styles/global.css';
import './styles/components.css';

/**
 * Componente principal - Enrutador de la aplicación
 */
function App() {
  const [pantalla, setPantalla] = useState('splash'); // splash, login, feed
  const [usuario, setUsuario] = useState(null);

  // Verificar autenticación al montar
  useEffect(() => {
    const token = localStorage.getItem('token');
    const usuarioGuardado = localStorage.getItem('usuario');

    if (token && usuarioGuardado) {
      setUsuario(JSON.parse(usuarioGuardado));
      setPantalla('feed');
    }
  }, []);

  /**
   * Manejar fin del splash screen
   */
  const handleSplashComplete = () => {
    const token = localStorage.getItem('token');
    if (token) {
      setPantalla('feed');
    } else {
      setPantalla('login');
    }
  };

  /**
   * Manejar login exitoso
   */
  const handleLoginSuccess = (usuarioData) => {
    setUsuario(usuarioData);
    setPantalla('feed');
  };

  /**
   * Cerrar sesión
   */
  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    setUsuario(null);
    setPantalla('login');
  };

  // Renderizar pantalla actual
  if (pantalla === 'splash') {
    return <PantallaInicio onComplete={handleSplashComplete} />;
  }

  if (pantalla === 'login') {
    return <PantallaLogin onLoginSuccess={handleLoginSuccess} />;
  }

  if (pantalla === 'feed') {
    return (
      <div style={{ minHeight: '100vh', backgroundColor: '#f5f5f5' }}>
        {/* Navbar */}
        <nav className="navbar">
          <div className="navbar-container">
            <a href="#/" className="navbar-brand">
              🏫 UTP Comunidades
            </a>
            <div className="navbar-menu">
              <span style={{ fontSize: '14px' }}>
                {usuario?.nombre || 'Usuario'}
              </span>
              <button
                onClick={handleLogout}
                style={{
                  background: 'rgba(255,255,255,0.2)',
                  border: 'none',
                  color: 'white',
                  padding: '8px 16px',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '14px',
                }}
              >
                Cerrar sesión
              </button>
            </div>
          </div>
        </nav>

        {/* Contenido */}
        <PantallaFeed usuario={usuario} />
      </div>
    );
  }

  return null;
}

export default App;
