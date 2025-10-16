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
  final String department;

  Student({
    required this.id,
    required this.firstname,
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

  // Fetch violation types from backend
  Future<List<String>> fetchViolationTypes(String filter) async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse(
        '$baseUrl/violations/get_violation_types',
      ).replace(queryParameters: {'filter': filter});
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return List<String>.from(data);
        if (data is Map && data.containsKey('violation_types')) {
          return List<String>.from(data['violation_types']);
        }
      } else {
        print("Failed to fetch violation types: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching violation types: $e");
    }
    return [];
  }

  // Fetch student by ID
  Future<Student?> fetchStudentById(String studentId) async {
    if (studentId.isEmpty) return null;
    try {
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/students/student-info/$studentId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Student(
          id: data['id'] ?? '',
          firstname: data['first_name'] ?? '',
          department: data['department'] ?? '',
        );
      }
    } catch (e) {
      print("Error fetching student: $e");
    }
    return null;
  }

  // Fetch violation count by Student ID
  Future<int> fetchStudentViolationCountById(String studentId) async {
    if (studentId.isEmpty) return 0;
    try {
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/violations$studentId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? '';
      }
    } catch (e) {
      print("Error fetching violation count: $e");
    }
    return 0;
  }

  // Pick image
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

  // Submit violation
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Student ID
                  TextFormField(
                    controller: studentIdController,
                    decoration: _fieldDecoration(
                      "Student ID",
                      "Enter Student ID",
                    ),
                    onChanged: (value) async {
                      final student = await fetchStudentById(value.trim());
                      if (student != null) {
                        setState(() {
                          studentNameController.text = student.firstname;
                          departmentController.text = student.department;
                        });
                        int violationCount =
                            await fetchStudentViolationCountById(student.id);
                        if (violationCount == 0)
                          offenseLevel = "First Offense";
                        else if (violationCount == 1)
                          offenseLevel = "Second Offense";
                        else
                          offenseLevel = "Third Offense";
                        setState(() {});
                      } else {
                        setState(() {
                          studentNameController.text = '';
                          departmentController.text = '';
                          offenseLevel = "First Offense";
                        });
                      }
                    },
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter Student ID'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Student Name
                  TextFormField(
                    controller: studentNameController,
                    readOnly: true,
                    decoration: _fieldDecoration(
                      "Student Name",
                      "Student Name",
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Student Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Department
                  TextFormField(
                    controller: departmentController,
                    readOnly: true,
                    decoration: _fieldDecoration("Department", "Department"),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Department cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Violation Type Dropdown
                  DropdownSearch<String>(
                    asyncItems: (filter) => fetchViolationTypes(filter),
                    selectedItem: violationTypeController.text.isEmpty
                        ? null
                        : violationTypeController.text,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search violation type...",
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: _fieldDecoration(
                        "Violation Type",
                        "Search or select violation type",
                      ),
                    ),
                    onChanged: (value) {
                      setState(
                        () => violationTypeController.text = value ?? '',
                      );
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select Violation Type'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Offense Level
                  TextFormField(
                    readOnly: true,
                    initialValue: offenseLevel,
                    decoration: _fieldDecoration(
                      "Offense Level",
                      "Auto-calculated based on previous violations",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Status
                  TextFormField(
                    readOnly: true,
                    initialValue: statusValue,
                    decoration: _fieldDecoration("Status", ""),
                  ),
                  const SizedBox(height: 15),

                  // Date & Time
                  TextFormField(
                    readOnly: true,
                    controller: incidentDateController,
                    decoration: _fieldDecoration(
                      "Date & Time of Incident",
                      "Pick date and time",
                    ).copyWith(prefixIcon: const Icon(Icons.calendar_today)),
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
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select date and time'
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // Reported By
                  TextFormField(
                    controller: reportedByController,
                    readOnly: true,
                    decoration: _fieldDecoration("Reported By", ""),
                  ),
                  const SizedBox(height: 15),

                  // Role
                  TextFormField(
                    controller: roleController,
                    readOnly: true,
                    decoration: _fieldDecoration("Role", ""),
                  ),
                  const SizedBox(height: 15),

                  // Photo Evidence
                  InkWell(
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
                  const SizedBox(height: 20),

                  // Buttons
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
                          if (_formKey.currentState!.validate())
                            createViolation();
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
