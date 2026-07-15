import 'package:flutter/material.dart';

class EvidenceButton extends StatelessWidget {
  const EvidenceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/submit_attendance'),
      icon: const Icon(Icons.upload_file),
      label: const Text('Subir evidencias de asistencia'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
