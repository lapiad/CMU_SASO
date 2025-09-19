import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class ViolationDetailsDialogs extends StatelessWidget {
  final ViolationRecord allRecords;

  const ViolationDetailsDialogs({super.key, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // Remove default dialog margins
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // Full screen width
        height: MediaQuery.of(context).size.height, // Full screen height
        child: Column(
          children: [
            // AppBar-like header
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person_outline, size: 40, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Violation Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildDetailRow("Student Name:", allRecords.studentName),
                    SizedBox(height: 20),
                    _buildDetailRow("Student ID:", allRecords.studentId),
                    SizedBox(height: 20),
                    _buildDetailRow("Violation:", allRecords.violation),
                    SizedBox(height: 20),
                    _buildDetailRow("Offense Level:", allRecords.status),
                    SizedBox(height: 20),
                    _buildDetailRow("Reported By:", allRecords.reportedBy),
                    SizedBox(height: 20),
                    _buildDetailRow("Date & Time:", allRecords.dateTime),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Overloaded method to accept both String or Widget (Image)
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          ),
          Expanded(
            flex: 4,
            child: value is String
                ? Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  )
                : value is Widget
                ? value // Displaying Image widget directly
                : Container(),
          ),
        ],
      ),
    );
  }
}
