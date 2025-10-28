import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class EditableViolationFormPage extends StatefulWidget {
  final String violationId;

  const EditableViolationFormPage({super.key, required this.violationId});

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

  List<File>? _photoEvidenceFile = [];
  List<Uint8List>? _photoEvidenceBytesList = [];
  final ImagePicker _picker = ImagePicker();

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

  late ViolationRecord violationRecord;

  String? _selectedStatus;
  String? _selectedOffenseLevel;

  List<String> imageUrls = [];
  int fromDBImagesCount = 0;
  bool _isSaving = false;
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _fetchViolationFromBackend();

    _fetchImagesFromBackend();
  }

  void _initializeControllers() {
    _studentIdController.text = violationRecord.studentId;
    _studentNameController.text = violationRecord.studentName;
    _departmentController.text = violationRecord.department;
    _reportedByController.text = violationRecord.reportedBy;
    _dateTimeController.text = violationRecord.dateTime;
    _roleController.text = violationRecord.role;
    _remarksController.text = violationRecord.remarks ?? '';

    _selectedStatus = violationStatus.contains(violationRecord.status)
        ? violationRecord.status
        : violationStatus.first;
    _selectedOffenseLevel = offenseLevels.contains(violationRecord.offenseLevel)
        ? violationRecord.offenseLevel
        : offenseLevels.first;
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
      } else {
        _showSnackBar(
          "Failed to fetch violation details: ${response.statusCode}",
        );
      }
    } catch (e) {
      _showSnackBar("Error fetching violation details: $e", color: Colors.red);
    } finally {}
  }

  Future<void> _fetchImagesFromBackend() async {
    setState(() {
      _isLoadingImages = true;
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
            fromDBImagesCount = filteredImages.length;
            _isLoadingImages = false;
          });
        } else {
          setState(() {
            imageUrls = [];
            _isLoadingImages = false;
          });
        }
      } else {
        setState(() {
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      if (kIsWeb) {
        List<String> photoBytes = [];
        for (var photo in pickedFile) {
          final bytes = await photo.readAsBytes();
          photoBytes.add(base64Encode(bytes));
        }
        setState(() {
          imageUrls.addAll(photoBytes);
          _photoEvidenceFile = [];
        });
      } else {
        List<File> photoBytes = [];
        for (var photo in pickedFile) {
          final bytes = File(photo.path);
          photoBytes.add(bytes);
        }
        setState(() {
          _photoEvidenceFile = photoBytes;
          _photoEvidenceBytesList = [];
        });
      }
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
          style: const TextStyle(color: Colors.black87, fontSize: 14),
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
          initialValue: safeValue,
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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        hintText: "Enter remarks here...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
        childAspectRatio: 10 / 4,
      ),
      itemBuilder: (context, index) {
        final url = imageUrls[index];
        return GestureDetector(
          onTap: () => _showZoomableImage(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: index + 1 > fromDBImagesCount
                ? Stack(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 4),
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.black54,
                            size: 16,
                          ),
                          Text("Click 'Save' to save this image."),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 20),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.memory(
                          base64Decode(url),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ],
                  )
                : Image.memory(
                    base64Decode(url),
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
      '$baseUrl/violations/update/${violationRecord.violationId}',
    );

    final updatedData = {
      "id": violationRecord.violationId,
      "offense_level": _selectedOffenseLevel ?? '',
      "status": _selectedStatus ?? '',
      "remarks": _remarksController.text,
      "reported_by": _reportedByController.text,
      "photo_evidence": imageUrls,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Changes saved successfully!", color: Colors.green);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditableViolationFormPage(violationId: widget.violationId),
            ),
          );
        }
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                      onChanged: (v) => setState(() => _selectedStatus = v),
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
                      onChanged: (v) =>
                          setState(() => _selectedOffenseLevel = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Remarks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _buildEditableRemarks(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      "Photo Evidence (Optional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add Photos",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildImageGrid(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
