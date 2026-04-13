import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionOpacidad;
  late Animation<double> _animacionEscala;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _controladorAnimacion = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Opacidad suave
    _animacionOpacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeIn),
    );

    // Escala para el logo
    _animacionEscala = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeOut),
    );

    _controladorAnimacion.forward();

    // Después de 2 segundos, ir a login
    Timer(const Duration(seconds: 2), () {
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
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animacionOpacidad,
        child: Center(
          child: Container(
            width: 390,
            height: 844,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB21132), Color(0xFF8B1A2A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'UTP Comunidades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
