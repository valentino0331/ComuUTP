import React, { useState, useEffect } from 'react';

/**
 * Componente PantallaInicio (Splash Screen)
 * Muestra logo, título y carga animada
 */
const PantallaInicio = ({ onComplete }) => {
  const [opacity, setOpacity] = useState(0);

  useEffect(() => {
    // Animar logo
    setOpacity(1);

    // Después de 4 segundos, llamar al callback
    const timer = setTimeout(() => {
      if (onComplete) onComplete();
    }, 4000);

    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <div className="splash-container">
      <div
        className="splash-logo"
        style={{
          opacity: opacity,
          transition: 'opacity 0.8s ease-in',
        }}
      >
        <span style={{ fontSize: '60px' }}>🏫</span>
      </div>

      <h1
        className="splash-title"
        style={{
          opacity: opacity,
          transition: 'opacity 0.8s ease-in 0.2s',
          transitionFillMode: 'both',
        }}
      >
        UTP Comunidades
      </h1>

      <p
        className="splash-subtitle"
        style={{
          opacity: opacity,
          transition: 'opacity 0.8s ease-in 0.4s',
          transitionFillMode: 'both',
        }}
      >
        Conecta con tu comunidad
      </p>

      <div
        className="splash-spinner"
        style={{
          opacity: opacity,
          transition: 'opacity 0.8s ease-in 0.6s',
          transitionFillMode: 'both',
        }}
      >
        <div className="spinner"></div>
      </div>
    </div>
  );
};

export default PantallaInicio;
