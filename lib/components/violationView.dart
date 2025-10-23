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

  /// ✅ Fetch images (optional, based on router without parameters)
  Future<void> _fetchImagesFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final imageBaseUrl = GlobalConfiguration().getValue("image_base_url");

      final url = Uri.parse('$baseUrl/violations/image');
      debugPrint("📡 Fetching all images from: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = data['images'] as List?;

        if (images != null && images.isNotEmpty) {
          // ✅ Filter by violation_id locally (optional)
          final filteredImages = images.where((img) {
            final imgViolationId = img['violation_id']?.toString() ?? "";
            return imgViolationId == widget.record.violationId;
          }).toList();

          setState(() {
            imageUrls = filteredImages
                .where(
                  (img) =>
                      img['image_path'] != null &&
                      img['image_path'].toString().isNotEmpty,
                )
                .map((img) {
                  String path = img['image_path'];
                  if (!path.startsWith('http')) {
                    if (!path.startsWith('/')) path = '/$path';
                    path = '$imageBaseUrl$path';
                  }
                  return path;
                })
                .toList();

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

  /// ✅ Only build grid if images exist
  Widget _buildImageGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageUrls.isEmpty) {
      // Don’t show anything if no image
      return const SizedBox.shrink();
    }

    final labels = ["1st Offense", "2nd Offense", "3rd Offense"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Photo Evidence",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final imageUrl = index < imageUrls.length ? imageUrls[index] : null;
            final label = labels[index];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: imageUrl != null
                          ? () => _showZoomableNetworkImage(imageUrl)
                          : null,
                      child: Container(
                        height: 400,
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
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              : const Center(
                                  child: Text(
                                    "No Image",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
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
                _buildImageGrid(), // ✅ Only appears if images exist
              ],
            ),
          ),
        ),
      ),
    );
  }
}
