import 'package:flutter/material.dart';

class Refferedview extends StatelessWidget {
  final ViolationRecord allRecord;

  const Refferedview({super.key, required this.allRecord});

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
        width: 500,
        height: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              _buildField("Student Name", allRecord.studentName),
              SizedBox(height: 10),
              _buildField("Student ID", allRecord.studentId),
              SizedBox(height: 10),
              _buildField("Violation", allRecord.violation),
              SizedBox(height: 10),
              _buildField("Offense Level", allRecord.status),
              SizedBox(height: 10),
              _buildField("Reported By", allRecord.reportedBy),
              SizedBox(height: 10),
              _buildField("Date & Time", allRecord.dateTime),
              SizedBox(height: 10),
              if (allRecord.priority != null)
                _buildField("Priority", allRecord.priority!),
              SizedBox(height: 10),
              if (allRecord.referredDate != null)
                _buildField("Referred Date", allRecord.referredDate!),
              SizedBox(height: 10),
              if (allRecord.hearingDate != null) SizedBox(height: 10),
              _buildField("Hearing Date", allRecord.hearingDate!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
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
            flex: 5,
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
