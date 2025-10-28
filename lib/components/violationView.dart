import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class ViolationFormPage extends StatefulWidget {
  final String violationId;

  const ViolationFormPage({super.key, required this.violationId});

  @override
  State<ViolationFormPage> createState() => _ViolationFormPageState();
}

class _ViolationFormPageState extends State<ViolationFormPage> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _reportedByController = TextEditingController();
  final _roleController = TextEditingController();
  final _statusController = TextEditingController();
  final _offenseLevelController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _remarksController = TextEditingController();

  List<String> imageUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  late ViolationRecord violationRecord;

  @override
  void initState() {
    super.initState();
    _fetchViolationFromBackend();
    _fetchImagesFromBackend();
  }

  void _initializeControllers() {
    _studentIdController.text = violationRecord.studentId ?? "";
    _studentNameController.text = violationRecord.studentName ?? "";
    _reportedByController.text = violationRecord.reportedBy ?? "";
    _roleController.text = violationRecord.role ?? "";
    _statusController.text = violationRecord.status ?? "";
    _offenseLevelController.text = violationRecord.offenseLevel ?? "";
    _remarksController.text = violationRecord.remarks ?? "";
    _departmentController.text = violationRecord.department ?? "";

    final rawDateFromBackend =
        (violationRecord.dateTime != null &&
            violationRecord.dateTime!.isNotEmpty)
        ? violationRecord.dateTime!
        : DateTime.now().toUtc().toIso8601String();

    _dateTimeController.text = _formatDateTime(rawDateFromBackend);
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dt = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _fetchViolationFromBackend() async {
    final baseUrl = GlobalConfiguration().getValue("server_url");
    final violationId = widget.violationId;
    try {
      final url = Uri.parse('$baseUrl/violations/violation/$violationId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          violationRecord = ViolationRecord.fromJson(data);
          _initializeControllers();
        });
        if ((_departmentController.text.isEmpty) &&
            (violationRecord.studentId != null &&
                violationRecord.studentId!.isNotEmpty)) {
          _fetchDepartmentForStudent(violationRecord.studentId!);
        }
      } else {
        _showSnackBar(
          "Failed to fetch violation details: ${response.statusCode}",
        );
      }
    } catch (e) {
      _showSnackBar("Error fetching violation details: $e", color: Colors.red);
    }
  }

  /// ✅ Fully connected department fetch method
  Future<void> _fetchDepartmentForStudent(String studentId) async {
    if (studentId.isEmpty) return;
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/students/$studentId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check multiple possible field formats
        dynamic deptData =
            data['department'] ??
            data['department_name'] ??
            data['departmentName'] ??
            data['dept'] ??
            data['student_department'];

        // If department is an object (nested)
        if (deptData is Map) {
          deptData =
              deptData['name'] ?? deptData['dept_name'] ?? deptData['title'];
        }

        if (deptData != null && deptData.toString().isNotEmpty) {
          setState(() {
            _departmentController.text = deptData.toString();
          });
        }
      } else {
        debugPrint(
          'Failed to fetch student department: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching student department: $e');
    }
  }

  void _showSnackBar(String message, {Color color = Colors.black87}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _fetchImagesFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final violationId = widget.violationId;
      final url = Uri.parse('$baseUrl/violations/images/$violationId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> images = data['images'];

        if (images.isNotEmpty) {
          final List<String> filteredImages = [];
          for (var img in images) {
            if (img['image_path'] != null &&
                img['image_path'].toString().isNotEmpty) {
              filteredImages.add(img['image_path'].toString());
            }
          }
          setState(() {
            imageUrls = filteredImages;
            _isLoading = false;
          });
        } else {
          setState(() {
            imageUrls = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to load images (Status ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = "Error loading images: $e";
        _isLoading = false;
      });
    }
  }

  void _showZoomableNetworkImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Image.memory(base64Decode(imageUrl)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyRemarks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _remarksController.text.isEmpty
            ? "No remarks available."
            : _remarksController.text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  String addBase64Padding(String base64String) {
    if (base64String.length % 4 > 0) {
      base64String += '=' * (4 - base64String.length % 4);
      debugPrint('Padded Base64 String: $base64String');
      return base64String;
    }
    return base64String;
  }

  Widget _buildImageGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Photo Evidence",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(imageUrls.length, (index) {
            final imageUrl = index < imageUrls.length ? imageUrls[index] : null;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl != null
                        ? GestureDetector(
                            onTap: () => _showZoomableNetworkImage(imageUrl),
                            child: Image.memory(
                              base64Decode(addBase64Padding(imageUrl)),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Text(
                              "No Image",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Violation Details",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF446EAD),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Violation ID: ${widget.violationId}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildReadOnlyField("Student ID", _studentIdController),
                    _buildReadOnlyField("Department", _departmentController),
                    _buildReadOnlyField("Reported By", _reportedByController),
                    _buildReadOnlyField("Status", _statusController),
                  ],
                ),
                Row(
                  children: [
                    _buildReadOnlyField("Student Name", _studentNameController),
                    _buildReadOnlyField("Date and Time", _dateTimeController),
                    _buildReadOnlyField("Role", _roleController),
                    _buildReadOnlyField(
                      "Offense Level",
                      _offenseLevelController,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Remarks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _buildReadOnlyRemarks(),
                _buildImageGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
