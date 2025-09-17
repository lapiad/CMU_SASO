import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';

class ViolationDetailsDialogs extends StatefulWidget {
  final ViolationRecord allRecords;

  const ViolationDetailsDialogs({super.key, required this.allRecords});

  @override
  State<ViolationDetailsDialogs> createState() =>
      _ViolationDetailsDialogsState();
}

class _ViolationDetailsDialogsState extends State<ViolationDetailsDialogs> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
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
      ),
      content: SizedBox(
        height: 1000,
        width: 2000,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildDetailRow("Images", widget.allRecords.studentId),
              SizedBox(height: 10),
              _buildDetailRow("Student Name:", widget.allRecords.studentName),
              SizedBox(height: 10),
              _buildDetailRow("Student ID:", widget.allRecords.studentId),
              SizedBox(height: 10),
              _buildDetailRow("Violation:", widget.allRecords.violation),
              SizedBox(height: 10),
              _buildDetailRow("Offense Level:", widget.allRecords.status),
              SizedBox(height: 10),
              _buildDetailRow("Reported By:", widget.allRecords.reportedBy),
              SizedBox(height: 10),
              _buildDetailRow("Date & Time:", widget.allRecords.dateTime),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(fontSize: 20),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
