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
  ); // Replace with your FastAPI URL
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['first_name']);
    return data['first_name'];
  } else {
    // error message
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

  String? violationType;
  String? offenseLevel;
  String? role;
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
      onTap: _openFullScreenImage, // 📌 open fullscreen on tap
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
                      icon: const Icon(Icons.close),
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
                                controller: studentIdController,
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
                                controller: studentNameController,
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => incidentDate = picked);
                                  }
                                },
                                controller: TextEditingController(
                                  text: incidentDate != null
                                      ? "${incidentDate!.month}/${incidentDate!.day}/${incidentDate!.year}"
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
                                  : _openFullScreenImage, // 📌 upload or fullscreen
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
                                decoration: _fieldDecoration(
                                  "Reported by",
                                  "Name of the person reporting",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: DropdownButtonFormField<String>(
                                value: role,
                                decoration: _fieldDecoration(
                                  "Role",
                                  "Select role",
                                ),
                                items: ["Teacher", "Staff", "Student"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => role = value),
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
                      child: const Text("Cancel"),
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
                      child: const Text("Submit Report"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          debugPrint("Submitting form...");
                          Navigator.pop(context);
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
