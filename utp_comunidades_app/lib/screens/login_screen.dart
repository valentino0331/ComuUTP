import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotEmailController = TextEditingController();
  bool _mostrarPassword = false;
  bool _emailHasError = false;
  bool _passwordHasError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _performShakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFB21132);
    const Color darkBg = Color(0xFF090A0B);
    const Color grayInput = Color(0xFFEDF0F2);
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth > 400 ? 345.0 : screenWidth - 32;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Stack(
            children: [
              // Fondo blanco
              Container(color: Colors.white),
              
              // Sin overlay rojo

              // Contenido principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rectángulo rojo principal con animación de shake
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (BuildContext context, Widget? child) {
                          final shakeValue = Tween<double>(begin: 0.0, end: 10.0)
                              .chain(CurveTween(curve: Curves.elasticInOut))
                              .evaluate(_shakeController);
                          return Transform.translate(
                            offset: Offset(shakeValue * ((_shakeController.value % 2) < 1 ? 1 : -1), 0),
                            child: child,
                          );
                        },
                        child: Container(
                          constraints: BoxConstraints(maxWidth: containerWidth),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: primaryRed,
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: primaryRed.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              
                              // Ícono PROMINENTE - sin círculo visible, tamaño grande
                              Image.asset(
                                'icon.png',
                                height: 280,
                                width: 280,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 10),

                              // Etiqueta: Correo o Código UTP
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Correo o Código UTP',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Campo de correo
                              Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: grayInput.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(14),
                                  border: _emailHasError
                                      ? Border.all(color: Colors.red[400]!, width: 2)
                                      : null,
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_emailHasError) {
                                      setState(() => _emailHasError = false);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'correo@utp.edu.pe',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Etiqueta: Contraseña
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Contraseña',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: grayInput.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(14),
                                  border: _passwordHasError
                                      ? Border.all(color: Colors.red[400]!, width: 2)
                                      : null,
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_mostrarPassword,
                                  onChanged: (_) {
                                    if (_passwordHasError) {
                                      setState(() => _passwordHasError = false);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Tu contraseña',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _mostrarPassword = !_mostrarPassword;
                                        });
                                      },
                                      child: Icon(
                                        _mostrarPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF999999),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // Error message si falla login
                              if (authProvider.loginError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red[400]!, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red[700], size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authProvider.loginError!,
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 32),

                              // Botón Ingresar
                              GestureDetector(
                                onTap: authProvider.loading
                                    ? null
                                    : () async {
                                        // Reset errors
                                        setState(() {
                                          _emailHasError = false;
                                          _passwordHasError = false;
                                        });

                                        final email = _emailController.text.trim();
                                        final password = _passwordController.text.trim();

                                        // Validation
                                        if (email.isEmpty || password.isEmpty) {
                                          _performShakeAnimation();
                                          if (email.isEmpty) {
                                            setState(() => _emailHasError = true);
                                          }
                                          if (password.isEmpty) {
                                            setState(() => _passwordHasError = true);
                                          }
                                          return;
                                        }

                                        final success = await authProvider.login(email, password);
                                        if (mounted) {
                                          if (success) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/main',
                                            );
                                          } else if (authProvider.needsEmailVerification) {
                                            // Redirigir a pantalla de verificación
                                            Navigator.pushNamed(
                                              context,
                                              '/verify-email',
                                              arguments: {
                                                'email': authProvider.verificationEmail ?? email,
                                              },
                                            );
                                          } else {
                                            _performShakeAnimation();
                                            setState(() => _passwordHasError = true);
                                          }
                                        }
                                      },
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: darkBg,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: darkBg.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: authProvider.loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Ingresar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Texto: ¿Olvidaste tu contraseña?
                              GestureDetector(
                                onTap: () {
                                  _forgotEmailController.clear();
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) => Container(
                                      margin: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Handle bar
                                          Container(
                                            width: 36,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          // Icono
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB21132).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lock_reset,
                                              color: Color(0xFFB21132),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Recuperar contraseña',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Ingresa tu correo UTP y te enviaremos un enlace para restablecer tu contraseña',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          TextField(
                                            controller: _forgotEmailController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              hintText: 'correo@utp.edu.pe',
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFB21132)),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: Color(0xFFB21132), width: 2),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                              hintStyle: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Color(0xFF999999),
                                                fontSize: 14,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                var email = _forgotEmailController.text.trim();
                                                // Convertir código a email si no tiene @
                                                if (!email.contains('@')) {
                                                  email = email + '@utp.edu.pe';
                                                }
                                                if (email.isEmpty || !email.contains('@utp.edu.pe')) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Ingresa un correo UTP válido'),
                                                      behavior: SnackBarBehavior.floating,
                                                      backgroundColor: Colors.red,
                                                      duration: Duration(seconds: 2),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Enlace enviado a $email'),
                                                    behavior: SnackBarBehavior.floating,
                                                    backgroundColor: Colors.green,
                                                    duration: const Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFB21132),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Enviar enlace',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Botón de registrar
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/register'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '¿No tienes cuenta? ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'Registrate',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
