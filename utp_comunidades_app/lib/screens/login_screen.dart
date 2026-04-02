import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 24),
                  const Text('UTP Comunidades', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Conecta con tu comunidad universitaria', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                  if (authProvider.error != null) ...[
                    Text(authProvider.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.loading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          authProvider.login(email, password).then((success) {
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: authProvider.loading ? const CircularProgressIndicator() : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('¿No tienes cuenta? '),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Regístrate aquí', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
