import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFB21132);
    const Color darkBg = Color(0xFF090A0B);
    const Color grayInput = Color(0xFFEDF0F2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Stack(
            children: [
              // Fondo blanco
              Container(color: Colors.white),
              
              // Overlay rojo semi-transparente
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132).withValues(alpha: 0.34),
                ),
              ),

              // Contenido principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rectángulo rojo principal
                      Container(
                        width: 345,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: primaryRed,
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 44),
                            
                            // Título "Bienvenido a UTP Comunidades"
                            const Text(
                              'Bienvenido a UTP\nComunidades',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                height: 32 / 26,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 87),

                            // Etiqueta: Correo o Código UTP
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Correo o Código UTP',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 18 / 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 9),

                            // Campo de correo
                            Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: grayInput.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'correo@utp.edu.pe',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF999999),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Por favor ingresa tu correo';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 54),

                            // Etiqueta: Contraseña
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 18 / 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 9),

                            // Campo de contraseña
                            Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: grayInput.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_mostrarPassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tu contraseña',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontFamily: 'Montserrat',
                                  ),
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
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Por favor ingresa tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 80),

                            // Botón Ingresar
                            GestureDetector(
                              onTap: authProvider.loading
                                  ? null
                                  : () {
                                      if (_emailController.text.isNotEmpty &&
                                          _passwordController.text.isNotEmpty) {
                                        authProvider
                                            .login(
                                          _emailController.text,
                                          _passwordController.text,
                                        )
                                            .then((success) {
                                          if (success && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/main',
                                            );
                                          }
                                        });
                                      }
                                    },
                              child: Container(
                                height: 39,
                                width: 263,
                                decoration: BoxDecoration(
                                  color: darkBg,
                                  borderRadius: BorderRadius.circular(37),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Ingresar',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      height: 20 / 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Texto: ¿Olvidaste tu contraseña?
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Función en desarrollo',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 16 / 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Botón para entrar como Admin (solo desarrollo)
                            GestureDetector(
                              onTap: authProvider.loading
                                  ? null
                                  : () {
                                      authProvider.loginAsAdmin().then((success) {
                                        if (success && mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/main',
                                          );
                                        }
                                      });
                                    },
                              child: Container(
                                height: 39,
                                width: 263,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB21132),
                                  borderRadius: BorderRadius.circular(37),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Entrar como Admin',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
