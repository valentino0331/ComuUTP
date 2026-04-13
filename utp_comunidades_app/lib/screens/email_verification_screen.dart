import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String uid;
  final String email;
  final String nombre;
  final String? apellido;
  final String? carrera;
  final int? ciclo;

  const EmailVerificationScreen({
    super.key,
    required this.uid,
    required this.email,
    required this.nombre,
    this.apellido,
    this.carrera,
    this.ciclo,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;

  static const Color colorPrimario = Color(0xFFB21132);
  static const Color colorFondoOverlay = Color(0x57B21132);
  static const Color colorBoton = Color(0xFF090A0B);
  static const Color colorTextoBlanco = Colors.white;

  @override
  void initState() {
    super.initState();
    // Verificar periódicamente si el email fue verificado
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    if (_isVerified || _isLoading) return;

    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.checkEmailVerified();

    if (isVerified && mounted) {
      setState(() => _isVerified = true);
      _timer?.cancel();
      
      // Completar registro en Neon
      await _completeRegistration();
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.completeRegistration(
      uid: widget.uid,
      email: widget.email,
      nombre: widget.nombre,
      apellido: widget.apellido,
      carrera: widget.carrera,
      ciclo: widget.ciclo,
    );

    if (!mounted) return;

    if (success) {
      // Registro completado, ir a login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro completado! Ahora inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _isLoading = false;
        _error = authProvider.error ?? 'Error al completar registro';
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.resendVerificationEmail();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email de verificación reenviado'),
        backgroundColor: colorPrimario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: colorFondoOverlay,
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 345,
                      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 44),
                      decoration: BoxDecoration(
                        color: colorPrimario,
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Column(
                        children: [
                          // Icono
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isVerified 
                                ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                                : PhosphorIcons.envelope(PhosphorIconsStyle.fill),
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          Text(
                            _isVerified ? '¡Email verificado!' : 'Verifica tu correo',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: colorTextoBlanco,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Descripción
                          Text(
                            _isVerified
                              ? 'Tu cuenta ha sido verificada. Completando registro...'
                              : 'Hemos enviado un link de verificación a:\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: colorTextoBlanco.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (!_isVerified) ...[
                            // Indicador de carga
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Esperando verificación...',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: colorTextoBlanco.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Botón reenviar
                            TextButton(
                              onPressed: _isLoading ? null : _resendEmail,
                              child: Text(
                                'Reenviar email',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: colorTextoBlanco.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],

                          if (_isVerified && _isLoading) ...[
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Completando registro...',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: colorTextoBlanco,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Link volver
                          GestureDetector(
                            onTap: () {
                              _timer?.cancel();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
                                  color: colorTextoBlanco.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Volver al login',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: colorTextoBlanco.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
