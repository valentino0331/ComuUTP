import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:shimmer/shimmer.dart';

/// Estados del personaje Rive interactivo
enum MascotState {
  idle,
  loading,
  success,
  error,
  thinking,
  happy,
  confused,
}

/// Personaje Rive Interactivo - Mascota IA con State Machine
class InteractiveMascot extends StatefulWidget {
  final MascotState state;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const InteractiveMascot({
    super.key,
    this.state = MascotState.idle,
    this.size = 120,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<InteractiveMascot> createState() => _InteractiveMascotState();
}

class _InteractiveMascotState extends State<InteractiveMascot> {
  late RiveAnimationController _controller;
  SMIInput<bool>? _isLoading;
  SMIInput<bool>? _isSuccess;
  SMIInput<bool>? _isError;
  SMIInput<bool>? _isThinking;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('idle');
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      _isLoading = controller.findInput<bool>('isLoading');
      _isSuccess = controller.findInput<bool>('isSuccess');
      _isError = controller.findInput<bool>('isError');
      _isThinking = controller.findInput<bool>('isThinking');
      _updateState();
    }
  }

  void _updateState() {
    _isLoading?.value = widget.state == MascotState.loading;
    _isSuccess?.value = widget.state == MascotState.success;
    _isError?.value = widget.state == MascotState.error;
    _isThinking?.value = widget.state == MascotState.thinking;
  }

  @override
  void didUpdateWidget(InteractiveMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB21132).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildFallbackMascot(),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: const Duration(seconds: 2),
      color: const Color(0xFFB21132).withOpacity(0.1),
    );
  }

  /// Fallback: Mascota animada con Flutter nativo mientras no tengamos .riv
  Widget _buildFallbackMascot() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB21132), Color(0xFF8B0D26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: _buildAnimatedFace(),
      ),
    );
  }

  Widget _buildAnimatedFace() {
    switch (widget.state) {
      case MascotState.loading:
        return _buildLoadingFace();
      case MascotState.success:
        return _buildSuccessFace();
      case MascotState.error:
        return _buildErrorFace();
      case MascotState.thinking:
        return _buildThinkingFace();
      case MascotState.happy:
        return _buildHappyFace();
      case MascotState.confused:
        return _buildConfusedFace();
      case MascotState.idle:
      default:
        return _buildIdleFace();
    }
  }

  Widget _buildIdleFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Robot face design
        Container(
          width: widget.size * 0.5,
          height: widget.size * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.size * 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eyes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: widget.size * 0.08,
                    height: widget.size * 0.08,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB21132),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: widget.size * 0.08),
                  Container(
                    width: widget.size * 0.08,
                    height: widget.size * 0.08,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB21132),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.size * 0.05),
              // Smile
              Container(
                width: widget.size * 0.15,
                height: widget.size * 0.04,
                decoration: BoxDecoration(
                  color: const Color(0xFFB21132),
                  borderRadius: BorderRadius.circular(widget.size * 0.02),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.size * 0.05),
        // Antenna
        Container(
          width: widget.size * 0.02,
          height: widget.size * 0.08,
          color: Colors.white,
        ),
        Container(
          width: widget.size * 0.06,
          height: widget.size * 0.06,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: const Duration(milliseconds: 500))
            .fadeOut(duration: const Duration(milliseconds: 500)),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -5, duration: const Duration(milliseconds: 2000), curve: Curves.easeInOut);
  }

  Widget _buildLoadingFace() {
    return Icon(
      Icons.psychology,
      size: widget.size * 0.5,
      color: Colors.white,
    )
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: const Duration(milliseconds: 1000));
  }

  Widget _buildSuccessFace() {
    return Icon(
      Icons.check_circle,
      size: widget.size * 0.5,
      color: Colors.white,
    )
        .animate()
        .scale(duration: const Duration(milliseconds: 400), curve: Curves.elasticOut)
        .shake(duration: const Duration(milliseconds: 500));
  }

  Widget _buildErrorFace() {
    return Icon(
      Icons.error_outline,
      size: widget.size * 0.5,
      color: Colors.white70,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shake(duration: const Duration(milliseconds: 500));
  }

  Widget _buildThinkingFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: widget.size * 0.4,
          color: Colors.white,
        ),
        Positioned(
          top: widget.size * 0.15,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: const Duration(milliseconds: 500))
              .fadeOut(duration: const Duration(milliseconds: 500)),
        ),
      ],
    );
  }

  Widget _buildHappyFace() {
    return Icon(
      Icons.sentiment_very_satisfied,
      size: widget.size * 0.5,
      color: Colors.white,
    )
        .animate()
        .scale(duration: const Duration(milliseconds: 300), curve: Curves.bounceOut);
  }

  Widget _buildConfusedFace() {
    return Icon(
      Icons.help_outline,
      size: widget.size * 0.5,
      color: Colors.white70,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.1, end: 0.1, duration: const Duration(milliseconds: 800));
  }
}

/// Botón con microinteracciones avanzadas
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool isLoading;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height ?? 52,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFFB21132),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: (widget.backgroundColor ?? const Color(0xFFB21132)).withOpacity(0.4),
                blurRadius: _isPressed ? 0 : 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(duration: const Duration(milliseconds: 200))
              : DefaultTextStyle(
                  style: TextStyle(
                    color: widget.foregroundColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  child: widget.child,
                ),
        ),
      ),
    ).animate(
      target: _isPressed ? 1 : 0,
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
      duration: const Duration(milliseconds: 100),
    );
  }
}

/// Skeleton Loader moderno con Shimmer
class ModernSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ModernSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Card con efecto de entrada animada
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFFB21132).withOpacity(0.1),
            highlightColor: const Color(0xFFB21132).withOpacity(0.05),
            child: child,
          ),
        ),
      ),
    );

    return card
        .animate(
          delay: Duration(milliseconds: index * 50),
        )
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }
}

/// Toast notification animado
class AnimatedToast extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  const AnimatedToast({
    super.key,
    required this.message,
    this.isError = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isError ? Colors.red[600] : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isError ? Colors.red : Colors.black).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(
          begin: -0.5,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        )
        .then(delay: const Duration(seconds: 2))
        .slideY(begin: 0, end: -1, duration: const Duration(milliseconds: 300))
        .fadeOut(duration: const Duration(milliseconds: 200));
  }
}

/// Transición de página personalizada
class CustomPageTransitions {
  static PageRouteBuilder<T> fadeScale<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> slideUp<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

/// Extensiones útiles para animaciones
extension AnimationExtensions on Widget {
  Widget fadeInList(int index, {Duration delay = Duration.zero}) {
    return animate(
      delay: Duration(milliseconds: index * 50) + delay,
    ).fadeIn(
      duration: const Duration(milliseconds: 400),
    ).slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget pulseAnimation() {
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  Widget bounceIn() {
    return animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
    ).fadeIn(
      duration: const Duration(milliseconds: 300),
    );
  }
}
