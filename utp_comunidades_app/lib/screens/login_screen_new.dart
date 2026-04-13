import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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

  // Colores del diseño
  static const Color colorPrimario = Color(0xFFB21132);
  static const Color colorFondoOverlay = Color(0x57B21132); // rgba(178, 17, 50, 0.34)
  static const Color colorInput = Color(0xD2EDF0F2); // rgba(237, 240, 242, 0.82)
  static const Color colorBoton = Color(0xFF090A0B);
  static const Color colorTextoBlanco = Colors.white;

  @override
  void dispose() {
    _controlEmail.dispose();
    _controlPassword.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!valor.endsWith('@utp.edu.pe')) {
      return 'Debe ser un correo @utp.edu.pe';
    }
    return null;
  }

  String? _validarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<void> _procesarLogin() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final provedor = context.read<AuthProvider>();
      final exito = await provedor.login(
        _controlEmail.text.trim(),
        _controlPassword.text,
      );

      if (exito && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido a UTP Comunidades!'),
            backgroundColor: colorPrimario,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provedor.error ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo con overlay rojo semitransparente
          Container(
            width: double.infinity,
            height: double.infinity,
            color: colorFondoOverlay,
          ),

          // Contenido centrado
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card principal roja
                    Container(
                      width: 345,
                      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 44),
                      decoration: BoxDecoration(
                        color: colorPrimario,
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Form(
                        key: _formulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título "Bienvenido a UTP Comunidades"
                            const Center(
                              child: Text(
                                'Bienvenido a UTP Comunidades',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  height: 1.23,
                                  color: colorTextoBlanco,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Label "Correo o Código UTP"
                            const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 9),
                              child: Text(
                                'Correo o Código UTP',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  color: colorTextoBlanco,
                                ),
                              ),
                            ),

                            // Input Email - Solución definitiva
                            SizedBox(
                              height: 55,
                              child: TextFormField(
                                controller: _controlEmail,
                                enabled: !_cargando,
                                keyboardType: TextInputType.emailAddress,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colorInput,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: const BorderSide(color: Colors.red, width: 1),
                                  ),
                                  hintText: 'ejemplo@utp.edu.pe',
                                  hintStyle: const TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                validator: _validarEmail,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Label "Contraseña"
                            const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 9),
                              child: Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  color: colorTextoBlanco,
                                ),
                              ),
                            ),

                            // Input Contraseña - Solución definitiva
                            SizedBox(
                              height: 55,
                              child: TextFormField(
                                controller: _controlPassword,
                                enabled: !_cargando,
                                obscureText: !_mostrarPassword,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colorInput,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: const BorderSide(color: Colors.red, width: 1),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black45,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _mostrarPassword = !_mostrarPassword),
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                validator: _validarPassword,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Botón "Ingresar"
                            Center(
                              child: SizedBox(
                                width: 263,
                                height: 39,
                                child: ElevatedButton(
                                  onPressed: _cargando ? null : _procesarLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorBoton,
                                    foregroundColor: colorTextoBlanco,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(37),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _cargando
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
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
                                            fontWeight: FontWeight.w600,
                                            height: 1.25,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // "¿Olvidaste tu contraseña?"
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navegar a recuperar contraseña
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.23,
                                    color: colorTextoBlanco,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // "Crear cuenta"
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text(
                                  '¿No tienes cuenta? Crear cuenta',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.23,
                                    color: colorTextoBlanco,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
