import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Widget de animación Lottie para estado de carga
class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingAnimation({
    super.key,
    this.size = 120,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/loading.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}

/// Widget de animación Lottie para estado vacío
class EmptyStateAnimation extends StatelessWidget {
  final double size;
  final String? message;

  const EmptyStateAnimation({
    super.key,
    this.size = 150,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'assets/lottie/empty.json',
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Widget de animación Lottie para éxito
class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    this.size = 100,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/success.json',
        fit: BoxFit.contain,
        repeat: false,
        onLoaded: (composition) {
          if (onComplete != null) {
            Future.delayed(composition.duration, onComplete!);
          }
        },
      ),
    );
  }
}

/// Widget de animación Lottie para robot IA
class AIRobotAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final bool isFloating;

  const AIRobotAnimation({
    super.key,
    this.size = 80,
    this.onTap,
    this.isFloating = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget robot = SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/ai_robot.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );

    if (isFloating) {
      robot = _FloatingAnimation(child: robot);
    }

    if (onTap != null) {
      robot = GestureDetector(
        onTap: onTap,
        child: robot,
      );
    }

    return robot;
  }
}

/// Animación de flotación suave
class _FloatingAnimation extends StatefulWidget {
  final Widget child;

  const _FloatingAnimation({required this.child});

  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pantalla de carga con animación Lottie
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingAnimation(size: 150),
            const SizedBox(height: 24),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de éxito con animación Lottie
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuccessAnimation(
              size: 120,
              onComplete: () {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (onDismiss != null) onDismiss!();
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB21132),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}
