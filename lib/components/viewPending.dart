import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendingReportsDialog extends StatefulWidget {
  const PendingReportsDialog({super.key});

  @override
  _PendingReportsDialogState createState() => _PendingReportsDialogState();
}

class _PendingReportsDialogState extends State<PendingReportsDialog> {
  List<Report> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingReports();
  }

  // ✅ Fetch pending reports from backend
  Future<void> fetchPendingReports() async {
    const apiUrl =
        'http://192.168.1.8:8000/violations/pending'; // your FastAPI URL
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          reports = data.map((e) => Report.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ Approve selected reports
  Future<void> approveSelectedReports() async {
    final selectedIds = reports
        .where((r) => r.isSelected)
        .map((r) => r.id)
        .toList();
    if (selectedIds.isEmpty) return;

    const apiUrl = 'http://192.168.1.8:8000/violations/approve';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(selectedIds),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Approved ${selectedIds.length} report(s).",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
        fetchPendingReports(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to approve reports: ${response.body}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error approving reports: $e")));
    }
  }

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
        width: 800,
        height: 700,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Text(
                    "Pending Reports",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Loading
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (reports.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No pending reports found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              // ✅ List of reports
              Expanded(
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
                          Checkbox(
                            value: report.isSelected,
                            onChanged: (value) =>
                                setState(() => report.isSelected = value!),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ID: ${report.id}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Student: ${report.studentName}"),
                                Text("Violation: ${report.violation}"),
                                Text("Reported by: ${report.reporter}"),
                                Text("Date: ${report.date}"),
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
                                    ),
                                    const SizedBox(width: 6),
                                    const Chip(
                                      label: Text(
                                        "Pending",
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

            // ✅ Approve button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: reports.any((r) => r.isSelected)
                    ? approveSelectedReports
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Approve Selected",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Report {
  final int id;
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

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      violation: json['violation_type'] ?? '',
      reporter: json['reported_by'] ?? '',
      offenseLevel: json['offense_level'] ?? '',
    );
  }
}
