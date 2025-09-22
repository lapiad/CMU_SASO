import 'package:flutter/material.dart';

class PendingReportsDialog extends StatefulWidget {
  const PendingReportsDialog({super.key});

  @override
  _PendingReportsDialogState createState() => _PendingReportsDialogState();
}

class _PendingReportsDialogState extends State<PendingReportsDialog> {
  final List<Report> reports = [
    Report(
      id: 'VR-2025-003',
      date: '02-16-2025',
      studentName: 'Manny Jacinto',
      studentId: '202202815',
      violation: 'Smoking on Campus',
      reporter: 'Mang Tani (Guard)',
      offenseLevel: 'Second Offense',
    ),
    Report(
      id: 'VR-2025-004',
      date: '02-16-2025',
      studentName: 'Superman Lopez',
      studentId: '202202453',
      violation: 'Dress Code',
      reporter: 'Ms. Nadine Lustre',
      offenseLevel: 'First Offense',
    ),
    Report(
      id: 'VR-2025-005',
      date: '02-17-2025',
      studentName: 'Jane Doe',
      studentId: '202203001',
      violation: 'Late Submission',
      reporter: 'Prof. Smith',
      offenseLevel: 'First Offense',
    ),
    Report(
      id: 'VR-2025-006',
      date: '02-18-2025',
      studentName: 'John Smith',
      studentId: '202203002',
      violation: 'Cheating',
      reporter: 'Ms. Annabelle',
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 800, // medium width
        height: 700, // medium height
        child: Column(
          children: [
            // Header with title + close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Pending Reports",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Text(
                'Unapproved reports are automatically deleted after 15 days.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
            const Divider(height: 1),

            // Reports list
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Checkbox(
                              value: report.isSelected,
                              onChanged: (value) {
                                setState(() {
                                  report.isSelected = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Placeholder image
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: CustomPaint(painter: CrossPainter()),
                          ),
                          const SizedBox(width: 14),

                          // Report details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "Reported on ${report.date}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                _detailRow(
                                  "Student",
                                  "${report.studentName} (${report.studentId})",
                                ),
                                _detailRow("Violation", report.violation),
                                _detailRow("Reported by", report.reporter),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        report.offenseLevel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: getOffenseColor(
                                        report.offenseLevel,
                                      ),
                                      shape: const StadiumBorder(),
                                    ),
                                    const SizedBox(width: 6),
                                    Chip(
                                      label: const Text(
                                        "Under Review",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shape: const StadiumBorder(
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

            // Approve button
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: reports.any((r) => r.isSelected)
                    ? () {
                        final selectedReports = reports
                            .where((r) => r.isSelected)
                            .toList();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color.fromARGB(
                              255,
                              119,
                              211,
                              122,
                            ),
                            content: Text(
                              "Approved ${selectedReports.length} report(s).",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(
                  Icons.check,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 18,
                ),
                label: const Text(
                  "Approve",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Draws "X" placeholder for image
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
