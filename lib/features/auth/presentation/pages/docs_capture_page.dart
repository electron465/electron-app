import 'package:flutter/material.dart';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart'; // <-- AGREGADO: Para usar context.push
import '../../../../core/widgets/app_button.dart';

class DocsCapturePage extends StatefulWidget {
  final bool isMilitar;
  const DocsCapturePage({super.key, required this.isMilitar});

  @override
  State<DocsCapturePage> createState() => _DocsCapturePageState();
}

class _DocsCapturePageState extends State<DocsCapturePage> {
  bool _isProcessing = false;
  String _extractedText = '';

  // Función que se ejecuta cuando el documento es capturado y guardado
  Future<void> _onDocumentSaved(DocumentCaptureData data) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Obtenemos la ruta de la imagen recortada
      final imagePath = data.frontImagePath;
      if (imagePath == null) return;

      // 2. Inicializamos el OCR de ML Kit
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(imagePath);

      // 3. Procesamos la imagen
      final recognizedText = await textRecognizer.processImage(inputImage);

      // 4. Guardamos el texto extraído
      setState(() {
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });

      // Cerramos el reconocedor para liberar memoria
      await textRecognizer.close();

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _extractedText = 'Error al procesar la imagen: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear Cédula', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Extrayendo datos...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : _extractedText.isNotEmpty
              ? _buildResultView()
              : _buildScannerView(),
    );
  }

  // Vista de la cámara con el marco de detección
  Widget _buildScannerView() {
    return DocumentCameraFrame(
      frameWidth: 320,
      frameHeight: 200,
      requireBothSides: false,
      enableAutoCapture: true,
      showCloseButton: true,
      onDocumentSaved: _onDocumentSaved,
      titleStyle: DocumentCameraTitleStyle(
        title: Text(
          widget.isMilitar ? 'Escanear Cédula (Militar)' : 'Escanear Cédula',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      instructionStyle: DocumentCameraInstructionStyle(
        showInstructionText: true,
        frontSideInstruction: 'Coloca la cédula dentro del marco',
      ),
    );
  }

  // Vista de resultado (temporal, para ver el texto extraído)
  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Texto extraído:',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _extractedText,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÓN 1: Volver a escanear
          AppButton(
            text: 'Volver a escanear',
            onPressed: () {
              setState(() {
                _extractedText = '';
              });
            },
          ),

          const SizedBox(height: 16),

          // BOTÓN 2: Ir a la cámara de rostro
          AppButton(
            text: 'Procesar Documento',
            onPressed: () {
              context.push('/face-capture');
            },
          ),
        ],
      ),
    );
  }
}