import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class ViolationFormPage extends StatefulWidget {
  final ViolationRecord record;

  const ViolationFormPage({super.key, required this.record});

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

  List<Uint8List> imageBytesList = [];
  List<String> imageUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchImagesFromBackend(); // fetch images when page loads
  }

  void _initializeControllers() {
    _studentIdController.text = widget.record.studentId;
    _studentNameController.text = widget.record.studentName;
    _departmentController.text = widget.record.department;
    _reportedByController.text = widget.record.reportedBy;
    _roleController.text = widget.record.role;
    _statusController.text = widget.record.status ?? "";
    _offenseLevelController.text = widget.record.offenseLevel ?? "";
    _dateTimeController.text = _formatDateTime(widget.record.dateTime);
    _remarksController.text = widget.record.remarks ?? "";
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dt = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (e) {
      debugPrint('Date format error: $e');
      return dateTimeStr;
    }
  }

  Future<void> _fetchImagesFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse(
        '$baseUrl/violations/image',
      ).replace(queryParameters: {'violation_id': widget.record.violationId});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          if (data.first.toString().startsWith("data:image")) {
            // Base64 images
            imageBytesList = data
                .map<Uint8List?>((item) => _decodeBase64(item.toString()))
                .whereType<Uint8List>()
                .toList();
            imageUrls = [];
          } else {
            // Network images
            imageUrls = List<String>.from(data);
            imageBytesList = [];
          }
        } else {
          _errorMessage = "No photo evidence available.";
        }
      } else {
        _errorMessage = "Failed to fetch images: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Error fetching images: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Uint8List? _decodeBase64(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last.trim()
          : base64String.trim();
      final padding = cleaned.length % 4;
      final normalized = padding > 0
          ? cleaned.padRight(cleaned.length + (4 - padding), '=')
          : cleaned;
      return base64Decode(normalized);
    } catch (e) {
      debugPrint("Invalid Base64 image: $e");
      return null;
    }
  }

  void _showZoomableImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: MemoryImage(imageBytes),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
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

  void _showZoomableNetworkImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
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
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyRemarks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        _remarksController.text.isEmpty
            ? "No remarks available."
            : _remarksController.text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null ||
        (imageBytesList.isEmpty && imageUrls.isEmpty)) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _errorMessage ?? "No photo evidence available.",
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      );
    }

    final totalImages = imageBytesList.length + imageUrls.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalImages,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index < imageBytesList.length) {
              final imageBytes = imageBytesList[index];
              return GestureDetector(
                onTap: () => _showZoomableImage(imageBytes),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain, // <-- Changed here
                  ),
                ),
              );
            } else {
              final imageUrl = imageUrls[index - imageBytesList.length];
              return GestureDetector(
                onTap: () => _showZoomableNetworkImage(imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // <-- Changed here
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Violation Details",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0033A0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Violation ID: ${widget.record.violationId}",
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
                const SizedBox(height: 10),
                const Text(
                  "Remarks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _buildReadOnlyRemarks(),
                const SizedBox(height: 20),
                const Text(
                  "Photo Evidence",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                _buildImageGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
