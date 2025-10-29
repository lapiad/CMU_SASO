import 'dart:typed_data';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/classes/Integrations.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/user_mgt.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';

class SummaryReportsPage extends StatefulWidget {
  const SummaryReportsPage({super.key});

  @override
  State<SummaryReportsPage> createState() => _SummaryReportsPageState();
}

class _SummaryReportsPageState extends State<SummaryReportsPage> {
  List<ViolationRecord> allRecords = [];
  double sideMenuSize = 0.0;

  final ScreenshotController _pieController = ScreenshotController();
  final ScreenshotController _barController = ScreenshotController();
  final ScreenshotController _lineController = ScreenshotController();

  final Map<String, String> departmentNames = {
    'CBA': 'College of Business Administration',
    'CCS': 'College of Computer Science',
    'COA': 'College of Accountancy',
    'CTE': 'College of Teachers Education',
    'CAS': 'College of Arts & Science',
    'CCJE': 'College of Criminal Justice Education',
  };

  final Map<String, Color> departmentColors = {
    'CAS': Colors.grey,
    'CBA': Colors.cyan,
    'CCS': Colors.orange,
    'COA': Colors.yellow,
    'CTE': Colors.indigo,
    'CCJE': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    Integration().fetchViolations().then((data) {
      if (data != null) {
        setState(() {
          allRecords = data
              .map<ViolationRecord>(
                (item) => ViolationRecord(
                  studentName: item['student_name'] ?? '',
                  violationType: item['violation_type'] ?? '',
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
        });
      }
    });
  }

  Map<String, int> getDepartmentDistribution() {
    final counts = <String, int>{};
    for (var record in allRecords) {
      final dept = (record.department ?? '').toUpperCase();
      if (dept.isNotEmpty) counts[dept] = (counts[dept] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getViolationTypeDistribution() {
    final counts = <String, int>{};
    for (var record in allRecords) {
      final type = record.violation.isNotEmpty ? record.violation : 'Unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getWeeklyViolationCounts() {
    final weeklyCount = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      weeklyCount[DateFormat('yyyy-MM-dd').format(date)] = 0;
    }
    for (var record in allRecords) {
      try {
        final date = DateTime.parse(record.dateTime);
        final formatted = DateFormat('yyyy-MM-dd').format(date);
        if (weeklyCount.containsKey(formatted)) {
          weeklyCount[formatted] = weeklyCount[formatted]! + 1;
        }
      } catch (_) {}
    }
    return weeklyCount;
  }

  Future<String> getName() async {
    final box = GetStorage();
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['first_name'];
    } else {
      return "User";
    }
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: [
        _popupItem(Icons.person, 'Profile Settings', 'profile'),
        _popupItem(Icons.logout, 'Sign Out', 'signout'),
      ],
    );
    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
      );
    } else if (result == 'signout') {
      final box = GetStorage();
      box.erase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    }
  }

  PopupMenuItem<String> _popupItem(IconData icon, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 26, color: const Color(0xFF446EAD)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departmentDist = getDepartmentDistribution();
    final typeDist = getViolationTypeDistribution();
    final weeklyData = getWeeklyViolationCounts();

    return Scaffold(
      backgroundColor:
          const LinearGradient(
                colors: [Color(0xFFe3eeff), Color(0xFFf5f9ff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, 400, 800)).transform !=
              null
          ? null
          : null,
      appBar: AppBar(
        title: const Text(
          'Summary of Reports',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        elevation: 8,
        shadowColor: Colors.black26,
        backgroundColor: const Color(0xFF446EAD),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 36, color: Colors.white),
          onPressed: () {
            setState(() => sideMenuSize = sideMenuSize == 0.0 ? 320.0 : 0.0);
          },
        ),
        actions: [
          FutureBuilder(
            future: getName(),
            builder: (context, snapshot) {
              return Row(
                children: [
                  Text(
                    snapshot.data ?? "Loading...",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person,
                        size: 25,
                        color: Color.fromARGB(255, 68, 110, 173),
                      ),
                      onPressed: () => _showAdminMenu(context),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (sideMenuSize != 0.0) _buildSideMenu(context),
          Expanded(
            child: allRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Screenshot(
                                controller: _pieController,
                                child: _buildPieChartCard(
                                  "Total Violations per Department",
                                  departmentDist,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Screenshot(
                                controller: _barController,
                                child: _buildBarChartCard(
                                  "Violations per Type",
                                  typeDist,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Screenshot(
                          controller: _lineController,
                          child: _buildWeeklyLineChart(weeklyData),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePdfAndSave,
        icon: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.white),
        label: const Text(
          "Export PDF",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 110, 173),
      ),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: sideMenuSize,
      color: const Color.fromARGB(255, 68, 110, 173),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.asset('images/logos.png', color: Colors.white, height: 80),
          const SizedBox(height: 10),
          const Text(
            "CMU_SASO DRMS",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(color: Colors.white),
          const Text(
            'GENERAL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          _menuItem(Icons.home, 'Dashboard', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard()),
            );
          }),
          _menuItem(Icons.list_alt, 'Violation Logs', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ViolationLogsPage()),
            );
          }),
          _menuItem(Icons.pie_chart, 'Summary of Reports', () {}),
          const Divider(color: Colors.white54, indent: 16, endIndent: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _menuHeader("ADMINISTRATION"),
              _menuItem(Icons.person, "User Management", () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => UserMgt()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
  );

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Future<void> _generatePdfAndSave() async {
    try {
      final pieImg = await _pieController.capture();
      final barImg = await _barController.capture();
      final lineImg = await _lineController.capture();

      final logoData = await rootBundle.load('images/logos.png');
      final logoBytes = logoData.buffer.asUint8List();

      final pdf = pw.Document();
      final departmentDist = getDepartmentDistribution();
      final typeDist = getViolationTypeDistribution();
      final weeklyData = getWeeklyViolationCounts();
      final totalViolations = allRecords.length;
      final topDept = departmentDist.entries.isEmpty
          ? "N/A"
          : departmentDist.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
      final topType = typeDist.entries.isEmpty
          ? "N/A"
          : typeDist.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
          build: (context) => [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "CITY OF MALABON UNIVERSITY",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      "Student Affairs & Services Office",
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.blueGrey700,
                      ),
                    ),
                    pw.Text(
                      "Disciplinary Records Management System",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.blueGrey600,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  height: 45,
                  width: 45,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey400),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                'SUMMARY REPORT OF STUDENT VIOLATIONS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Generated on ${DateFormat('MMMM dd, yyyy – hh:mm a').format(now)}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                "As of ${DateFormat('MMMM yyyy').format(now)}, the Student Affairs and Services Office recorded a total of $totalViolations student violation cases. "
                "The most common violation is '$topType', with the highest number of incidents reported from the '$topDept' department. "
                "This report summarizes department-wise, type-wise, and weekly violation trends to support informed decision-making.",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                textAlign: pw.TextAlign.justify,
              ),
            ),
            pw.SizedBox(height: 20),
            _sectionRow("Violations per Department", pieImg, departmentDist),
            _sectionRow("Violations per Type", barImg, typeDist),
            _sectionRow("Weekly Violations Overview", lineImg, weeklyData),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                "Prepared automatically by CMU_SASO DRMS",
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'Summary_Report_${DateFormat("yyyyMMdd_HHmm").format(now)}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Organized 2-page PDF generated!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error generating PDF: $e')));
      }
    }
  }

  pw.Widget _sectionRow(String title, Uint8List? image, Map<String, int> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (image != null)
              pw.Container(
                width: 230,
                height: 150,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.contain),
              ),
            pw.SizedBox(width: 10),
            pw.Expanded(child: _buildCompactSummaryTable(data)),
          ],
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildCompactSummaryTable(Map<String, int> data) {
    final headers = ['Category', 'Count'];
    final rows = data.entries.map((e) => [e.key, e.value.toString()]).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 9,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
    );
  }

  Widget _buildPieChartCard(String title, Map<String, int> data) {
    final entries = data.entries.toList();
    return _chartContainer(
      title,
      PieChart(
        PieChartData(
          sections: List.generate(entries.length, (i) {
            final key = entries[i].key;
            final value = entries[i].value;
            return PieChartSectionData(
              color:
                  departmentColors[key] ??
                  Colors.primaries[i % Colors.primaries.length],
              value: value.toDouble(),
              title: "$key\n$value",
              radius: 90,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          borderData: FlBorderData(show: false),
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildBarChartCard(String title, Map<String, int> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return _chartContainer(
      title,
      BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() < entries.length) {
                    return Text(
                      entries[value.toInt()].key,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          barGroups: List.generate(entries.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  color: colors[i % colors.length],
                  width: 18,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeeklyLineChart(Map<String, int> weeklyData) {
    final dates = weeklyData.keys.toList();
    final counts = weeklyData.values.toList();

    return _chartContainer(
      "Weekly Violation Reports",
      LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() < dates.length) {
                    return Text(
                      DateFormat(
                        'E',
                      ).format(DateTime.parse(dates[value.toInt()])),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
              ),
              spots: List.generate(
                dates.length,
                (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF446EAD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(8), child: chart),
          ),
        ],
      ),
    );
  }
}

extension on Shader {
  Null get transform => null;
}
