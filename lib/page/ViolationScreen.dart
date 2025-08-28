import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Guard_DSH.dart';
import 'package:image_picker/image_picker.dart';

class ViolationScreen extends StatefulWidget {
  final String name;
  final String course;
  final String studentNo;
  final int violationsCount;

  const ViolationScreen({
    super.key,
    required this.name,
    required this.course,
    required this.studentNo,
    this.violationsCount = 0,
  });

  @override
  _ViolationScreenState createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  late TextEditingController fullNameController;
  late TextEditingController studentNumberController;
  late TextEditingController courseController;

  int violations = 0;

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

  String searchQuery = "";
  Set<String> selectedViolations = {};
  File? _evidenceImage; // ✅ Store uploaded photo

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.name);
    studentNumberController = TextEditingController(text: widget.studentNo);
    courseController = TextEditingController(text: widget.course);
    violations = widget.violationsCount;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    studentNumberController.dispose();
    courseController.dispose();
    super.dispose();
  }

  /// ✅ Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _evidenceImage = File(pickedFile.path);
      });
    }
  }

  /// ✅ Auto-closing confirmation popup (no button, no details)
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // cannot dismiss manually
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Checkmark icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
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
            ],
          ),
        ),
      ),
    );

    // ✅ Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SchoolGuardHome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredViolations = violationTypes
        .where((v) => v.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Violation"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Student Information
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Student Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: studentNumberController,
                        decoration: const InputDecoration(
                          labelText: "Student Number",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: courseController,
                        decoration: const InputDecoration(
                          labelText: "Course",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Violations: $violations",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Violation Types (organized grid)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Violation Types",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Search Violation",
                          prefixIcon: Icon(Icons.search),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // ✅ 2 per row
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 3, // ✅ makes all same size
                            ),
                        itemCount: filteredViolations.length,
                        itemBuilder: (context, index) {
                          final violation = filteredViolations[index];
                          final isSelected = selectedViolations.contains(
                            violation,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedViolations.remove(violation);
                                } else {
                                  selectedViolations.add(violation);
                                }
                                violations = selectedViolations.length;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                violation,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
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
              ),

              const SizedBox(height: 15),

              // ✅ Attach photo evidence
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text("Take Photo"),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text("Choose from Gallery"),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Attach photo evidence (optional)"),
              ),

              if (_evidenceImage != null) ...[
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _evidenceImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ✅ Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(); // ✅ Show popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Record Violation",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
