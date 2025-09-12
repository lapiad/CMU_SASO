import 'package:flutter/material.dart';

class ViolationDetailsDialog extends StatelessWidget {
  final ViolationRecord allRecords;

  const ViolationDetailsDialog({super.key, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_outline),
          SizedBox(width: 8),
          Text("Violation Details"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildField(allRecords.studentName, "Student Name"),
            _buildField(allRecords.studentId, "Student ID"),
            _buildField(allRecords.violation, "Violation"),
            _buildField(allRecords.status, "Offense Level"),
            _buildField(allRecords.reportedBy, "Reported By"),
            _buildField(allRecords.dateTime, "Date & Time"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class ViolationRecord {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String? priority;
  final String? referredDate;
  final String? hearingDate;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
    this.priority,
    this.referredDate,
    this.hearingDate,
  });
}
