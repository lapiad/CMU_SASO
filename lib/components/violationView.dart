import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

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
  late TextEditingController statusActionController; // Renamed for clarity

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
    // Renamed the controller to match its purpose
    statusActionController = TextEditingController(
      text: widget.record.reportStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust breakpoint for better responsiveness
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0033A0),
        // MODIFICATION: Added leading person icon as seen in the image
        leading: const Icon(Icons.person, color: Colors.white, size: 35),
        title: Text(
          "Violation Details",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MODIFICATION: Adjusted styling for the image container
            Container(
              width: isWide ? 300 : 200,
              height: isWide ? 300 : 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                // Added rounded corners to match the image
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                // Used a more fitting icon for the placeholder
                Icons.image_outlined,
                size: isWide ? 150 : 100,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top three fields remain in a single column
                    buildDetailField("Student Name", nameController),
                    buildDetailField("Student Number", idController),
                    buildDetailField("Violation", violationController),
                    buildDetailField(
                      "Department",
                      TextEditingController(text: widget.record.department),
                    ),
                    const SizedBox(height: 18),
                    // Bottom four fields are now in a two-column Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              buildDetailField(
                                "Reported by",
                                reportedByController,
                              ),
                              buildDetailField(
                                "Date and Time",
                                dateTimeController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              buildDetailField("Status", statusController),
                              buildDetailField(
                                "Status Action",
                                statusActionController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // No changes needed for the bottom navigation bar
      bottomNavigationBar: widget.isEditable
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "studentName": nameController.text,
                        "studentId": idController.text,
                        "violation": violationController.text,
                        "reportedBy": reportedByController.text,
                        "dateTime": dateTimeController.text,
                        "status": statusController.text,
                        "reportStatus": statusActionController.text,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text("Save Changes"),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8), // Slightly increased spacing
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
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
        ],
      ),
    );
  }
}
