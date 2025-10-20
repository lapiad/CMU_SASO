import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendingReportsDialog extends StatefulWidget {
  const PendingReportsDialog({super.key});

  @override
  State<PendingReportsDialog> createState() => _PendingReportsDialogState();
}

class _PendingReportsDialogState extends State<PendingReportsDialog> {
  List<Report> reports = [];
  bool isLoading = true;

  // Change this IP to your backend’s IP if needed
  static const String baseUrl = 'http://192.168.1.4:8000';

  @override
  void initState() {
    super.initState();
    fetchPendingReports();
  }

  /// Fetch all pending reports
  Future<void> fetchPendingReports() async {
    final apiUrl = Uri.parse('$baseUrl/violations/pending');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          reports = data.map((e) => Report.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        debugPrint('Failed to load pending reports: ${response.body}');
        setState(() => isLoading = false);
        _showSnackBar(
          "Failed to load reports (Code: ${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      setState(() => isLoading = false);
      _showSnackBar("Error fetching reports: $e", isError: true);
    }
  }

  /// Approve all selected reports
  Future<void> approveSelectedReports() async {
    final selectedIds = reports
        .where((r) => r.isSelected)
        .map((r) => r.id)
        .toList();

    if (selectedIds.isEmpty) {
      _showSnackBar("No reports selected", isError: true);
      return;
    }

    final apiUrl = Uri.parse('$baseUrl/violations/approve');
    try {
      final response = await http.put(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(selectedIds),
      );

      if (response.statusCode == 200) {
        _showSnackBar(
          "Approved ${selectedIds.length} report(s).",
          isError: false,
        );
        fetchPendingReports(); // Refresh list after approving
      } else {
        _showSnackBar(
          "Failed to approve reports: ${response.body}",
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar("Error approving reports: $e", isError: true);
    }
  }

  /// Helper method to show consistent snackbars
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  /// Color indicator for offense level
  Color getOffenseColor(String offenseLevel) {
    switch (offenseLevel.toLowerCase()) {
      case 'third offense':
        return Colors.red;
      case 'second offense':
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
        width: 1100,
        height: 800,
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

            // Body
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reports.isEmpty
                  ? const Center(
                      child: Text(
                        "No pending reports found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
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
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: report.isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    report.isSelected = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              // Image preview
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child:
                                    report.imageUrl != null &&
                                        report.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          report.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                );
                                              },
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              // Info section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ID: ${report.id}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text("Reported on ${report.date}"),
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
                                        ),
                                        const SizedBox(width: 6),
                                        const Chip(
                                          label: Text(
                                            "Under Review",
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shape: StadiumBorder(
                                            side: BorderSide(
                                              color: Colors.blue,
                                            ),
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
                    ? approveSelectedReports
                    : null,
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
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

/// Data model
class Report {
  final dynamic id;
  final String date;
  final String studentName;
  final String studentId;
  final String violation;
  final String reporter;
  final String offenseLevel;
  final String? imageUrl;
  bool isSelected;

  Report({
    required this.id,
    required this.date,
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.reporter,
    required this.offenseLevel,
    this.imageUrl,
    this.isSelected = false,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      date: json['date_of_incident'] ?? json['date'] ?? '',
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      violation: json['violation_type'] ?? '',
      reporter: json['reported_by'] ?? '',
      offenseLevel: json['offense_level'] ?? '',
      imageUrl:
          (json['photo_evidence'] != null &&
              json['photo_evidence'].toString().isNotEmpty)
          ? "data:image/jpeg;base64,${json['photo_evidence']}"
          : null,
    );
  }
}
