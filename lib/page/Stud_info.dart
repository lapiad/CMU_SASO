import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Schoolguard.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

const Color kPrimaryColor = Color(0xFF1A237E);
const Color kAccentColor = Color(0xFF42A5F5);

class ViolationScreen extends StatefulWidget {
  final String studentNo;
  final String name;
  final String department;

  const ViolationScreen({
    super.key,
    required this.studentNo,
    this.name = "",
    this.department = "",
  });

  @override
  State<ViolationScreen> createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  // Controllers
  late TextEditingController studentNameController;
  late TextEditingController studentIdController;
  late TextEditingController departmentController;
  late TextEditingController violationTypeController;
  late TextEditingController offenseLevelController;
  late TextEditingController reportedByController;
  late TextEditingController roleController;

  DateTime? incidentDate;
  TimeOfDay? incidentTime;
  String? statusValue;

  // State
  String? _photoEvidencePath;
  Uint8List? _photoEvidenceBytes;
  bool _isSubmitting = false;
  bool _isLoadingViolations = true;

  List<String> violationTypes = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    studentNameController = TextEditingController(text: widget.name);
    studentIdController = TextEditingController(text: widget.studentNo);
    departmentController = TextEditingController(text: widget.department);
    violationTypeController = TextEditingController();
    offenseLevelController = TextEditingController();
    reportedByController = TextEditingController();
    roleController = TextEditingController();

    // Default date/time
    incidentDate = DateTime.now();
    incidentTime = TimeOfDay.now();

    _loadViolationTypes();
  }

  @override
  void dispose() {
    studentNameController.dispose();
    studentIdController.dispose();
    departmentController.dispose();
    violationTypeController.dispose();
    offenseLevelController.dispose();
    reportedByController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> _loadViolationTypes() async {
    try {
      final baseUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$baseUrl/violations/get_violation_types');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final types = (data is List)
            ? List<String>.from(data)
            : (data['violation_types'] as List)
                  .map((e) => e['type_name'].toString())
                  .toList();
        setState(() {
          violationTypes = types;
          _isLoadingViolations = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading violation types: $e");
      setState(() => _isLoadingViolations = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _photoEvidencePath = pickedFile.path;
      });
      _photoEvidenceBytes = await pickedFile.readAsBytes();
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            const Text(
              'Evidence Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kPrimaryColor),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: kPrimaryColor),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoEvidencePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove Photo",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoEvidencePath = null;
                    _photoEvidenceBytes = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitViolation() async {
    if (!_formKey.currentState!.validate() ||
        incidentDate == null ||
        violationTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic> violationData = {
      'student_id': studentIdController.text.trim(),
      'student_name': studentNameController.text.trim(),
      'violation_type': violationTypeController.text.trim(),
      'offense_level': offenseLevelController.text.trim(),
      'department': departmentController.text.trim(),
      'reported_by': reportedByController.text.trim(),
      'status': statusValue ?? '',
      'role': roleController.text.trim(),
      'date_of_incident': incidentDate!.toIso8601String(),
    };

    if (_photoEvidenceBytes != null) {
      violationData['photo_evidence'] = base64Encode(_photoEvidenceBytes!);
    }

    try {
      final url = '${GlobalConfiguration().getValue("server_url")}/violations';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(violationData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Violation report submitted.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SchoolGuardHome()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting violation: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _readOnlyField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
        ),
      );

  Widget _dateTimePickerField(
    String label,
    DateTime? date,
    TimeOfDay? time,
    VoidCallback onTap,
  ) {
    final text = date != null && time != null
        ? '${DateFormat('yyyy-MM-dd').format(date)} ${time.format(context)}'
        : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: kPrimaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller: TextEditingController(text: text),
            validator: (v) => text.isEmpty ? 'Required' : null,
          ),
        ),
      ),
    );
  }

  Widget _evidenceBox() => GestureDetector(
    onTap: _showImagePicker,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _photoEvidencePath != null
          ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_photoEvidencePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Photo Evidence Attached (Tap to change)",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ],
            )
          : Column(
              children: [
                const Icon(Icons.camera_alt, color: kPrimaryColor, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Upload Photo Evidence (Optional)",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Record Violation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSection(
                          "Student Information",
                          Icons.person,
                          Column(
                            children: [
                              _readOnlyField(
                                studentIdController,
                                "Student No.",
                              ),
                              _readOnlyField(
                                studentNameController,
                                "Student Name",
                              ),
                              _readOnlyField(
                                departmentController,
                                "Department",
                              ),
                            ],
                          ),
                        ),
                        _buildSection(
                          "Violation Details",
                          Icons.gavel,
                          _isLoadingViolations
                              ? const CircularProgressIndicator(
                                  color: kPrimaryColor,
                                )
                              : Column(
                                  children: [
                                    Autocomplete<String>(
                                      optionsBuilder: (textEditingValue) {
                                        final input = textEditingValue.text
                                            .toLowerCase();
                                        return violationTypes.where(
                                          (v) =>
                                              v.toLowerCase().contains(input),
                                        );
                                      },
                                      onSelected: (val) =>
                                          violationTypeController.text = val,
                                      fieldViewBuilder:
                                          (
                                            context,
                                            controller,
                                            focusNode,
                                            onFieldSubmitted,
                                          ) {
                                            controller.text =
                                                violationTypeController.text;
                                            return TextFormField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                labelText: "Violation Type",
                                                suffixIcon: const Icon(
                                                  Icons.search,
                                                  color: kPrimaryColor,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              validator: (v) =>
                                                  controller.text.isEmpty
                                                  ? "Required"
                                                  : null,
                                            );
                                          },
                                    ),
                                    _dateTimePickerField(
                                      "Date & Time of Incident",
                                      incidentDate,
                                      incidentTime,
                                      () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              incidentDate ?? DateTime.now(),
                                          firstDate: DateTime(2023),
                                          lastDate: DateTime(2030),
                                        );
                                        if (pickedDate != null) {
                                          final pickedTime =
                                              await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    incidentTime ??
                                                    TimeOfDay.now(),
                                              );
                                          if (pickedTime != null) {
                                            setState(() {
                                              incidentDate = pickedDate;
                                              incidentTime = pickedTime;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    _evidenceBox(),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: kPrimaryColor,
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitViolation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text(
                                "Record Violation",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
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

  Widget _buildSection(String title, IconData icon, Widget body) => Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: body),
      ],
    ),
  );
}
