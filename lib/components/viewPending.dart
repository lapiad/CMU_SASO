import 'package:flutter/material.dart';

class PendingReportsDialog extends StatefulWidget {
  PendingReportsDialog({super.key});

  @override
  _PendingReportsDialogState createState() => _PendingReportsDialogState();
}

class _PendingReportsDialogState extends State<PendingReportsDialog> {
  final List<Report> reports = [
    Report(
      id: 'VR-2025-001',
      date: '02-15-2025',
      studentName: 'John Doe',
      studentId: '202201234',
      violation: 'Bullying',
      reporter: 'Mang Tani (Guard)',
      offenseLevel: 'First Offense',
    ),
    Report(
      id: 'VR-2025-002',
      date: '02-16-2025',
      studentName: 'Jane Smith',
      studentId: '202201235',
      violation: 'Cheating',
      reporter: 'Nadine Lustre',
      offenseLevel: 'Second Offense',
    ),
    Report(
      id: 'VR-2025-003',
      date: '02-17-2025',
      studentName: 'Carlos Reyes',
      studentId: '202201236',
      violation: 'Vandalism',
      reporter: 'James Reid',
      offenseLevel: 'Third Offense',
    ),
  ];

  Color getOffenseColor(String offenseLevel) {
    switch (offenseLevel) {
      case 'Third Offense':
        return Colors.red;
      case 'Second Offense':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pending Reports"),
      content: SizedBox(
        width: 900,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Unapproved reports are automatically deleted after 15 days.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              SizedBox(
                height: 600,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: report.isSelected,
                              onChanged: (value) {
                                setState(() {
                                  report.isSelected = value!;
                                });
                              },
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: Icon(Icons.person, size: 30),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.id,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Reported on ${report.date}",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Student: ${report.studentName} (${report.studentId})",
                                  ),
                                  Text("Violation: ${report.violation}"),
                                  Text("Reported by: ${report.reporter}"),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Chip(
                                        label: Text(
                                          report.offenseLevel,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: getOffenseColor(
                                          report.offenseLevel,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          "Under Review",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shape: StadiumBorder(
                                          side: BorderSide(color: Colors.blue),
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
                    },
                  ),
                ),
              ),
              if (reports.any((r) => r.isSelected))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      // Approve selected reports
                    },
                    icon: Icon(Icons.check, color: Colors.white, size: 20),
                    label: Text(
                      "Approve",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Report {
  final String id;
  final String date;
  final String studentName;
  final String studentId;
  final String violation;
  final String reporter;
  final String offenseLevel;
  bool isSelected;

  Report({
    required this.id,
    required this.date,
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.reporter,
    required this.offenseLevel,
    this.isSelected = false,
  });
}
