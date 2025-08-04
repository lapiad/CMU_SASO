import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/guardprof.dart';
import 'package:flutter_application_1/page/guardscreen.dart';

class Scanscreen extends StatefulWidget {
  const Scanscreen({super.key});

  @override
  State<Scanscreen> createState() => _ScanscreenState();
}

class _ScanscreenState extends State<Scanscreen> {
  bool isScanned = false;
  String studentName = "Nika Luna";
  String studentID = "2024 - 005678";
  String course = "BSIT";

  List<String> selectedViolations = [];

  void toggleViolation(String violation) {
    setState(() {
      if (selectedViolations.contains(violation)) {
        selectedViolations.remove(violation);
      } else {
        selectedViolations.add(violation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Text(
          "CMU - SASO DRMS",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isScanned ? _buildViolationForm() : _buildScannerUI(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Guardscreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Scanscreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Guardprof()),
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Widget _buildScannerUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            child: Column(
              children: [
                const Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                const SizedBox(height: 10),
                const Text(
                  "Ready to Scan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Position the student ID card clearly in front of the camera.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    setState(() => isScanned = true);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  label: const Text("Start Scanning"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Instructions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text("• Ensure the ID is well-lit and visible"),
                Text("• Hold the device steady when capturing"),
                Text("• Make sure all details on the ID are readable"),
                Text(
                  "• The system will automatically extract student information",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Student Information",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(studentName, style: const TextStyle(fontSize: 16)),
                Text(
                  "$course   $studentID",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Violation Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Violation Types",
                    hintText: "e.g., Dress code, No ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Quick Select:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        "Dress Code",
                        "Noise Disturbance",
                        "Late Attendance",
                        "ID not Displayed",
                        "Serious Misconduct",
                        "Smoking on Campus",
                        "Vandalism",
                        "Littering",
                      ].map((violation) {
                        final isSelected = selectedViolations.contains(
                          violation,
                        );
                        return FilterChip(
                          label: Text(violation),
                          selected: isSelected,
                          onSelected: (_) => toggleViolation(violation),
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue,
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Image",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text("Select Image"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() => isScanned = false),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Re-scan"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text("Record Violation"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
