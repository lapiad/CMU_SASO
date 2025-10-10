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
  final TextEditingController incidentDateController = TextEditingController();

  String? violationType;
  String? offenseLevel;
  String? department;
  String? statusValue;
  DateTime? incidentDate;

  File? _photoEvidenceFile;
  Uint8List? _photoEvidenceBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userDetails = GetStorage().read('user_details');
    reportedByController.text = userDetails?['first_name'] ?? '';
    roleController.text = userDetails?['role'] ?? '';
    imageController.text = userDetails?['image'] ?? '';
  }

  @override
  void dispose() {
    studentIdController.dispose();
    studentNameController.dispose();
    reportedByController.dispose();
    status.dispose();
    roleController.dispose();
    imageController.dispose();
    incidentDateController.dispose();
    super.dispose();
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
                  : FileImage(_photoEvidenceFile!) as ImageProvider,
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

  Future<void> createViolation() async {
    final box = GetStorage();

    if (incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the date of incident.")),
      );
      return;
    }

    Map<String, dynamic> violationData = {
      'student_id': studentIdController.text.trim(),
      'student_name': studentNameController.text.trim(),
      'violation_type': violationType ?? '',
      'offense_level': offenseLevel ?? '',
      'department': department ?? '',
      'reported_by': reportedByController.text.trim(),
      'status': statusValue ?? '',
      'role': roleController.text.trim(),
      'date_of_incident': incidentDate!.toIso8601String(),
    };

    String? base64Photo;
    if (_photoEvidenceFile != null) {
      final bytes = await _photoEvidenceFile!.readAsBytes();
      base64Photo = base64Encode(bytes);
      violationData['photo_evidence'] = base64Photo;
    } else if (_photoEvidenceBytes != null) {
      base64Photo = base64Encode(_photoEvidenceBytes!);
      violationData['photo_evidence'] = base64Photo;
    }

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
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: studentIdController,
                                decoration: _fieldDecoration(
                                  "Student ID",
                                  "Enter student ID",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter Student ID';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: studentNameController,
                                decoration: _fieldDecoration(
                                  "Student Name",
                                  "Enter student name",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter Student Name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                value: violationType,
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
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please select Violation Type'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                value: offenseLevel,
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
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please select Offense Level'
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                value: department,
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
                                    setState(() => department = value),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please select Department'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                value: statusValue,
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
                                    setState(() => statusValue = value),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please select Status'
                                    : null,
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
                                    setState(() {
                                      incidentDate = picked;
                                      incidentDateController.text =
                                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                    });
                                  }
                                },
                                controller: incidentDateController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select the date of incident';
                                  }
                                  return null;
                                },
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
                                ),
                                child: _buildPhotoPreview(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: reportedByController,
                                readOnly: true,
                                decoration: _fieldDecoration("Reported By", ""),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: TextFormField(
                                controller: roleController,
                                readOnly: true,
                                decoration: _fieldDecoration("Role", ""),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
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
