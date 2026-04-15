import 'package:flutter/material.dart';

class SubmitAttendanceScreen extends StatelessWidget {
  const SubmitAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Evidencias de Asistencia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Sube aquí tus evidencias de asistencia a clase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar lógica de subida
              },
              icon: const Icon(Icons.upload),
              label: const Text('Seleccionar archivo'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
