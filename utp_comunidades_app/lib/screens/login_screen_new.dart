import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _controlEmail = TextEditingController();
  final _controlPassword = TextEditingController();
  bool _mostrarPassword = false;
  bool _cargando = false;

  @override
  void dispose() {
    _controlEmail.dispose();
    _controlPassword.dispose();
    super.dispose();
  }

  /// Validar correo UTP
  String? _validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!valor.endsWith('@utp.edu.pe')) {
      return 'Debe ser un correo @utp.edu.pe';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@utp\.edu\.pe$').hasMatch(valor)) {
      return 'Correo inválido';
    }
    return null;
  }

  /// Validar contraseña
  String? _validarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Procesar login
  Future<void> _procesarLogin() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final provedor = context.read<AuthProvider>();
      final exito = await provedor.iniciarSesion(
        _controlEmail.text.trim(),
        _controlPassword.text,
      );

      if (exito) {
        if (mounted) {
          // Navegar a pantalla principal
          Navigator.of(context).pushReplacementNamed('/main');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido a UTP Comunidades!'),
              backgroundColor: AppTheme.colorPrimary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provedor.mensajeError ?? 'Error al iniciar sesión'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBlancoFondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo UTP
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.colorPrimary,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusStandard),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'UTP Comunidades',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colorNegro,
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo
              const Text(
                'Conecta con tu comunidad universitaria',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.colorGris,
                ),
              ),
              const SizedBox(height: 40),

              // Formulario
              Form(
                key: _formulario,
                child: Column(
                  children: [
                    // Campo Email
                    TextFormField(
                      controller: _controlEmail,
                      enabled: !_cargando,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo UTP',
                        hintText: 'tu.email@utp.edu.pe',
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: _controlEmail.text.isNotEmpty
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.colorPrimary)
                            : null,
                      ),
                      onChanged: (valor) => setState(() {}),
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 16),

                    // Campo Contraseña
                    TextFormField(
                      controller: _controlPassword,
                      enabled: !_cargando,
                      obscureText: !_mostrarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppTheme.colorGris,
                          ),
                          onPressed: () => setState(
                              () => _mostrarPassword = !_mostrarPassword),
                        ),
                      ),
                      validator: _validarPassword,
                    ),
                    const SizedBox(height: 24),

                    // Botón Login
                    ElevatedButton(
                      onPressed: _cargando ? null : _procesarLogin,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Enlace Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(color: AppTheme.colorGris),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/register'),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: AppTheme.colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
