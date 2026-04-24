import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/auth_provider.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cicloController = TextEditingController();
  String? _selectedCarrera;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _mostrarPassword = false;
  bool _mostrarConfirmPassword = false;

  // Colores del diseño
  static const Color colorPrimario = Color(0xFFB21132);
  static const Color colorFondoOverlay = Color(0x57B21132);
  static const Color colorInput = Color(0xD2EDF0F2);
  static const Color colorBoton = Color(0xFF090A0B);
  static const Color colorTextoBlanco = Colors.white;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creando cuenta...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Registrar en Firebase
    final result = await authProvider.registerWithFirebase(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      carrera: _selectedCarrera,
      ciclo: int.tryParse(_cicloController.text.trim()),
    );
    
    if (!mounted) return;
    
    // Ocultar snackbar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    if (result['success']) {
      // REGISTRAR EN NEON (BASE DE DATOS)
      final neonResult = await authProvider.completeRegistration(
        uid: result['uid'],
        email: _emailController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        carrera: _selectedCarrera,
        ciclo: int.tryParse(_cicloController.text.trim()),
      );
      
      if (!neonResult) {
        // Si falla Neon, igual continuamos pero advertimos
        print('⚠️ Advertencia: No se pudo guardar en Neon, pero Firebase sí');
      }
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada. Verifica tu correo.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Ir a pantalla de verificación de email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            uid: result['uid'],
            email: _emailController.text.trim(),
            nombre: _nombreController.text.trim(),
            apellido: _apellidoController.text.trim(),
            carrera: _selectedCarrera,
            ciclo: int.tryParse(_cicloController.text.trim()),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al registrar'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Carreras UTP Piura
  final List<String> _carreras = [
    'Ingeniería Ambiental',
    'Ingeniería Civil',
    'Ingeniería Empresarial',
    'Ingeniería Industrial',
    'Ingeniería de Sistemas e Informática',
    'Ingeniería de Software',
    'Administración de Empresas',
    'Administración de Negocios Internacionales',
    'Administración y Marketing',
    'Contabilidad',
    'Economía',
    'Psicología',
    'Arquitectura',
    'Diseño Profesional de Interiores',
    'Enfermería',
    'Farmacia y Bioquímica',
    'Laboratorio Clínico y Anatomía Patológica',
    'Nutrición y Dietética',
    'Obstetricia',
    'Terapia Física',
    'Derecho',
    'Educación Inicial',
    'Educación Primaria',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cicloController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: colorFondoOverlay,
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 20),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Crear cuenta',
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
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Únete a UTP Comunidades',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: colorTextoBlanco.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Nombre
                            _buildLabel('Nombre'),
                            _buildTextField(
                              controller: _nombreController,
                              hint: 'Tu nombre',
                              icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                              validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido',
                            ),
                            const SizedBox(height: 16),

                            // Apellido
                            _buildLabel('Apellido'),
                            _buildTextField(
                              controller: _apellidoController,
                              hint: 'Tu apellido',
                              icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                              validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido',
                            ),
                            const SizedBox(height: 16),

                            // Carrera
                            _buildLabel('Carrera *'),
                            _buildCarreraSelector(authProvider.loading),
                            const SizedBox(height: 16),

                            // Ciclo
                            _buildLabel('Ciclo'),
                            _buildTextField(
                              controller: _cicloController,
                              hint: 'Ej: 5',
                              icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                              keyboardType: TextInputType.number,
                              validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido',
                            ),
                            const SizedBox(height: 16),

                            // Correo UTP
                            _buildLabel('Correo UTP'),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'ejemplo@utp.edu.pe',
                              icon: PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if (!v.endsWith('@utp.edu.pe')) return 'Debe ser @utp.edu.pe';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Contraseña
                            _buildLabel('Contraseña'),
                            _buildPasswordField(
                              controller: _passwordController,
                              hint: 'Mínimo 6 caracteres',
                              mostrar: _mostrarPassword,
                              onToggle: () => setState(() => _mostrarPassword = !_mostrarPassword),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if (v.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirmar Contraseña
                            _buildLabel('Confirmar contraseña'),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              hint: 'Repite tu contraseña',
                              mostrar: _mostrarConfirmPassword,
                              onToggle: () => setState(() => _mostrarConfirmPassword = !_mostrarConfirmPassword),
                              validator: (v) {
                                if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Botón Registrarse
                            Center(
                              child: SizedBox(
                                width: 263,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorBoton,
                                    foregroundColor: colorTextoBlanco,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(37),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Registrarse',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Link a login
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
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
                                      'Ya tengo cuenta',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        color: colorTextoBlanco.withOpacity(0.9),
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
                  ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorTextoBlanco,
        ),
      ),
    );
  }

  Widget _buildCarreraSelector(bool loading) {
    return GestureDetector(
      onTap: loading ? null : () => _showCarreraBottomSheet(context),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorInput,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.graduationCap(PhosphorIconsStyle.regular), color: Colors.black45, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCarrera ?? 'Selecciona tu carrera',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: _selectedCarrera != null ? Colors.black87 : Colors.black45,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.regular), color: Colors.black45, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCarreraBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorPrimario,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecciona tu carrera',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Carreras list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _carreras.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final carrera = _carreras[index];
                  final isSelected = carrera == _selectedCarrera;
                  return ListTile(
                    title: Text(
                      carrera,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? colorPrimario : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: colorPrimario, size: 20)
                        : null,
                    onTap: () {
                      setState(() => _selectedCarrera = carrera);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        controller: controller,
        enabled: !context.watch<AuthProvider>().loading,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorInput,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.red)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontFamily: 'Montserrat'),
          prefixIcon: Icon(icon, color: Colors.black45),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool mostrar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        controller: controller,
        enabled: !context.watch<AuthProvider>().loading,
        obscureText: !mostrar,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorInput,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.red)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontFamily: 'Montserrat'),
          prefixIcon: Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.regular), color: Colors.black45),
          suffixIcon: IconButton(
            icon: Icon(
              mostrar ? PhosphorIcons.eye(PhosphorIconsStyle.regular) : PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular),
              color: Colors.black45,
            ),
            onPressed: onToggle,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
