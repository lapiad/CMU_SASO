import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class Student {
  final String id;
  final String firstname;
  final String lastname;
  final String department;

  Student({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.department,
  });
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
  final TextEditingController roleController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController incidentDateController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController violationTypeController = TextEditingController();

  String? offenseLevel = "First Offense";
  String statusValue = "Pending";
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

    incidentDate = DateTime.now();
    incidentDateController.text = DateFormat(
      'yyyy-MM-dd – hh:mm a',
    ).format(incidentDate!);
  }

  Future<List<Student>> fetchStudents(String filter) async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/students');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return data
              .map<Student>(
                (e) => Student(
                  id: e['student_id'].toString(),
                  firstname: e['first_name'] ?? '',
                  lastname: e['last_name'] ?? '',
                  department: e['department'] ?? '',
                ),
              )
              .toList();
        }
      } else {
        print("Failed to fetch students: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
    return [];
  }

  Future<List<String>> fetchViolationTypes(String filter) async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/violations/get_violation_types');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return List<String>.from(data);
        } else if (data is Map && data.containsKey('violation_types')) {
          return List<String>.from(
            data['violation_types'].map((e) => e['type_name']),
          );
        }
      } else {
        print("Failed to fetch violation types: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching violation types: $e");
    }
    return [];
  }

  Future<int> fetchStudentViolationCountById(String studentId) async {
    if (studentId.isEmpty) return 0;

    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/violations/$studentId/count');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
    } catch (e) {
      print("Error fetching violation count: $e");
    }

    return 0;
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
    if (_photoEvidenceFile == null && _photoEvidenceBytes == null) return;

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildPhotoPreview() {
    if (_photoEvidenceFile == null && _photoEvidenceBytes == null) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Stack(
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
    if (incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the date of incident.")),
      );
      return;
    }

    Map<String, dynamic> violationData = {
      'student_id': studentIdController.text.trim(),
      'student_name': studentNameController.text.trim(),
      'violation_type': violationTypeController.text.trim(),
      'offense_level': offenseLevel ?? '',
      'department': departmentController.text.trim(),
      'reported_by': reportedByController.text.trim(),
      'status': statusValue,
      'role': roleController.text.trim(),
      'date_of_incident': incidentDate!.toIso8601String(),
    };

    if (_photoEvidenceFile != null) {
      final bytes = await _photoEvidenceFile!.readAsBytes();
      violationData['photo_evidence'] = base64Encode(bytes);
    } else if (_photoEvidenceBytes != null) {
      violationData['photo_evidence'] = base64Encode(_photoEvidenceBytes!);
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
          const SnackBar(content: Text("Violation report submitted.")),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _fieldDecoration(label, "").copyWith(
        prefixIcon: const Icon(Icons.text_fields, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildReadOnlyField(String? value, String label) {
    return TextFormField(
      readOnly: true,
      initialValue: value,
      decoration: _fieldDecoration(label, ""),
    );
  }

  Widget _buildReadOnlyFieldController(
    TextEditingController controller,
    String label,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: _fieldDecoration(
        label,
        "",
      ).copyWith(prefixIcon: Icon(icon, color: Colors.blueAccent)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create New Violation Report",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 28,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Student Dropdown
                  DropdownSearch<Student>(
                    asyncItems: (filter) => fetchStudents(filter),
                    itemAsString: (Student s) =>
                        "${s.id} - ${s.firstname} ${s.lastname}",
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search student...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration:
                          _fieldDecoration(
                            "Search Student",
                            "Select student by ID or name",
                          ).copyWith(
                            prefixIcon: const Icon(
                              Icons.person_search,
                              color: Colors.blue,
                            ),
                          ),
                    ),
                    selectedItem:
                        (studentIdController.text.isNotEmpty &&
                            studentNameController.text.isNotEmpty)
                        ? Student(
                            id: studentIdController.text,
                            firstname: studentNameController.text
                                .split(' ')
                                .first,
                            lastname: studentNameController.text
                                .split(' ')
                                .last,
                            department: departmentController.text,
                          )
                        : null,
                    onChanged: (Student? selectedStudent) async {
                      if (selectedStudent == null) return;

                      setState(() {
                        studentIdController.text = selectedStudent.id;
                        studentNameController.text =
                            '${selectedStudent.firstname} ${selectedStudent.lastname}';
                        departmentController.text = selectedStudent.department;
                      });

                      int count = await fetchStudentViolationCountById(
                        selectedStudent.id,
                      );
                      setState(() {
                        offenseLevel = (count == 0)
                            ? "First Offense"
                            : (count == 1)
                            ? "Second Offense"
                            : "Third Offense";
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildTextField(studentIdController, "Student ID"),
                  const SizedBox(height: 15),
                  _buildTextField(studentNameController, "Student Name"),
                  const SizedBox(height: 15),
                  _buildTextField(departmentController, "Department"),
                  const SizedBox(height: 15),

                  // Violation Type Dropdown
                  DropdownSearch<String>(
                    asyncItems: (filter) => fetchViolationTypes(filter),
                    selectedItem: violationTypeController.text.isEmpty
                        ? null
                        : violationTypeController.text,
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search violation type...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration:
                          _fieldDecoration(
                            "Violation Type",
                            "Select violation type",
                          ).copyWith(
                            prefixIcon: const Icon(
                              Icons.report,
                              color: Colors.redAccent,
                            ),
                          ),
                    ),
                    onChanged: (value) {
                      setState(
                        () => violationTypeController.text = value ?? '',
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildReadOnlyField(offenseLevel, "Offense Level"),
                  const SizedBox(height: 15),
                  _buildReadOnlyField(statusValue, "Status"),
                  const SizedBox(height: 15),
                  _buildReadOnlyFieldController(
                    incidentDateController,
                    "Date & Time of Incident",
                    Icons.calendar_today,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: incidentDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(3000),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            incidentDate ?? DateTime.now(),
                          ),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            incidentDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            incidentDateController.text = DateFormat(
                              'yyyy-MM-dd – hh:mm a',
                            ).format(incidentDate!);
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(reportedByController, "Reported By"),
                  const SizedBox(height: 15),
                  _buildTextField(roleController, "Role"),
                  const SizedBox(height: 15),

                  // Photo Preview
                  InkWell(
                    onTap:
                        _photoEvidenceFile == null &&
                            _photoEvidenceBytes == null
                        ? _pickImage
                        : _openFullScreenImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blueGrey[50],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _buildPhotoPreview(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Submit Report",
                          style: TextStyle(
                            fontSize: 18,
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
      ),
    );
  }
}
