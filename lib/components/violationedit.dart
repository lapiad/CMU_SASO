import 'dart:typed_data';
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

  String? _selectedRole;
  final List<String> _roles = [];

  String? violation_status;
  List<String> _status = [];

  String? _selectedOffenseLevel;
  List<String> _offenseLevels = [];

  List<Uint8List> imageBytesList = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Keep existing status and offense level from record
    violation_status = widget.record.status;
    _selectedOffenseLevel = widget.record.offenseLevel;

    _fetchImagesFromBackend();
    _fetchStatusAndOffense();
  }

  void _initializeControllers() {
    _studentIdController.text = widget.record.studentId;
    _studentNameController.text = widget.record.studentName;
    _departmentController.text = widget.record.department;
    _reportedByController.text = widget.record.reportedBy;
    _dateTimeController.text = widget.record.dateTime;
    _roleController.text = widget.record.role;
    _remarksController.text = widget.record.remarks ?? '';
  }

  Future<void> _fetchStatusAndOffense() async {
    final baseUrl = GlobalConfiguration().getValue("server_url");
    try {
      // Fetch status list
      final statusResp = await http.get(Uri.parse('$baseUrl/status'));
      if (statusResp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(statusResp.body);
        setState(() {
          _status = data.map((e) => e.toString()).toList();
          // Preserve record's current status
          violation_status = widget.record.status.isNotEmpty
              ? widget.record.status
              : (violation_status ?? (_status.isNotEmpty ? _status[0] : null));
        });
      }

      // Fetch offense level list
      final offenseResp = await http.get(Uri.parse('$baseUrl/offense-level'));
      if (offenseResp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(offenseResp.body);
        setState(() {
          _offenseLevels = data.map((e) => e.toString()).toList();
          // Preserve record's current offense level
          _selectedOffenseLevel = widget.record.offenseLevel.isNotEmpty
              ? widget.record.offenseLevel
              : (_selectedOffenseLevel ??
                    (_offenseLevels.isNotEmpty ? _offenseLevels[0] : null));
        });
      }
    } catch (e) {
      _showSnackBar(
        "Error fetching status/offense options: $e",
        color: Colors.red,
      );
    }
  }

  Future<void> _fetchImagesFromBackend() async {
    final baseUrl = GlobalConfiguration().getValue("server_url");
    final url = Uri.parse(
      '$baseUrl/violations/image',
    ).replace(queryParameters: {'violation_id': widget.record.violationId});

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            imageBytesList = data
                .map((e) => _safeDecodeBase64(e.toString()))
                .whereType<Uint8List>()
                .toList();
          });
        } else if (data is Map<String, dynamic>) {
          final imagesData = data['photo_evidence'] ?? [];
          if (imagesData is List) {
            setState(() {
              imageBytesList = imagesData
                  .map((e) => _safeDecodeBase64(e.toString()))
                  .whereType<Uint8List>()
                  .toList();
            });
          }
        }
      } else {
        _showSnackBar("Failed to fetch images: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error fetching images: $e", color: Colors.red);
    }
  }

  Uint8List? _safeDecodeBase64(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      final cleaned = base64String
          .split(',')
          .last
          .replaceAll(RegExp(r'\s+'), '');
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
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: MemoryImage(imageBytes),
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

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextField(
          controller: controller,
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
    Color fillColor = const Color(0xFFE0E0E0),
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
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
    if (imageBytesList.isEmpty) {
      return const Center(child: Text("No photo evidence available."));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageBytesList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
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
      "reportedBy": _reportedByController.text,
      "role": _roleController.text,
      "status": violation_status,
      "offenseLevel": _selectedOffenseLevel,
      "dateTime": _dateTimeController.text,
      "remarks": _remarksController.text,
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
                    _buildEditableField("Student ID", _studentIdController),
                    _buildEditableField("Department", _departmentController),
                    _buildEditableField("Reported By", _reportedByController),
                    _buildStyledDropdown(
                      label: "Status",
                      selectedValue: violation_status,
                      options: _status,
                      onChanged: (val) =>
                          setState(() => violation_status = val),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildEditableField("Student Name", _studentNameController),
                    _buildEditableField("Date and Time", _dateTimeController),
                    _buildEditableField("Role", _roleController),
                    _buildStyledDropdown(
                      label: "Offense Level",
                      selectedValue: _selectedOffenseLevel,
                      options: _offenseLevels,
                      onChanged: (val) =>
                          setState(() => _selectedOffenseLevel = val),
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
                  "Photo Evidence",
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
