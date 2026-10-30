import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';

class FaceCapturePage extends StatelessWidget {
  const FaceCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Verificación de Identidad', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Verificación facial de identidad',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tómate una foto para que podamos comprobar que eres tú.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // Ilustración (puedes cambiarla por una imagen)
            const Icon(Icons.face, size: 120, color: Color(0xFF2196F3)),

            const SizedBox(height: 40),

            // Recomendaciones
            const Text(
              '• Elige un sitio iluminado.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              '• No uses accesorios como gorras, lentes o mascarillas.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Tu rostro y fondo serán grabados.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const Spacer(),

            // Botón de Capturar
            AppButton(
              text: 'Presionar para Capturar',
              onPressed: () {
                // TODO: Aquí tu compañero integrará la cámara de rostro
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo de captura facial en construcción')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}