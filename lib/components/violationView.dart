import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
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
    _fetchImagesFromBackend();
  }

  void _initializeControllers() {
    _studentIdController.text = widget.record.studentId;
    _studentNameController.text = widget.record.studentName;
    _departmentController.text = widget.record.department;
    _reportedByController.text = widget.record.reportedBy;
    _roleController.text = widget.record.role ?? "";
    _statusController.text = widget.record.status ?? "";
    _offenseLevelController.text = widget.record.offenseLevel ?? "";
    _dateTimeController.text = widget.record.dateTime;
    _remarksController.text = widget.record.remarks ?? "";
  }

  Future<void> _fetchImagesFromBackend() async {
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
            final tempImages = <Uint8List>[];
            for (var item in data) {
              final bytes = _decodeBase64(item.toString());
              if (bytes != null) tempImages.add(bytes);
            }
            setState(() {
              imageBytesList = tempImages;
              imageUrls = [];
              _errorMessage = null;
            });
          } else {
            setState(() {
              imageUrls = List<String>.from(data);
              imageBytesList = [];
              _errorMessage = null;
            });
          }
        } else {
          setState(() {
            _errorMessage = "No photo evidence available.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to fetch images: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching images: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Uint8List? _decodeBase64(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      final cleaned = base64String.split(',').last.trim();
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
            fillColor: Colors.grey.shade200,
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
        color: Colors.grey.shade200,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final totalImages = imageBytesList.length + imageUrls.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalImages,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
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
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        }
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
