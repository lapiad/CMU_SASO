import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class EditableViolationFormPage extends StatefulWidget {
  final ViolationRecord record;

  const EditableViolationFormPage({super.key, required this.record});

  @override
  State<EditableViolationFormPage> createState() =>
      _EditableViolationFormPageState();
}

class _EditableViolationFormPageState extends State<EditableViolationFormPage> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _reportedByController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _remarksController = TextEditingController();
  final _roleController = TextEditingController();

  final List<String> violationStatus = [
    'Pending',
    'In Progress',
    'Reviewed',
    'Referred',
  ];

  final List<String> offenseLevels = [
    'First Offense',
    'Second Offense',
    'Third Offense',
  ];

  String? _selectedStatus;
  String? _selectedOffenseLevel;

  List<String> imageUrls = [];
  bool _isSaving = false;
  bool _isLoadingImages = false;

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
    _dateTimeController.text = widget.record.dateTime;
    _roleController.text = widget.record.role;
    _remarksController.text = widget.record.remarks ?? '';

    _selectedStatus = violationStatus.contains(widget.record.status)
        ? widget.record.status
        : violationStatus.first;
    _selectedOffenseLevel = offenseLevels.contains(widget.record.offenseLevel)
        ? widget.record.offenseLevel
        : offenseLevels.first;
  }

  /// ✅ Fetch all images and filter locally by violation_id
  Future<void> _fetchImagesFromBackend() async {
    setState(() => _isLoadingImages = true);

    final baseUrl = GlobalConfiguration().getValue("server_url");
    final imageBaseUrl = GlobalConfiguration().getValue("image_base_url");

    try {
      final url = Uri.parse('$baseUrl/violations/image');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data["images"] is List) {
          final List images = data["images"];
          final filteredImages = images.where((img) {
            return img["violation_id"].toString() ==
                widget.record.violationId.toString();
          }).toList();

          // ✅ Safely build image URLs
          setState(() {
            imageUrls = filteredImages
                .map<String>((img) {
                  String? path = img["image_path"];
                  if (path == null || path.isEmpty) return "";
                  if (!path.startsWith("http")) {
                    if (!path.startsWith("/")) path = "/$path";
                    path = imageBaseUrl != null ? "$imageBaseUrl$path" : path;
                  }
                  return path;
                })
                .where((path) => path.isNotEmpty)
                .toList();
          });
        }
      } else {
        _showSnackBar("Failed to fetch images: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error fetching images: $e", color: Colors.red);
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  void _showZoomableImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
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

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
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

  Widget _buildStyledDropdown({
    required String label,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = (selectedValue != null && options.contains(selectedValue))
        ? selectedValue
        : null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: DropdownButtonFormField<String>(
          value: safeValue,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEditableRemarks() {
    return TextField(
      controller: _remarksController,
      maxLines: 4,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Enter remarks here...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageUrls.isEmpty) {
      return const Center(
        child: Text(
          "No photo evidence available.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final url = imageUrls[index];
        return GestureDetector(
          onTap: () => _showZoomableImage(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final baseUrl = GlobalConfiguration().getValue("server_url");
    final url = Uri.parse(
      '$baseUrl/violations/update/${widget.record.violationId}',
    );

    final updatedData = {
      "id": widget.record.violationId,
      "offense_level": _selectedOffenseLevel ?? '',
      "status": _selectedStatus ?? '',
      "remarks": _remarksController.text,
      "reported_by": _reportedByController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Changes saved successfully!", color: Colors.green);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar(
          "Failed to save changes: ${response.body}",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar("Error saving changes: $e", color: Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _cancelChanges() => Navigator.pop(context);

  void _showSnackBar(String message, {Color color = Colors.black87}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Violation Details",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0033A0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
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
                    _buildEditableField(
                      "Student ID",
                      _studentIdController,
                      readOnly: true,
                    ),
                    _buildEditableField(
                      "Department",
                      _departmentController,
                      readOnly: true,
                    ),
                    _buildEditableField(
                      "Reported By",
                      _reportedByController,
                      readOnly: true,
                    ),
                    _buildStyledDropdown(
                      label: "Status",
                      selectedValue: _selectedStatus,
                      options: violationStatus,
                      onChanged: (value) =>
                          setState(() => _selectedStatus = value),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildEditableField(
                      "Student Name",
                      _studentNameController,
                      readOnly: true,
                    ),
                    _buildEditableField(
                      "Date and Time",
                      _dateTimeController,
                      readOnly: true,
                    ),
                    _buildEditableField(
                      "Role",
                      _roleController,
                      readOnly: true,
                    ),
                    _buildStyledDropdown(
                      label: "Offense Level",
                      selectedValue: _selectedOffenseLevel,
                      options: offenseLevels,
                      onChanged: (value) =>
                          setState(() => _selectedOffenseLevel = value),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Remarks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _buildEditableRemarks(),
                const SizedBox(height: 20),
                const Text(
                  "Photo Evidence (Optional)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                _buildImageGrid(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _cancelChanges,
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _isSaving ? null : _saveChanges,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
