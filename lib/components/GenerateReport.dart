import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  final List<String> departments = [
    'All Departments',
    'COA',
    'CTE',
    'CCJE',
    'CAS',
    'CCS',
  ];

  bool _isLoading = false;
  double _progress = 0.0;

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
              violationType: item['violation_type'] ?? '',
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

    setState(() {
      _isLoading = true;
      _progress = 0.1;
    });

    await _fetchViolations();
    setState(() => _progress = 0.3);

    final records = _filterRecords();
    if (records.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No records found for the selected filters."),
        ),
      );
      return;
    }

    // Load header image
    final imageBytes = await rootBundle.load('images/header.png');
    setState(() => _progress = 0.5);
    final headerImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final pdf = pw.Document();

    // ===== Cover Page =====
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.only(top: 10),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(headerImage, width: 500, fit: pw.BoxFit.contain),
            pw.SizedBox(height: 20),
            pw.Text(
              "Student Affairs and Services Office",
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.black,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(color: PdfColors.blueGrey300, thickness: 0.8),
            pw.SizedBox(height: 40),
            pw.Expanded(
              child: pw.Center(
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'Student Violations Report',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Department: ${selectedDepartment ?? ''}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'From ${_dateFormat.format(startDate!)} to ${_dateFormat.format(endDate!)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'Generated on: ${DateFormat("MMMM dd, yyyy 'at' hh:mm a").format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() => _progress = 0.7);

    // ===== Data Table Page =====
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        header: (context) => _buildPdfHeader(headerImage),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildStyledTable(records),
          pw.SizedBox(height: 30),
          _buildPdfFooter(),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    setState(() => _progress = 0.9);
    await _savePdfToDevice(pdfBytes);

    setState(() {
      _progress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _isLoading = false;
      _progress = 0.0;
    });
  }

  // ===================== PDF BUILDERS =====================
  pw.Widget _buildPdfHeader(pw.ImageProvider headerImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(headerImage, width: 600, height: 80, fit: pw.BoxFit.contain),
        pw.SizedBox(height: 15),
        pw.Text(
          'Violation Records Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Department: ${selectedDepartment ?? "All Departments"}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          'Date Range: ${_dateFormat.format(startDate!)} to ${_dateFormat.format(endDate!)}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColors.grey600, thickness: 0.5),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        'Generated by CMU SASO System, ${DateFormat("MMMM dd, yyyy").format(DateTime.now())}',
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
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "weekly_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
  }

  // ===================== UI BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Dialog
          Container(
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
                      'Student Violations Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generatePdfReport,
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
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

          // ===== LOADING OVERLAY =====
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.75),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 4.5,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Smooth linear bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Text section
                      Text(
                        "Generating Report...",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${(100 * _progress).toInt()}% complete",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
      value: selectedValue,
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
