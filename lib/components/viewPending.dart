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

  @override
  void initState() {
    super.initState();
    fetchPendingReports();
  }

  Future<void> fetchPendingReports() async {
    const apiUrl = 'http://192.168.1.7:8000/violations/pending';
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

  Future<void> approveSelectedReports() async {
    final selectedIds = reports
        .where((r) => r.isSelected)
        .map((r) => r.id)
        .toList();
    if (selectedIds.isEmpty) return;

    const apiUrl = 'http:/192.168.1.7:8000/violations/approve';
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
        fetchPendingReports();
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
        height: 1100,
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

class Report {
  final int id;
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date_of_incident'] ?? json['date'] ?? '',
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      violation: json['violation_type'] ?? '',
      reporter: json['reported_by'] ?? '',
      offenseLevel: json['offense_level'] ?? '',
      imageUrl: json['photo_evidence'] != null && json['photo_evidence'] != ''
          ? "data:image/jpeg;base64,${json['photo_evidence']}"
          : null,
    );
  }
}
