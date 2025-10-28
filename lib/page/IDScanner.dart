import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Schoolguard.dart';
import 'package:flutter_application_1/page/Stud_info.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription>? cameras;

class StudentIDScannerApp extends StatelessWidget {
  const StudentIDScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IDScannerScreen(),
    );
  }
}

class IDScannerScreen extends StatefulWidget {
  const IDScannerScreen({super.key});

  @override
  State<IDScannerScreen> createState() => _IDScannerScreenState();
}

class _IDScannerScreenState extends State<IDScannerScreen> {
  CameraController? _cameraController;
  bool _flashOn = false;
  bool _isProcessing = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        CameraDescription camera;
        if (kIsWeb) {
          camera = (await availableCameras()).firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          );
        } else {
          camera = (await availableCameras()).firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
          );
        }

        _cameraController = CameraController(camera, ResolutionPreset.high);
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint("Camera init error: $e");
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _flashOn = !_flashOn);
    await _cameraController!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _scanID({int attempt = 1}) async {
    if (!mounted ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() => _isProcessing = true);
      final picture = await _cameraController!.takePicture();
      _capturedImage = File(picture.path);
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500));
      final scannedText = await _extractTextFromFile(_capturedImage!);

      final nameReg = RegExp(
        r'([A-Z][a-zA-Z]+,\s+(?:[A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*)(?:\s+[A-Z]\.?)?)',
      );
      final courseReg = RegExp(
        r'\b(?:BS|BA|B\.S\.|B\.A\.|BACHELOR(?:\s+OF)?(?:\s+[A-Z]+)*)(?:\s+IN\s+[A-Z][A-Z\s]+)?\b',
        caseSensitive: false,
      );
      final studNoReg = RegExp(r'\b(20\d{6,8})\b');

      final name = nameReg.firstMatch(scannedText)?.group(0) ?? '';
      final course = courseReg.firstMatch(scannedText)?.group(0) ?? '';
      final studentNo = studNoReg.firstMatch(scannedText)?.group(0) ?? '';

      if ((studentNo.isEmpty || name.isEmpty || course.isEmpty) &&
          attempt < 2) {
        debugPrint("⚠️ OCR incomplete. Retrying...");
        return _scanID(attempt: attempt + 1);
      }

      if (studentNo.isEmpty || name.isEmpty || course.isEmpty) {
        _showOverlayMessage("No valid ID details detected");
        setState(() {
          _isProcessing = false;
          _capturedImage = null;
        });
        return;
      }

      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() => _flashOn = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViolationScreen(studentNo: studentNo),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _capturedImage = null;
            _isProcessing = false;
          });
        }
      });
    } catch (e) {
      debugPrint("❌ Scan error: $e");
      _showOverlayMessage("Failed to scan ID. Try again in good lighting.");
      setState(() {
        _isProcessing = false;
        _capturedImage = null;
      });
    }
  }

  Future<String> _extractTextFromFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  void _showOverlayMessage(String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () => overlay.remove());
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.width * 0.22;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          _capturedImage != null
              ? Image.file(
                  _capturedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : (_cameraController == null ||
                    !_cameraController!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final size = _cameraController!.value.previewSize!;
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: size.height,
                          height: size.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    );
                  },
                ),
          Positioned.fill(child: CustomPaint(painter: ScannerOverlay())),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SchoolGuardHome()),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          if (!_isProcessing)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 30,
              child: GestureDetector(
                onTap: _scanID,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Processing ID...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    const padding = 10.0;
    final rectWidth = size.width - (padding * 5);
    final rectHeight = rectWidth / 0.625;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2;
    final right = left + rectWidth;
    final bottom = top + rectHeight;
    const cornerSize = 40.0;

    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerSize), paint);
    canvas.drawLine(Offset(right, top), Offset(right - cornerSize, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerSize), paint);
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerSize, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - cornerSize, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
