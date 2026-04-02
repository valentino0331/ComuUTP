import React, { useState } from 'react';
import { CLIENT_API } from '../services/apiService';

/**
 * Componente PantallaLogin - Autenticación de usuarios UTP
 * Valida correo @utp.edu.pe y contraseña
 */
const PantallaLogin = ({ onLoginSuccess }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mostrarPassword, setMostrarPassword] = useState(false);
  const [cargando, setCargando] = useState(false);
  const [errores, setErrores] = useState({});
  const [mensajeError, setMensajeError] = useState('');

  /**
   * Validar correo UTP
   */
  const validarEmail = (valor) => {
    if (!valor) return 'Por favor ingresa tu correo';
    if (!valor.endsWith('@utp.edu.pe')) {
      return 'Debe ser un correo @utp.edu.pe';
    }
    if (!/^[a-zA-Z0-9._%+-]+@utp\.edu\.pe$/.test(valor)) {
      return 'Correo inválido';
    }
    return '';
  };

  /**
   * Validar contraseña
   */
  const validarPassword = (valor) => {
    if (!valor) return 'Por favor ingresa tu contraseña';
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return '';
  };

  /**
   * Procesar login
   */
  const procesarLogin = async (e) => {
    e.preventDefault();

    // Validar campos
    const erroresTemp = {};
    erroresTemp.email = validarEmail(email);
    erroresTemp.password = validarPassword(password);

    setErrores(erroresTemp);

    if (erroresTemp.email || erroresTemp.password) {
      return;
    }

    setCargando(true);
    setMensajeError('');

    try {
      const response = await fetch(`${CLIENT_API}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email.trim(),
          password: password,
        }),
      });

      const datos = await response.json();

      if (response.ok) {
        // Guardar token
        localStorage.setItem('token', datos.token);
        localStorage.setItem('usuario', JSON.stringify(datos.usuario));

        // Callback de éxito
        if (onLoginSuccess) {
          onLoginSuccess(datos.usuario);
        }
      } else {
        setMensajeError(
          datos.mensaje || 'Error al iniciar sesión. Verifica tus credenciales.'
        );
      }
    } catch (error) {
      setMensajeError(`Error: ${error.message}`);
    } finally {
      setCargando(false);
    }
  };

  return (
    <div className="container-auth">
      {/* Logo */}
      <div className="login-logo">
        <span>🏫</span>
      </div>

      {/* Título */}
      <h1>UTP Comunidades</h1>

      {/* Subtítulo */}
      <p style={{ marginBottom: '32px', fontSize: '14px' }}>
        Conecta con tu comunidad universitaria
      </p>

      {/* Mensaje de error general */}
      {mensajeError && (
        <div
          style={{
            backgroundColor: '#ffebee',
            color: '#ff5252',
            padding: '12px',
            borderRadius: '8px',
            marginBottom: '20px',
            fontSize: '14px',
          }}
        >
          {mensajeError}
        </div>
      )}

      {/* Formulario */}
      <form onSubmit={procesarLogin} className="login-form">
        {/* Campo Email */}
        <div className="form-group">
          <label htmlFor="email">Correo UTP</label>
          <input
            id="email"
            type="email"
            placeholder="tu.email@utp.edu.pe"
            value={email}
            onChange={(e) => {
              setEmail(e.target.value);
              setErrores({ ...errores, email: '' });
            }}
            disabled={cargando}
          />
          {errores.email && (
            <span className="form-error">{errores.email}</span>
          )}
        </div>

        {/* Campo Contraseña */}
        <div className="form-group password-toggle">
          <label htmlFor="password">Contraseña</label>
          <input
            id="password"
            type={mostrarPassword ? 'text' : 'password'}
            placeholder="Mínimo 6 caracteres"
            value={password}
            onChange={(e) => {
              setPassword(e.target.value);
              setErrores({ ...errores, password: '' });
            }}
            disabled={cargando}
          />
          <button
            type="button"
            className="password-toggle-icon"
            onClick={() => setMostrarPassword(!mostrarPassword)}
            disabled={cargando}
          >
            {mostrarPassword ? '👁️' : '👁️‍🗨️'}
          </button>
          {errores.password && (
            <span className="form-error">{errores.password}</span>
          )}
        </div>

        {/* Botón Login */}
        <button
          type="submit"
          className="login-button"
          disabled={cargando}
        >
          {cargando ? (
            <>
              <div className="spinner" style={{ width: '20px', height: '20px' }}></div>
              <span>Cargando...</span>
            </>
          ) : (
            'Iniciar Sesión'
          )}
        </button>
      </form>

      {/* Enlace a Registro */}
      <div className="login-register-link">
        ¿No tienes cuenta?{' '}
        <a href="#/register">Regístrate aquí</a>
      </div>
    </div>
  );
};

export default PantallaLogin;
