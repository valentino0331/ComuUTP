// lib/screens/study_hub_screen.dart - EstudIA
// Tu asistente inteligente de estudio

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/study_provider.dart';
import '../models/study_models.dart';
import '../widgets/course_card.dart';

// Brand Colors for EstudIA - Usando colores de la marca UTP Comunidades
class EstudIAColors {
  static const Color primary = Color(0xFFB21132);    // Rojo UTP marca
  static const Color secondary = Color(0xFF8B0D26);  // Rojo oscuro
  static const Color accent = Color(0xFFD4204A);     // Rojo brillante
  static const Color success = Color(0xFF10B981);    // Verde éxito
  static const Color warning = Color(0xFFF59E0B);    // Ámbar
  static const Color dark = Color(0xFF1E293B);       // Slate oscuro
  static const Color light = Color(0xFFF8FAFC);      // Gris claro
  static const Color cardBackground = Color(0xFFFEF2F4); // Rojo muy claro para cards
  
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get accentGradient => const LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Helper function to show notification overlay
void showEstudIANotification(BuildContext context, String message, {bool isError = false}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: isError 
                ? null 
                : const LinearGradient(
                    colors: [EstudIAColors.primary, EstudIAColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isError ? Colors.red : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isError ? Icons.error_outline : Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key});
  
  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstudIAColors.light,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: EstudIAColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          // EstudIA Logo - simple text
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.brain(PhosphorIconsStyle.fill),
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'EstudIA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 28), // Balance
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Welcome Text
                      const Text(
                        'Tu Asistente Inteligente',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '¿Qué vas a\nestudiar hoy?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Consumer<StudyProvider>(
                builder: (context, studyProvider, _) {
                  if (studyProvider.error != null) {
                    return _buildUnavailableState(context, studyProvider.error!);
                  }
                  if (studyProvider.isLoading && studyProvider.courses.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (studyProvider.courses.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCoursesList(context, studyProvider);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: EstudIAColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preparando tu espacio de estudio...',
              style: TextStyle(
                color: EstudIAColors.dark.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Illustration Container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: EstudIAColors.accentGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '¡Comienza tu viaje de aprendizaje!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: EstudIAColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primer curso y deja que la IA te ayude a estudiar de forma inteligente',
              style: TextStyle(
                fontSize: 16,
                color: EstudIAColors.dark.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Modern Button
            GestureDetector(
              onTap: () => _showModernCreateCourseDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: EstudIAColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Crear Mi Primer Curso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: EstudIAColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: EstudIAColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Servicio no disponible',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: EstudIAColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: EstudIAColors.dark.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.read<StudyProvider>().fetchCourses(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: EstudIAColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, StudyProvider studyProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Cursos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EstudIAColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${studyProvider.courses.length} cursos',
                  style: TextStyle(
                    color: EstudIAColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Course Cards
          ...studyProvider.courses.map((course) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildModernCourseCard(context, course),
          )),
        ],
      ),
    );
  }

  Widget _buildModernCourseCard(BuildContext context, StudyCourse course) {
    return GestureDetector(
      onTap: () => _navigateToCourseDetail(course),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Gradient Background
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: EstudIAColors.primaryGradient,
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: EstudIAColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.folder_special_rounded,
                            color: EstudIAColors.primary,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(course),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: EstudIAColors.dark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.professorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Prof: ${course.professorName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: EstudIAColors.dark.withOpacity(0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: EstudIAColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 14,
                                color: EstudIAColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.materialCount ?? 0} materiales',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: EstudIAColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: EstudIAColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 14,
                                color: EstudIAColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.questionCount ?? 0} preguntas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: EstudIAColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: EstudIAColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showModernCreateCourseDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Curso',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showModernCreateCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final professorController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Header with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: EstudIAColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Nuevo Curso',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: EstudIAColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos para crear tu espacio de estudio',
                      style: TextStyle(
                        fontSize: 14,
                        color: EstudIAColors.dark.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Modern Text Fields
                    _buildModernTextField(
                      controller: nameController,
                      label: 'Nombre del Curso',
                      icon: Icons.book_outlined,
                      validator: (value) => value?.isEmpty ?? true ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: codeController,
                      label: 'Código del Curso (Opcional)',
                      icon: Icons.code_outlined,
                      hint: 'Ej: MAT-2024',
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: professorController,
                      label: 'Profesor (Opcional)',
                      icon: Icons.person_outlined,
                      hint: 'Ej: Dr. García',
                    ),
                    const SizedBox(height: 32),
                    // Create Button
                    GestureDetector(
                      onTap: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final success = await context.read<StudyProvider>().createCourse({
                            'name': nameController.text.trim(),
                            'course_code': codeController.text.isNotEmpty ? codeController.text : null,
                            'professor_name': professorController.text.isNotEmpty ? professorController.text : null,
                            'semester': 1,
                            'year': DateTime.now().year,
                          });

                          if (success != null && context.mounted) {
                            Navigator.pop(context);
                            showEstudIANotification(context, '¡Curso creado exitosamente!');
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: EstudIAColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Crear Curso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cancel Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: EstudIAColors.dark.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: EstudIAColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EstudIAColors.primary.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: EstudIAColors.dark,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: EstudIAColors.primary,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: EstudIAColors.dark.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: EstudIAColors.dark.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(StudyCourse course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¿Eliminar curso?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción no se puede deshacer',
                style: TextStyle(
                  fontSize: 15,
                  color: EstudIAColors.dark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  await context.read<StudyProvider>().deleteCourse(course.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    showEstudIANotification(context, 'Curso eliminado');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: EstudIAColors.dark.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCourseDetail(StudyCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyCourseDetailScreen(course: course),
      ),
    );
  }
}

class StudyCourseDetailScreen extends StatefulWidget {
  final StudyCourse course;

  const StudyCourseDetailScreen({required this.course});

  @override
  State<StudyCourseDetailScreen> createState() => _StudyCourseDetailScreenState();
}

class _StudyCourseDetailScreenState extends State<StudyCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<StudyProvider>().fetchMaterials(widget.course.id);
      context.read<StudyProvider>().fetchQuestions(widget.course.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstudIAColors.light,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Modern App Bar
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: EstudIAColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showUploadBottomSheet,
                            child: const Icon(
                              Icons.upload_file_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.course.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      if (widget.course.professorName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Profesor: ${widget.course.professorName}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Modern Tab Bar
            Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: EstudIAColors.primary,
                  unselectedLabelColor: EstudIAColors.dark.withOpacity(0.5),
                  indicator: BoxDecoration(
                    gradient: EstudIAColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 18),
                            SizedBox(width: 6),
                            Text('Materiales'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 18),
                            SizedBox(width: 6),
                            Text('Quiz'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 18),
                            SizedBox(width: 6),
                            Text('IA'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildModernMaterialsTab(),
                    _buildModernQuizzesTab(),
                    _buildModernAITab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMaterialsTab() {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, _) {
        final materials = studyProvider.getMaterialsByCourse(widget.course.id);
        
        if (materials.isEmpty) {
          return _buildEmptyMaterialsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return _buildModernMaterialCard(material);
          },
        );
      },
    );
  }

  Widget _buildEmptyMaterialsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: EstudIAColors.accentGradient,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay materiales aún',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: EstudIAColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sube tu primer PDF para comenzar a estudiar con IA',
              style: TextStyle(
                fontSize: 14,
                color: EstudIAColors.dark.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _showUploadBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: EstudIAColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Subir PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMaterialCard(StudyMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: EstudIAColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: EstudIAColors.dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    material.formattedSize,
                    style: TextStyle(
                      fontSize: 13,
                      color: EstudIAColors.dark.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showMaterialOptions(material),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EstudIAColors.light,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: EstudIAColors.dark.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuizzesTab() {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, _) {
        final questions = studyProvider.getQuestionsByCourse(widget.course.id);
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [EstudIAColors.warning, EstudIAColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  questions.isEmpty
                      ? 'Genera tu primer cuestionario'
                      : '${questions.length} preguntas generadas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: EstudIAColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'La IA analizará tus materiales y creará preguntas personalizadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: EstudIAColors.dark.withOpacity(0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => _showGenerateQuizDialog(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: EstudIAColors.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Generar con IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (questions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _startQuiz(questions),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: EstudIAColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Comenzar Quiz',
                          style: TextStyle(
                            color: EstudIAColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernAITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Herramientas IA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EstudIAColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Potencia tu aprendizaje con inteligencia artificial',
            style: TextStyle(
              fontSize: 13,
              color: EstudIAColors.dark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          _buildAIFeatureCard(
            'Resumir Material',
            'Obtén un resumen automático de tus PDFs',
            Icons.summarize,
            EstudIAColors.primary,
            () => _showAISummaryDialog(),
          ),
          const SizedBox(height: 12),
          _buildAIFeatureCard(
            'Generar Cuestionario',
            'Crea preguntas personalizadas de tus materiales',
            Icons.quiz,
            EstudIAColors.accent,
            () => _showGenerateQuizDialog(),
          ),
          const SizedBox(height: 12),
          _buildAIFeatureCard(
            'Explicar Concepto',
            'La IA te explica cualquier tema en detalle',
            Icons.lightbulb,
            EstudIAColors.warning,
            () => _showAIExplainDialog(),
          ),
          const SizedBox(height: 12),
          _buildAIFeatureCard(
            'Chat con IA',
            'Haz preguntas en tiempo real sobre tus PDFs',
            Icons.chat_bubble,
            EstudIAColors.success,
            () => _showAIChatDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: EstudIAColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: EstudIAColors.dark.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: EstudIAColors.accentGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Subir Material',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona un archivo PDF de tu dispositivo',
                style: TextStyle(
                  fontSize: 14,
                  color: EstudIAColors.dark.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadPDF();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: EstudIAColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Seleccionar PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: EstudIAColors.dark.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Importante: obtener bytes para web
      );

      if (result == null || result.files.isEmpty) {
        return; // Usuario canceló
      }

      final platformFile = result.files.single;
      final fileName = platformFile.name;

      if (!mounted) return;

      // Show upload progress
      _showUploadProgressDialog(fileName);

      // Simulate upload progress
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _uploadProgress = i / 10;
          });
        }
      }

      // Verificar si tenemos bytes (web) o path (móvil)
      if (platformFile.bytes != null) {
        // Web: usar bytes
        final material = await context.read<StudyProvider>().uploadMaterialBytes(
          widget.course.id,
          platformFile.bytes!,
          fileName,
        );

        if (material != null && mounted) {
          Navigator.pop(context); // Close progress dialog
          showEstudIANotification(context, '¡PDF subido exitosamente!');
        }
      } else if (platformFile.path != null) {
        // Móvil/Desktop: usar path
        final material = await context.read<StudyProvider>().uploadMaterial(
          widget.course.id,
          platformFile.path!,
        );

        if (material != null && mounted) {
          Navigator.pop(context); // Close progress dialog
          showEstudIANotification(context, '¡PDF subido exitosamente!');
        }
      } else {
        throw Exception('No se pudo obtener el archivo');
      }
    } catch (e) {
      if (mounted) {
        showEstudIANotification(context, 'Error al subir el archivo: $e', isError: true);
      }
    }
  }

  void _showUploadProgressDialog(String fileName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: EstudIAColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Subiendo...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: EstudIAColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 13,
                      color: EstudIAColors.dark.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: EstudIAColors.light,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _uploadProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: EstudIAColors.primaryGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: EstudIAColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMaterialOptions(StudyMaterial material) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Header con nombre del archivo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: EstudIAColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${material.formattedSize} • ${material.fileType.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Opciones en Grid
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Ver PDF
                    _buildMaterialOptionTile(
                      icon: Icons.visibility_rounded,
                      title: 'Ver PDF',
                      subtitle: 'Abrir documento',
                      color: EstudIAColors.primary,
                      onTap: () async {
                        Navigator.pop(context);
                        await _openPDF(material.fileUrl, material.name);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Divisor IA
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[200])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.brain(PhosphorIconsStyle.fill),
                                size: 16,
                                color: EstudIAColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Funciones IA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: EstudIAColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[200])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Resumen IA
                    _buildMaterialOptionTile(
                      icon: Icons.summarize_rounded,
                      title: 'Generar Resumen',
                      subtitle: 'Resumen automático con IA',
                      color: EstudIAColors.accent,
                      onTap: () {
                        Navigator.pop(context);
                        _showAISummaryDialog(materialId: material.id);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Generar Cuestionario
                    _buildMaterialOptionTile(
                      icon: Icons.quiz_rounded,
                      title: 'Generar Cuestionario',
                      subtitle: 'Crear preguntas del material',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _showGenerateQuizDialog();
                      },
                    ),
                    const SizedBox(height: 12),
                    // Explicar Concepto
                    _buildMaterialOptionTile(
                      icon: Icons.lightbulb_rounded,
                      title: 'Explicar Concepto',
                      subtitle: 'La IA explica temas del PDF',
                      color: EstudIAColors.warning,
                      onTap: () {
                        Navigator.pop(context);
                        _showAIExplainDialog();
                      },
                    ),
                    const SizedBox(height: 12),
                    // Chat con IA
                    _buildMaterialOptionTile(
                      icon: Icons.chat_bubble_rounded,
                      title: 'Chat con IA',
                      subtitle: 'Pregunta sobre el material',
                      color: EstudIAColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        _showAIChatDialog();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Divisor Peligro
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.red[100])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Zona de peligro',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.red[100])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Eliminar
                    _buildMaterialOptionTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Eliminar Material',
                      subtitle: 'Eliminar permanentemente',
                      color: Colors.red,
                      isDanger: true,
                      onTap: () async {
                        Navigator.pop(context);
                        final confirmed = await _showDeleteConfirmation(material.name);
                        if (confirmed == true && mounted) {
                          await context.read<StudyProvider>().deleteMaterial(material.id);
                          showEstudIANotification(context, 'Material eliminado');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50] : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDanger ? Colors.red[200]! : color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.withOpacity(0.1) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.red : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDanger ? Colors.red[700] : EstudIAColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDanger ? Colors.red[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDanger ? Colors.red[300] : color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(String materialName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.red[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Eliminar material?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"$materialName" se eliminará permanentemente',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  void _showAISummaryDialog({String? materialId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: EstudIAColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.summarize,
                          color: Colors.white,
                          size: 28,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Resumen con IA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La IA analizará tu documento y generará un resumen',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Summary content would go here
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: EstudIAColors.light,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: EstudIAColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Generando resumen...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: EstudIAColors.dark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(EstudIAColors.primary),
                            backgroundColor: EstudIAColors.primary.withOpacity(0.1),
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
    );
  }

  void _showAIExplainDialog() {
    final textController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EstudIAColors.warning, EstudIAColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Explicar Concepto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escribe el concepto que quieres que la IA te explique',
                style: TextStyle(
                  fontSize: 14,
                  color: EstudIAColors.dark.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: EstudIAColors.light,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: EstudIAColors.warning.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ej: Teorema de Pitágoras, Fotosíntesis, etc.',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                    hintStyle: TextStyle(
                      color: EstudIAColors.dark.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (textController.text.isNotEmpty) {
                    Navigator.pop(context);
                    // Call AI explain
                    context.read<StudyProvider>().askQuestion(
                      widget.course.id,
                      'Explica el concepto: ${textController.text}',
                    );
                    showEstudIANotification(context, 'Consulta enviada a la IA');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [EstudIAColors.warning, EstudIAColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Preguntar a la IA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: EstudIAColors.dark.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIChatDialog() {
    final textController = TextEditingController();
    final messages = <Map<String, dynamic>>[
      {
        'text': '¡Hola! Soy EstudIA, tu asistente de estudio. Puedo ayudarte a resumir documentos, explicar conceptos o responder preguntas sobre tus materiales. ¿Qué necesitas?',
        'isAI': true,
        'time': DateTime.now(),
      }
    ];
    var isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: EstudIAColors.accentGradient,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chat con EstudIA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Tu asistente de estudio',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Chat Messages Area
                Expanded(
                  child: Container(
                    color: EstudIAColors.light,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildChatBubble(
                          msg['text'] as String,
                          isAI: msg['isAI'] as bool,
                        );
                      },
                    ),
                  ),
                ),
                // Chat Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: EstudIAColors.light,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: textController,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                hintText: isLoading ? 'EstudIA está escribiendo...' : 'Escribe tu pregunta...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: EstudIAColors.dark.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: isLoading || textController.text.trim().isEmpty
                              ? null
                              : () async {
                                  final question = textController.text.trim();
                                  textController.clear();
                                  
                                  setDialogState(() {
                                    messages.add({
                                      'text': question,
                                      'isAI': false,
                                      'time': DateTime.now(),
                                    });
                                    isLoading = true;
                                  });

                                  // Call AI API
                                  final response = await context.read<StudyProvider>().askQuestion(
                                    widget.course.id,
                                    question,
                                  );

                                  setDialogState(() {
                                    isLoading = false;
                                    if (response != null) {
                                      messages.add({
                                        'text': response.content,
                                        'isAI': true,
                                        'time': DateTime.now(),
                                      });
                                    } else {
                                      messages.add({
                                        'text': 'Lo siento, no pude procesar tu pregunta. Intenta de nuevo más tarde.',
                                        'isAI': true,
                                        'time': DateTime.now(),
                                      });
                                    }
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isLoading || textController.text.trim().isEmpty
                                  ? LinearGradient(
                                      colors: [Colors.grey[400]!, Colors.grey[300]!],
                                    )
                                  : EstudIAColors.accentGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
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
    );
  }

  // Open PDF viewer
  Future<void> _openPDF(String url, String title) async {
    try {
      if (kIsWeb) {
        // For web, open in new tab
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, webOnlyWindowName: '_blank');
        } else {
          throw 'Could not launch $url';
        }
      } else {
        // For mobile, show options
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      showEstudIANotification(context, 'Error al abrir PDF: $e');
    }
  }

  Widget _buildChatBubble(String message, {required bool isAI}) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isAI ? EstudIAColors.primaryGradient : null,
          color: isAI ? null : EstudIAColors.light,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAI ? 4 : 20),
            bottomRight: Radius.circular(isAI ? 20 : 4),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isAI ? Colors.white : EstudIAColors.dark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  void _showGenerateQuizDialog() {
    int questionCount = 5;
    String difficulty = 'medium';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 24,
              right: 24,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Header icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: EstudIAColors.accentGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Generar Cuestionario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: EstudIAColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La IA creará preguntas personalizadas basadas en tus materiales',
                  style: TextStyle(
                    fontSize: 14,
                    color: EstudIAColors.dark.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Question count selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuizOption(
                      label: '5 preguntas',
                      icon: Icons.looks_one,
                      selected: questionCount == 5,
                      onTap: () => setState(() => questionCount = 5),
                    ),
                    const SizedBox(width: 12),
                    _buildQuizOption(
                      label: '10 preguntas',
                      icon: Icons.looks_two,
                      selected: questionCount == 10,
                      onTap: () => setState(() => questionCount = 10),
                    ),
                    const SizedBox(width: 12),
                    _buildQuizOption(
                      label: '20 preguntas',
                      icon: Icons.looks_3,
                      selected: questionCount == 20,
                      onTap: () => setState(() => questionCount = 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Difficulty selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDifficultyChip(
                      label: 'Fácil',
                      selected: difficulty == 'easy',
                      onTap: () => setState(() => difficulty = 'easy'),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildDifficultyChip(
                      label: 'Medio',
                      selected: difficulty == 'medium',
                      onTap: () => setState(() => difficulty = 'medium'),
                      color: EstudIAColors.warning,
                    ),
                    const SizedBox(width: 8),
                    _buildDifficultyChip(
                      label: 'Difícil',
                      selected: difficulty == 'hard',
                      onTap: () => setState(() => difficulty = 'hard'),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Generate button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _generateQuizWithOptions(questionCount, difficulty);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: EstudIAColors.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Generar Cuestionario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: EstudIAColors.dark.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generateQuizWithOptions(int count, String difficulty) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: EstudIAColors.accentGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Generando cuestionario...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: EstudIAColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La IA está analizando tus materiales',
                style: TextStyle(
                  fontSize: 14,
                  color: EstudIAColors.dark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(EstudIAColors.accent),
              ),
            ],
          ),
        ),
      ),
    );

    // Generate quiz with options
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        context.read<StudyProvider>().generateQuiz(widget.course.id, count: count, difficulty: difficulty);
        showEstudIANotification(context, '¡Cuestionario de $count preguntas generado!');
      }
    });
  }

  Widget _buildQuizOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? EstudIAColors.accent.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? EstudIAColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? EstudIAColors.accent : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? EstudIAColors.accent : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? color : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _startQuiz(List<dynamic> questions) {
    // Navigate to quiz screen
    showEstudIANotification(context, 'Iniciando cuestionario...');
  }
}
