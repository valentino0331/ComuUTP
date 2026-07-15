// filepath: utp_comunidades_app/lib/screens/duelo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/duelo_provider.dart';
import '../providers/auth_provider.dart';

class DueloScreen extends StatefulWidget {
  final int dueloId;
  final String opponentName;
  final String tema;

  const DueloScreen({
    super.key,
    required this.dueloId,
    required this.opponentName,
    required this.tema,
  });

  @override
  State<DueloScreen> createState() => _DueloScreenState();
}

class _DueloScreenState extends State<DueloScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  int? _respuestaSeleccionada;
  int _tiempoRestante = 30;
  late AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _countdownController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DueloProvider>(context, listen: false).obtenerDuelo(widget.dueloId);
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Evitar volver atrás durante duelo
      child: Scaffold(
        body: Consumer<DueloProvider>(
          builder: (context, dueloProvider, _) {
            if (dueloProvider.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final duelo = dueloProvider.dueloActual;
            final pregunta = dueloProvider.preguntaActual;

            if (duelo == null || pregunta == null) {
              return const Center(child: Text('Error al cargar duelo'));
            }

            return Stack(
              children: [
                // Fondo con gradiente
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimaryToCyan,
                  ),
                ),
                // Contenido
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(duelo, dueloProvider),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildRondaInfo(duelo, dueloProvider),
                                const SizedBox(height: 24),
                                _buildPregunta(pregunta),
                                const SizedBox(height: 24),
                                _buildOpciones(pregunta, dueloProvider),
                                const SizedBox(height: 24),
                                _buildBotonResponder(duelo, pregunta, dueloProvider),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Duelo duelo, DueloProvider dueloProvider) {
    final authProvider = context.read<AuthProvider>();
    final esUsuario1 = authProvider.user?.id == duelo.usuario1Id;
    final misPuntos = esUsuario1 ? duelo.puntosUsuario1 : duelo.puntosUsuario2;
    final puntosoponente = esUsuario1 ? duelo.puntosUsuario2 : duelo.puntosUsuario1;

    return Container(
      color: AppTheme.colorPrimary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Batalla header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'TÚ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ScaleTransition(
                      scale: Tween<double>(begin: 1, end: 1.1).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.colorSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$misPuntos',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // VS badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.opponentName.split(' ').first,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.colorAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$puntosoponente',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (dueloProvider.dueloActualIndex + 1) / dueloProvider.preguntas.length,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.colorSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pregunta ${dueloProvider.dueloActualIndex + 1}/${dueloProvider.preguntas.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRondaInfo(Duelo duelo, DueloProvider dueloProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientCyanVibrant,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(PhosphorIcons.targetBold,
                    color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Tema',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: Text(
                    duelo.tema ?? 'Conocimiento',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Icon(PhosphorIcons.timerBold,
                    color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Tiempo',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '30s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Icon(PhosphorIcons.lightbulbBold,
                    color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Dificultad',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Media',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregunta(Pregunta pregunta) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.colorSecondary,
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pregunta.pregunta,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpciones(Pregunta pregunta, DueloProvider dueloProvider) {
    return Column(
      children: List.generate(pregunta.opciones.length, (index) {
        final opcion = pregunta.opciones[index];
        final isSelected = _respuestaSeleccionada == opcion['id'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _respuestaSeleccionada = opcion['id'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppTheme.gradientAccent
                    : const LinearGradient(
                        colors: [Colors.white, Color(0xFFF5F7FA)],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.colorAccent : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.colorAccent.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : AppTheme.colorPrimaryLight.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.colorPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opcion['texto'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : AppTheme.colorTextPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        PhosphorIcons.checkCircleFill,
                        color: Colors.white,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBotonResponder(Duelo duelo, Pregunta pregunta, DueloProvider dueloProvider) {
    final enabled = _respuestaSeleccionada != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled
            ? () async {
                final isCorrecta = await dueloProvider.enviarRespuesta(
                  dueloId: duelo.id,
                  preguntaId: pregunta.id,
                  respuestaSeleccionada: _respuestaSeleccionada!,
                  tiempoRespuesta: 15,
                );

                if (mounted) {
                  setState(() {
                    _respuestaSeleccionada = null;
                  });

                  // Mostrar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isCorrecta ? '¡Correcto! +10 puntos' : 'Incorrecto'),
                      backgroundColor: isCorrecta
                          ? AppTheme.colorSuccess
                          : AppTheme.colorError,
                    ),
                  );

                  // Si es la última pregunta, ir a resultados
                  if (dueloProvider.dueloActualIndex >= dueloProvider.preguntas.length) {
                    Navigator.pop(context);
                  }
                }
              }
            : null,
        icon: const Icon(PhosphorIcons.checkLight),
        label: const Text(
          'Confirmar Respuesta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: enabled ? AppTheme.colorSecondary : Colors.grey,
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
