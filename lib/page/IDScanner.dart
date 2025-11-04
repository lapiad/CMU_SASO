import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Schoolguard.dart';
import 'package:flutter_application_1/page/Stud_info.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart'; // <-- import your ViolationScreen

void main() => runApp(const StudentIDScannerApp());

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
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraController = CameraController(backCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _flashOn = !_flashOn;
    await _cameraController!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _scanStudentID({int attempt = 1}) async {
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
      final extractedText = await _extractTextFromFile(_capturedImage!);

      final studNoReg = RegExp(r'\b(20\d{6,8})\b'); // adjust regex if needed
      final studentNo = studNoReg.firstMatch(extractedText)?.group(0) ?? '';

      if (studentNo.isEmpty && attempt < 2) {
        debugPrint("⚠️ No student number detected. Retrying...");
        return _scanStudentID(attempt: attempt + 1);
      }

      if (studentNo.isEmpty) {
        _showMessage("No valid student number detected");
        setState(() {
          _isProcessing = false;
          _capturedImage = null;
        });
        return;
      }

      // Fetch students and find match
      final students = await fetchStudents('');
      final matchedStudent = students.firstWhere(
        (s) => s.id == studentNo,
        orElse: () =>
            Student(id: '', firstname: '', lastname: '', department: ''),
      );

      if (matchedStudent.id.isEmpty) {
        _showMessage("Student not found in the database.");
      } else {
        // Navigate to ViolationScreen with studentId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ViolationScreen(studentId: matchedStudent.id),
          ),
        );
      }

      setState(() {
        _isProcessing = false;
        _capturedImage = null;
      });
    } catch (e) {
      debugPrint("Scan error: $e");
      _showMessage("Failed to scan ID. Ensure good lighting.");
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

  void _showMessage(String message) {
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

  Future<List<Student>> fetchStudents(String filter) async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/students');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return data
              .map<Student>(
                (e) => Student(
                  id: e['student_id'].toString(),
                  firstname: e['first_name'] ?? '',
                  lastname: e['last_name'] ?? '',
                  department: e['department'] ?? '',
                ),
              )
              .toList();
        }
      } else {
        print("Failed to fetch students: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
    return [];
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const SchoolGuardHome();
                  },
                ),
              ),
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
                onTap: _scanStudentID,
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

class Student {
  final String id;
  final String firstname;
  final String lastname;
  final String department;

  Student({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.department,
  });
}
