import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:photo_view/photo_view.dart';

Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['first_name'];
  } else {
    return "null";
  }
}

class CreateViolationDialog extends StatefulWidget {
  const CreateViolationDialog({super.key});

  @override
  State<CreateViolationDialog> createState() => _CreateViolationDialogState();
}

class _CreateViolationDialogState extends State<CreateViolationDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController reportedByController = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  String get formattedDate {
    if (incidentDate == null) return "";
    return "${incidentDate!.year.toString().padLeft(4, '0')}-${incidentDate!.month.toString().padLeft(2, '0')}-${incidentDate!.day.toString().padLeft(2, '0')}";
  }

  String? violationType;
  String? offenseLevel;
  DateTime? incidentDate;

  File? _photoEvidenceFile;
  Uint8List? _photoEvidenceBytes;
  final ImagePicker _picker = ImagePicker();

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _photoEvidenceBytes = bytes;
          _photoEvidenceFile = null;
        });
      } else {
        setState(() {
          _photoEvidenceFile = File(pickedFile.path);
          _photoEvidenceBytes = null;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _photoEvidenceFile = null;
      _photoEvidenceBytes = null;
    });
  }

  void _openFullScreenImage() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: kIsWeb
                  ? MemoryImage(_photoEvidenceBytes!)
                  : FileImage(_photoEvidenceFile!),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: 30,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_photoEvidenceFile == null && _photoEvidenceBytes == null) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_upload, size: 30, color: Colors.grey),
              SizedBox(height: 6),
              Text("Tap to upload", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final imageWidget = kIsWeb
        ? Image.memory(_photoEvidenceBytes!, fit: BoxFit.cover)
        : Image.file(_photoEvidenceFile!, fit: BoxFit.cover);

    return GestureDetector(
      onTap: _openFullScreenImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              imageWidget,
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with values from GetStorage
    final userDetails = GetStorage().read('user_details');
    studentNameController.text = userDetails?['first_name'] ?? '';
    reportedByController.text = userDetails?['first_name'] ?? '';
    roleController.text = userDetails?['role'] ?? '';
    imageController.text = userDetails?['image'] ?? '';

    // Initialize default values for violationType and offenseLevel
    violationType = "Improper Uniform";
    offenseLevel = "First Offense";
  }

  Future<void> createViolation() async {
    final box = GetStorage();

    Map<String, dynamic> violationData = {
      'student_id': studentIdController.text,
      'student_name': studentNameController.text,
      'violation_type': violationType ?? '',
      'offense_level': offenseLevel ?? '',
      'department': box.read('user_details')?['department'] ?? '',
      'reported_by': reportedByController.text,
      'status': status.text, // Use status controller's text
      'role': roleController.text,
      'date_of_incident': incidentDate?.toIso8601String() ?? '',
    };

    // Encode photo evidence as base64 and store in GetStorage
    String? base64Photo;
    if (_photoEvidenceFile != null) {
      final bytes = await _photoEvidenceFile!.readAsBytes();
      base64Photo = base64Encode(bytes);
      violationData['photo_evidence'] = base64Photo;
    } else if (_photoEvidenceBytes != null) {
      base64Photo = base64Encode(_photoEvidenceBytes!);
      violationData['photo_evidence'] = base64Photo;
    }

    // Save base64 photo evidence to GetStorage for backend access
    if (base64Photo != null) {
      box.write('photo_evidence_base64', base64Photo);
    }

    try {
      final url = '${GlobalConfiguration().getValue("server_url")}/violations';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(violationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Violation report submitted successfully."),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create New Violation Report",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Row 1: Student ID + Name
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                decoration: _fieldDecoration(
                                  "Student ID",
                                  "Enter student ID",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                decoration: _fieldDecoration(
                                  "Student Name",
                                  "Enter student name",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: Violation Type + Offense Level
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                decoration: _fieldDecoration(
                                  "Violation Type",
                                  "Select violation type",
                                ),
                                items:
                                    [
                                          "Improper Uniform",
                                          "Late Attendance",
                                          "Serious Misconduct",
                                          "Smoking on Campus",
                                        ]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    setState(() => violationType = value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                decoration: _fieldDecoration(
                                  "Offense Level",
                                  "Select offense level",
                                ),
                                items:
                                    [
                                          "First Offense",
                                          "Second Offense",
                                          "Third Offense",
                                        ]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    setState(() => offenseLevel = value),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                decoration: _fieldDecoration(
                                  "Department",
                                  "Select Department",
                                ),
                                items:
                                    ["CAS", "CBA", "CCS", "COA", "CTE", "CCJE"]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) =>
                                    setState(() => offenseLevel = value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                decoration: _fieldDecoration(
                                  "Status",
                                  "Select Status",
                                ),
                                items: ["Pending", "Reviewed", "Referred"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => offenseLevel = value),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Row 3: Date of Incident + Photo Evidence
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                readOnly: true,
                                decoration:
                                    _fieldDecoration(
                                      "Date of Incident",
                                      "Pick a date",
                                    ).copyWith(
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                    ),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: incidentDate ?? DateTime.now(),
                                    firstDate: DateTime(2020, 1, 1),
                                    lastDate: DateTime(2030, 12, 31),
                                  );
                                  if (picked != null) {
                                    setState(() => incidentDate = picked);
                                  }
                                },
                                controller: TextEditingController(
                                  text: incidentDate != null
                                      ? "${incidentDate!.year.toString().padLeft(4, '0')}-${incidentDate!.month.toString().padLeft(2, '0')}-${incidentDate!.day.toString().padLeft(2, '0')}"
                                      : "",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: InkWell(
                              onTap:
                                  _photoEvidenceFile == null &&
                                      _photoEvidenceBytes == null
                                  ? _pickImage
                                  : _openFullScreenImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[50],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _buildPhotoPreview(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 4: Reported by + Role
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: reportedByController,
                                decoration: InputDecoration(
                                  labelText: "Reported By",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: roleController,
                                decoration: InputDecoration(
                                  labelText: "Role",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Footer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Submit Report",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          createViolation();
                        }
                      },
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
