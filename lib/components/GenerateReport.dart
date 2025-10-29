import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/Integrations.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedDepartment;

  List<ViolationRecord> allRecords = [];
  final _dateFormat = DateFormat('yyyy-MM-dd');

  // Example list of departments — you can replace or load dynamically
  final List<String> departments = [
    'All Departments',
    'COA',
    'CTE',
    'CCJE',
    'CAS',
    'CCS',
  ];

  // ===================== DATE PICKER =====================
  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // ===================== FETCH VIOLATIONS =====================
  Future<void> _fetchViolations() async {
    final data = await Integration().fetchViolations();
    if (data != null) {
      allRecords = data
          .map(
            (item) => ViolationRecord(
              studentName: item['student_name'] ?? '',
              studentId: item['student_id'] ?? '',
              violation: item['violation_type'] ?? '',
              status: item['status'] ?? '',
              role: item['role'] ?? '',
              reportedBy: item['reported_by'] ?? '',
              dateTime: item['date_of_incident'] ?? '',
              department: item['student_department'] ?? '',
              base64Imagestring: item['photo_evidence'] ?? '',
              offenseLevel: item['offense_level'] ?? '',
              violationId: item['id'] ?? '',
            ),
          )
          .toList();
    }
  }

  // ===================== FILTER RECORDS =====================
  List<ViolationRecord> _filterRecords() {
    if (startDate == null || endDate == null) return [];

    return allRecords.where((record) {
      try {
        final recordDate = DateTime.parse(record.dateTime);
        final withinRange =
            recordDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            recordDate.isBefore(endDate!.add(const Duration(days: 1)));

        final matchesDepartment =
            selectedDepartment == null ||
            selectedDepartment == 'All Departments' ||
            record.department == selectedDepartment;

        return withinRange && matchesDepartment;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // ===================== GENERATE PDF =====================
  Future<void> _generatePdfReport() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start and end dates.")),
      );
      return;
    }

    await _fetchViolations();
    final records = _filterRecords();

    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No records found for the selected filters."),
        ),
      );
      return;
    }

    final pdf = pw.Document();

    // ===== Cover Page =====
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'City of Malabon University',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Weekly Violation Report',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Department: ${selectedDepartment ?? "All Departments"}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'From ${_dateFormat.format(startDate!)} to ${_dateFormat.format(endDate!)}',
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Generated on: ${DateFormat("MMMM dd, yyyy – hh:mm a").format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      ),
    );

    // ===== Data Table Page =====
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildPdfHeader(),
          pw.SizedBox(height: 15),
          _buildStyledTable(records),
          pw.SizedBox(height: 30),
          _buildPdfFooter(),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    await _savePdfToDevice(pdfBytes);
  }

  // ===================== PDF BUILDERS =====================
  pw.Widget _buildPdfHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Violation Records Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Department: ${selectedDepartment ?? "All Departments"}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          'Date Range: ${_dateFormat.format(startDate!)} → ${_dateFormat.format(endDate!)}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildStyledTable(List<ViolationRecord> records) {
    final headers = [
      'Student ID',
      'Student Name',
      'Violation',
      'Date of Incident',
      'Department',
      'Reported By',
      'Role',
      'Status',
      'Offense Level',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(2.0),
      1: const pw.FlexColumnWidth(2.8),
      2: const pw.FlexColumnWidth(2.8),
      3: const pw.FlexColumnWidth(2.0),
      4: const pw.FlexColumnWidth(2.0),
      5: const pw.FlexColumnWidth(2.2),
      6: const pw.FlexColumnWidth(1.6),
      7: const pw.FlexColumnWidth(1.6),
      8: const pw.FlexColumnWidth(1.6),
    };

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.blue800),
      children: headers
          .map(
            (header) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              child: pw.Center(
                child: pw.Text(
                  header,
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );

    final dataRows = List<pw.TableRow>.generate(records.length, (index) {
      final record = records[index];
      final rowColor = index.isEven ? PdfColors.grey200 : PdfColors.white;

      return pw.TableRow(
        decoration: pw.BoxDecoration(
          color: rowColor,
          border: const pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.3),
          ),
        ),
        children: [
          _buildCell(record.studentId),
          _buildCell(record.studentName),
          _buildCell(record.violation),
          _buildCell(
            DateFormat('MMM dd, yyyy').format(DateTime.parse(record.dateTime)),
          ),
          _buildCell(record.department),
          _buildCell(record.reportedBy),
          _buildCell(record.role),
          _buildCell(record.status),
          _buildCell(record.offenseLevel),
        ],
      );
    });

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
      columnWidths: columnWidths,
      children: [headerRow, ...dataRows],
    );
  }

  pw.Widget _buildCell(String text) {
    double fontSize = 10.0;
    if (text.length > 25) fontSize = 9.5;
    if (text.length > 40) fontSize = 8.8;
    if (text.length > 60) fontSize = 8.0;
    if (text.length > 80) fontSize = 7.0;

    final displayText = text.trim().isNotEmpty ? text.trim() : '-';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        displayText,
        textAlign: pw.TextAlign.left,
        softWrap: true,
        maxLines: null,
        overflow: pw.TextOverflow.visible,
        style: pw.TextStyle(fontSize: fontSize, color: PdfColors.black),
      ),
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generated by CMU SAO System • ${DateFormat("MMMM dd, yyyy").format(DateTime.now())}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  // ===================== SAVE PDF =====================
  Future<void> _savePdfToDevice(Uint8List pdfBytes) async {
    final now = DateTime.now();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "weekly_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    //   try {
    //     final jsfile =pdfBytes.toJS;
    //     final jsBlobParts = <JSAny>[jsfile].toJS;
    //     final blob = html.Blob(jsBlobParts, html.BlobPropertyBag(type: 'application/pdf'));
    //     final url = html.URL.createObjectURL(blob);

    //     final anchor = html.document.createElement('a') as html.HTMLAnchorElement
    //       ..href = url
    //       ..download =
    //           "weekly_report_${DateTime.now().millisecondsSinceEpoch}.pdf"
    //       ..target = "blank";

    //     html.document.body!.append(anchor);
    //     anchor.click();
    //     anchor.remove();
    //     html.URL.revokeObjectURL(url);

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text("✅ PDF report downloaded successfully!"),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //   } catch (e) {
    //     debugPrint("PDF Download Error: $e");
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text("❌ Failed to download report: $e"),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
  }

  // ===================== UI BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Header =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.description_outlined,
                  size: 30,
                  color: Colors.blueAccent,
                ),
                SizedBox(width: 10),
                Text(
                  'Generate Weekly Report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ===== Department Dropdown =====
            _buildDropdownField(
              label: 'Department',
              icon: Icons.apartment_outlined,
              items: departments,
              selectedValue: selectedDepartment,
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
            ),
            const SizedBox(height: 18),

            // ===== Start and End Dates =====
            _buildDateField(
              label: 'Start Date',
              icon: Icons.calendar_today_outlined,
              isStart: true,
              date: startDate,
            ),
            const SizedBox(height: 18),
            _buildDateField(
              label: 'End Date',
              icon: Icons.calendar_month_outlined,
              isStart: false,
              date: endDate,
            ),
            const SizedBox(height: 30),

            // ===== Generate Button =====
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _generatePdfReport,
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text(
                  'Download PDF Report',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FORM WIDGETS =====================
  Widget _buildDateField({
    required String label,
    required IconData icon,
    required bool isStart,
    required DateTime? date,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: () => _pickDate(context, isStart),
      controller: TextEditingController(
        text: date != null ? _dateFormat.format(date) : '',
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      items: items
          .map(
            (dept) => DropdownMenuItem(
              value: dept,
              child: Text(dept, style: const TextStyle(fontSize: 16)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
