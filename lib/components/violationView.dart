import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

class ViolationDetails extends StatefulWidget {
  final ViolationRecord record;
  final bool isEditable;

  const ViolationDetails({
    super.key,
    required this.record,
    this.isEditable = false,
  });

  @override
  State<ViolationDetails> createState() => _ViolationDetailsState();
}

class _ViolationDetailsState extends State<ViolationDetails> {
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController violationController;
  late TextEditingController reportedByController;
  late TextEditingController dateTimeController;
  late TextEditingController statusController;
  late TextEditingController statusActionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.record.studentName);
    idController = TextEditingController(text: widget.record.studentId);
    violationController = TextEditingController(text: widget.record.violation);
    reportedByController = TextEditingController(
      text: widget.record.reportedBy,
    );
    dateTimeController = TextEditingController(text: widget.record.dateTime);
    statusController = TextEditingController(text: widget.record.status);
    statusActionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    violationController.dispose();
    reportedByController.dispose();
    dateTimeController.dispose();
    statusController.dispose();
    statusActionController.dispose();
    super.dispose();
  }

  Uint8List? _safeDecodeBase64(String base64String) {
    try {
      final cleaned = base64String.split(',').last.trim();
      final padding = cleaned.length % 4;
      final normalized = padding > 0
          ? cleaned.padRight(cleaned.length + (4 - padding), '=')
          : cleaned;
      return base64Decode(normalized);
    } catch (e) {
      debugPrint("Invalid Base64 image: $e");
      return null;
    }
  }

  Future<void> saveChanges() async {
    final violationId = widget.record.violationId; // ✅ correct field name
    print("Updating violation with ID: $violationId");

    final url =
        '${GlobalConfiguration().getValue("server_url")}/violations/update/$violationId';

    final updatedData = {
      "student_name": nameController.text.trim(),
      "student_id": idController.text.trim(),
      "violation": violationController.text.trim(),
      "violation_type": widget.record.violation,
      "department": widget.record.department,
      "reported_by": reportedByController.text.trim(),
      "date_time": dateTimeController.text.trim(),
      "status": statusController.text.trim(),
      "report_status": statusActionController.text.trim(),
      "offense_level": widget.record.offenseLevel,
      "image": widget.record.base64Imagestring,
      "violation_id": violationId,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Connection error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final imageBytes = _safeDecodeBase64(widget.record.base64Imagestring);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0033A0),
        leading: const Icon(Icons.person, color: Colors.white),
        title: const Text(
          "Case Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isWide ? 700 : 500,
              height: isWide ? 700 : 500,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No valid image",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailField("Student Name", nameController),
                    buildDetailField("Student Number", idController),
                    buildDetailField("Violation", violationController),
                    buildDetailField(
                      "Department",
                      TextEditingController(text: widget.record.department),
                    ),
                    buildDetailField("Reported by", reportedByController),
                    buildDetailField("Date and Time", dateTimeController),
                    buildDetailField("Status", statusController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isEditable
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget buildDetailField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const SizedBox(height: 6),
          widget.isEditable
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    controller.text,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
        ],
      ),
    );
  }
}
