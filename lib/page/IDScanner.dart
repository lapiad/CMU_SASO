import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/ViolationScreen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const StudentIDScannerApp());
}

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
  _IDScannerScreenState createState() => _IDScannerScreenState();
}

class _IDScannerScreenState extends State<IDScannerScreen> {
  CameraController? _cameraController;
  bool _flashOn = false;
  bool _isProcessing = false;
  File? _capturedImage; // frozen preview

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();
    if (await Permission.camera.isGranted) {
      cameras = await availableCameras();
      CameraDescription cameraTobeUsed;
      if (kIsWeb) {
        cameraTobeUsed = cameras!.first;
      } else {cameraTobeUsed = cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );}
      
      _cameraController = CameraController(
        cameraTobeUsed,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _flashOn = !_flashOn);

    if (!_isProcessing) {
      await _cameraController!.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  Future<void> _setFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    try {
      await _cameraController!.setFocusPoint(offset);
      await _cameraController!.setExposurePoint(offset);
    } catch (e) {
      debugPrint("Focus not supported: $e");
    }
  }

  Future<void> _scanID() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // 1. Capture image
      XFile picture = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(picture.path); // freeze
        _isProcessing = true;
      });

      // 2. Crop ID area
      File croppedFile = await _cropToIDRect(File(picture.path));

      // 3. Run OCR
      final inputImage = InputImage.fromFile(croppedFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String scannedText = recognizedText.text;

      // Improved regex (handles variations better)
      RegExp nameReg = RegExp(
        r'([A-Z][a-zA-Z]+,\s+[A-Z][a-zA-Z]+(?:\s+[A-Z]\.?)?)',
        multiLine: true,
      );
      RegExp courseReg = RegExp(r'\b[A-Z]{2,5}\b');
      RegExp studNoReg = RegExp(r'\b\d{9,12}\b'); // allow up to 12 digits

      String name = nameReg.firstMatch(scannedText)?.group(0) ?? '';
      String course = courseReg.firstMatch(scannedText)?.group(0) ?? '';
      String studentNo = studNoReg.firstMatch(scannedText)?.group(0) ?? '';
      name = name.replaceAll(',', '').trim();

      await textRecognizer.close();

      // Turn off flash after scan
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() => _flashOn = false);

      if (name.isEmpty || studentNo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ID not recognized or too blurry. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
          _capturedImage = null; // return live preview
        });
        return;
      }

      // ✅ Navigate if success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViolationScreen(
            name: name,
            course: course,
            studentNo: studentNo,
            violationsCount: 0,
          ),
        ),
      ).then((_) {
        // return to live preview
        setState(() {
          _capturedImage = null;
          _isProcessing = false;
        });
      });
    } catch (e) {
      debugPrint('Error scanning ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan ID. Please try again.')),
      );
      setState(() {
        _isProcessing = false;
        _capturedImage = null; // back to live preview
      });
    }
  }

  Future<File> _cropToIDRect(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    double padding = 40;
    double rectWidth = (image.width - (padding * 2))
        .clamp(0, image.width)
        .toDouble();
    double rectHeight = rectWidth / 1.6; // 1.6 ratio closer to ID cards
    double left = (image.width - rectWidth) / 2;
    double top = (image.height - rectHeight) / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(left, top, rectWidth, rectHeight),
      Rect.fromLTWH(0, 0, rectWidth, rectHeight),
      paint,
    );

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(
      rectWidth.toInt(),
      rectHeight.toInt(),
    );
    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final croppedFile = File(
      "${file.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png",
    );
    await croppedFile.writeAsBytes(byteData!.buffer.asUint8List());
    return croppedFile;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width * 0.22;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera preview OR frozen captured image
          _capturedImage != null
              ? Image.file(
                  _capturedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : _cameraController == null ||
                    !_cameraController!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) => _setFocus(details, constraints),
                      child: SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize!.height,
                            height: _cameraController!.value.previewSize!.width,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      ),
                    );
                  },
                ),

          // Scanner overlay (corners)
          Positioned.fill(child: CustomPaint(painter: ScannerOverlay())),

          // Flash toggle
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _toggleFlash,
            ),
          ),

          // Capture button
          if (!_isProcessing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _scanID,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),

          // Loader overlay
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
                      'Processing ID...',
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

    double padding = 15;
    double rectWidth = size.width - (padding * 5);
    double rectHeight = rectWidth / 0.625;
    double left = (size.width - rectWidth) / 2;
    double top = (size.height - rectHeight) / 2;
    double right = left + rectWidth;
    double bottom = top + rectHeight;

    double cornerSize = 40;

    // Draw corners
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
