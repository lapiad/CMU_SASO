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

class ViolationScreen extends StatefulWidget {
  final String studentId;

  const ViolationScreen({super.key, required this.studentId});

  @override
  State<ViolationScreen> createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController reportedByController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController incidentDateController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController violationTypeController = TextEditingController();
  final TextEditingController offenseLevelController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  DateTime? incidentDate;
  List<File>? _photoEvidenceFile = [];
  List<Uint8List>? _photoEvidenceBytesList = [];
  final ImagePicker _picker = ImagePicker();

  bool canSubmit = true;
  Color offenseColor = Colors.green;
  int violationCount = 0;

  @override
  void initState() {
    super.initState();
    statusController.text = "Pending";
    final userDetails = GetStorage().read('user_details');
    reportedByController.text = userDetails?['first_name'] ?? '';
    roleController.text = userDetails?['role'] ?? '';
    incidentDate = DateTime.now();
    incidentDateController.text = DateFormat(
      'yyyy-MM-dd – hh:mm a',
    ).format(incidentDate!);
    fetchStudents();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: _fieldDecoration(label).copyWith(
        prefixIcon: icon != null ? Icon(icon, color: Colors.blueAccent) : null,
      ),
    );
  }

  Future<void> fetchStudents() async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/students/student-info/${widget.studentId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data["student_Info"] != null) {
          Student student = Student(
            id: data["student_Info"]["student_id"],
            firstname: data["student_Info"]["first_name"],
            lastname: data["student_Info"]["last_name"],
            department: data["student_Info"]["department"],
          );
          setState(() {
            studentIdController.text = student.id;
            studentNameController.text = "${student.firstname} ${student.lastname}";
            departmentController.text = student.department;
            fetchStudentViolationCountById().then((_) {
              _updateOffenseLevel(violationCount);
            });
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }
  }
  

  Future<List<String>> fetchViolationTypes(String filter) async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/violations/get_violation_types');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
         return List<String>.from(
            data['violation_types'].map((e) => e['type_name']),
          );
      }
    } catch (e) {
      debugPrint("Error fetching violation types: $e");
    }
    return [];
  }

  Future<void> fetchStudentViolationCountById() async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/violations/student/${widget.studentId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          violationCount = data['violations'].length;
        });
        
      }
    } catch (e) {
      debugPrint("Error fetching violation count: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      if (kIsWeb) {
        List<Uint8List> photoBytes = [];
        for (var photo in pickedFiles) {
          photoBytes.add(await photo.readAsBytes());
        }
        setState(() {
          _photoEvidenceBytesList = photoBytes;
          _photoEvidenceFile = [];
        });
      } else {
        setState(() {
          _photoEvidenceFile = pickedFiles.map((e) => File(e.path)).toList();
          _photoEvidenceBytesList = [];
        });
      }
    }
  }

  Widget _buildPhotoPreview() {
    final photos = kIsWeb ? _photoEvidenceBytesList : _photoEvidenceFile;
    if (photos == null || photos.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload, size: 30, color: Colors.grey),
              SizedBox(height: 6),
              Text(
                "Tap to upload photos",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (_, index) {
        final photo = kIsWeb
            ? _photoEvidenceBytesList![index]
            : _photoEvidenceFile![index];
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: EdgeInsets.zero,
                    backgroundColor: Colors.black,
                    child: PhotoView(
                      imageProvider: kIsWeb
                          ? MemoryImage(photo as Uint8List)
                          : FileImage(photo as File) as ImageProvider,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.memory(photo as Uint8List, fit: BoxFit.cover)
                    : Image.file(photo as File, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (kIsWeb) {
                      _photoEvidenceBytesList!.removeAt(index);
                    } else {
                      _photoEvidenceFile!.removeAt(index);
                    }
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateOffenseLevel(int count) {
    String level = '';
    Color color = Colors.green;
    bool canSubmitLocal = true;

    if (count == 0) {
      level = "First Offense";
      color = Colors.green;
    } else if (count == 1) {
      level = "Second Offense";
      color = Colors.orange;
    } else if (count == 2) {
      level = "Third Offense";
      color = Colors.redAccent;
    } else {
      level = "Limit Reached (No More Violations)";
      color = Colors.red.shade700;
      canSubmitLocal = false;
    }

    setState(() {
      offenseLevelController.text = level;
      offenseColor = color;
      canSubmit = canSubmitLocal;
    });
  }

  Future<void> createViolation() async {
    // TODO: implement your violation submission logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Violation Report"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!canSubmit)
                  Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "⚠️ Maximum offense limit reached. Cannot submit new violation.",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Student Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: studentIdController,
                          label: "Student ID",
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: studentNameController,
                          label: "Student Name",
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: departmentController,
                          label: "Department",
                        ),
                      ],
                    ),
                  ),
                ),

                // Violation Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        DropdownSearch<String>(
                          asyncItems: (filter) => fetchViolationTypes(filter),
                          selectedItem: violationTypeController.text.isEmpty
                              ? null
                              : violationTypeController.text,
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: _fieldDecoration(
                              "Violation Type",
                            ),
                          ),
                          onChanged: (value) {
                            violationTypeController.text = value ?? '';
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyField(
                                controller: offenseLevelController,
                                label: "Offense Level",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              label: Text(
                                offenseLevelController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: offenseColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: statusController,
                          label: "Status",
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: incidentDateController,
                          label: "Incident Date & Time",
                          icon: Icons.calendar_today,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: incidentDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(3000),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  incidentDate ?? DateTime.now(),
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  incidentDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  incidentDateController.text = DateFormat(
                                    'yyyy-MM-dd – hh:mm a',
                                  ).format(incidentDate!);
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Reporter Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildReadOnlyField(
                          controller: reportedByController,
                          label: "Reported By",
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: roleController,
                          label: "Role",
                        ),
                      ],
                    ),
                  ),
                ),

                // Photo Upload
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildPhotoPreview(),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: canSubmit
                      ? () {
                          if (_formKey.currentState!.validate())
                            createViolation();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    canSubmit ? "Submit Report" : "Cannot Submit",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
