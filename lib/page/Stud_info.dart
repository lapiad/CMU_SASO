import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Schoolguard.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class ViolationScreen extends StatefulWidget {
  final String studentNo;
  String name;
  String course;

  ViolationScreen({
    super.key,
    required this.studentNo,
    this.name = "",
    this.course = "",
  });

  @override
  State<ViolationScreen> createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  late final TextEditingController studentnameController;
  late final TextEditingController studentidController;
  late final TextEditingController courseController;

  File? _evidenceImage;
  String searchQuery = "";
  final Set<String> selectedViolations = {};

  final List<String> violationTypes = [
    "Dress Code",
    "Noise Disturbance",
    "Late Attendance",
    "ID not Displayed",
    "Serious Misconduct",
    "Smoking on Campus",
    "Vandalism",
    "Others",
  ];

  Future<void> fetchStudentInfo() async {
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/violations/student-info/${widget.studentNo}',
  ); // Replace with your FastAPI URL
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    widget.name = data['first_name'];
    widget.course = data['course'];
    setState(() {
      studentnameController.text = widget.name;
      courseController.text = widget.course;
    });
  } else {
    // error message
    throw Exception('Failed to load student info');}
}

  // Example: Connect to backend (replace with your API endpoint)
  Future<void> recordViolationToBackend() async {
    final box = GetStorage();

    // Encode image to base64 if exists
    String? evidenceBase64;
    if (_evidenceImage != null) {
      final bytes = await _evidenceImage!.readAsBytes();
      evidenceBase64 = base64Encode(bytes);
    }

    final Map<String, dynamic> data = {
      "student_name": studentnameController.text,
      "student_id": studentidController.text,
      "course": courseController.text,
      "violations": selectedViolations.toList(),
      "evidence": evidenceBase64, // base64 string or null
    };

    // Save to GetStorage (local backend)
    await box.write('violation_${studentidController.text}', data);

    print("Saved violation: $data");
  }

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
    studentnameController = TextEditingController(text: widget.name);
    studentidController = TextEditingController(text: widget.studentNo);
    courseController = TextEditingController(text: widget.course);
  }

  @override
  void dispose() {
    studentnameController.dispose();
    studentidController.dispose();
    courseController.dispose();
    super.dispose();
  }

  // Pick image for evidence
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _evidenceImage = File(pickedFile.path));
    }
  }

  // Show success popup → redirect after 2s
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                radius: 40,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Violation Recorded!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Redirecting to dashboard...",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close popup
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SchoolGuardHome()),
          (route) => false,
        );
      }
    });
  }

  // Confirmation dialog with date & time
  void _showConfirmationDialog() {
    if (studentnameController.text.trim().isEmpty ||
        studentidController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please fill in all student information."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedViolations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select at least one violation."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedDate = DateFormat("MMMM dd, yyyy").format(now);
    final formattedTime = DateFormat("hh:mm a").format(now);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gavel,
                        color: Colors.indigo,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Confirm Violation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Please review the details before recording.",
                  style: TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),

                _infoCard("👨‍🎓 Student Information", [
                  _infoRow(Icons.person, "Name", studentnameController.text),
                  _infoRow(Icons.school, "Course", courseController.text),
                  _infoRow(
                    Icons.badge,
                    "Student No.",
                    studentidController.text,
                  ),
                ]),
                const SizedBox(height: 16),

                _infoCard(
                  "⚠️ Selected Violations",
                  selectedViolations.map((v) => Text("• $v")).toList(),
                  color: Colors.red.withOpacity(0.05),
                ),

                const SizedBox(height: 16),

                _infoCard("📅 Date & Time", [
                  _infoRow(Icons.calendar_today, "Date", formattedDate),
                  _infoRow(Icons.access_time, "Time", formattedTime),
                ], color: Colors.blue.withOpacity(0.05)),

                const SizedBox(height: 16),

                _infoCard("📸 Evidence", [
                  Row(
                    children: [
                      Icon(
                        _evidenceImage != null
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _evidenceImage != null
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _evidenceImage != null
                              ? "Photo evidence attached."
                              : "No evidence provided.",
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showSuccessDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Confirm"),
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

  Widget _infoCard(String title, List<Widget> children, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredViolations = violationTypes
        .where((v) => v.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Violation"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _studentInfoCard(),
                      const SizedBox(height: 15),
                      _violationTypeCard(filteredViolations),
                      const SizedBox(height: 15),
                      _evidenceUploader(),
                      if (_evidenceImage != null) _evidencePreview(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _actionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _textField(studentnameController, "Full Name"),
            _textField(studentidController, "Student Number"),
            _textField(courseController, "Course"),
            const SizedBox(height: 10),
            Text(
              "Violations Selected: ${selectedViolations.length}",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _violationTypeCard(List<String> violations) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Violation Types",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Search Violation",
                prefixIcon: Icon(Icons.search),
                border: UnderlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.5,
              ),
              itemCount: violations.length,
              itemBuilder: (_, i) {
                final violation = violations[i];
                final selected = selectedViolations.contains(violation);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selected
                          ? selectedViolations.remove(violation)
                          : selectedViolations.add(violation);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? Colors.indigo : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.indigoAccent : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      violation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _evidenceUploader() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          useSafeArea: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.indigo),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.indigo,
                  ),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
      icon: const Icon(Icons.camera_alt),
      label: const Text("Attach photo evidence (optional)"),
    );
  }

  Widget _evidencePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _evidenceImage!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _showConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Record Violation"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
