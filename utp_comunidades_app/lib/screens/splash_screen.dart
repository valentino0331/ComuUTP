import 'package:flutter/material.dart';
import 'dart:async';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionOpacidad;

  @override
  void initState() {
    super.initState();

    // Configurar animación de opacidad para el logo
    _controladorAnimacion = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animacionOpacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeIn),
    );

    _controladorAnimacion.forward();

    // Después de 4 segundos, ir a login
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con animación de opacidad
            FadeTransition(
              opacity: _animacionOpacidad,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED1C24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'UTP Comunidades',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conecta con tu comunidad',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Indicador de carga
            FadeTransition(
              opacity: _animacionOpacidad,
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFED1C24)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
