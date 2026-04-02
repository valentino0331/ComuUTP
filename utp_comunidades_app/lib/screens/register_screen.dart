import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String nombre = '';
  bool loading = false;
  String? error;

  Future<void> register() async {
    setState(() { loading = true; error = null; });
    final res = await ApiService.post('/auth/register', {
      'email': email,
      'password': password,
      'nombre': nombre,
    });
    if (res.statusCode == 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso. Inicia sesión.')));
      Navigator.pop(context);
    } else {
      setState(() { error = 'No se pudo registrar'; });
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text('Únete a la comunidad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) => nombre = v,
                      validator: (v) => v != null && v.isNotEmpty ? null : 'Campo requerido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo UTP',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) => email = v,
                      validator: (v) => v != null && v.endsWith('@utp.edu.pe') ? null : 'Correo UTP inválido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                      onChanged: (v) => password = v,
                      validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (error != null) ...[
                Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : () {
                    if (_formKey.currentState!.validate()) register();
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading ? const CircularProgressIndicator() : const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
