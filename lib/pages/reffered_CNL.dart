import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';

class RefferedCnl extends StatefulWidget {
  RefferedCnl({super.key});

  @override
  State<RefferedCnl> createState() => _RefferedCnlState();
}

class _RefferedCnlState extends State<RefferedCnl> {
  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('Profile Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        PopupMenuItem(
          value: 'system',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('System Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text("Sign Out", style: TextStyle(fontSize: 20)),
        ),
      ],
    );

    if (result == 'logout') {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  final List<ViolationRecord> records = [
    ViolationRecord(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Under Review',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecord(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Referred',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
    ViolationRecord(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Pending',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecord(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Reviewed',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
  ];

  int countByStatus(String status) =>
      records.where((r) => r.status == status).length;

  bool filterFirstOffense = false;
  bool filterSecondOffense = false;
  bool filterThirdOffense = false;

  bool filterPending = false;
  bool filterUnderReview = false;
  bool filterReviewed = false;

  bool filterImproperUniform = false;
  bool filterLateAttendance = false;
  bool filterSeriousMisconduct = false;

  bool filterGuard = false;
  bool filterSASOOfficer = false;
  bool filterProfessor = false;
  bool filterAdministration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referred To Council'),
        backgroundColor: const Color.fromARGB(255, 182, 175, 175),
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              const Text(
                'ADMIN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showAdminMenu(context),
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 253, 250, 250),
                  child: Icon(Icons.person, color: Colors.black),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 10.0),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: buildSummaryCard(
                      "Total Cases",
                      records.length.toString(),
                      "Active Referrals",
                      Icons.cases_outlined,
                      const Color.fromARGB(255, 33, 31, 196),
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: buildSummaryCard(
                      "Under Review",
                      countByStatus("Under Review").toString(),
                      "Being Evaluated",
                      Icons.reviews,
                      const Color.fromARGB(255, 24, 206, 33),
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: buildSummaryCard(
                      "Reviewed",
                      countByStatus("Reviewed").toString(),
                      "Finalized Cases",
                      Icons.check_circle_outline,
                      const Color.fromARGB(255, 97, 77, 197),
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: buildSummaryCard(
                      "Pending",
                      countByStatus("Pending").toString(),
                      "Awaiting Decision",
                      Icons.pending,
                      const Color.fromARGB(255, 44, 71, 194),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            buildCaseTable(),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[200],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 70.0,
                      maxWidth: 70.0,
                    ),
                    child: Image.asset('images/logos.png'),
                  ),
                  const Text(
                    "CMU_SASO DRMS",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'GENERAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              tileColor: Colors.grey[300],
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Violation Logs'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ViolationLogsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Summary of Reports'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryReportsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Referred to Council'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ADMINISTRATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User management'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserMgt()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 300,
      height: 180,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget buildCaseTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText:
                      'Search by student name, student ID, or violation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                _showFilterDialog();
              },
              icon: const Icon(Icons.filter_list),
              label: const Text("Filter By", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1887,
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnWidths: const {
                0: FixedColumnWidth(180),
                1: FixedColumnWidth(180),
                2: FixedColumnWidth(180),
                3: FixedColumnWidth(180),
                4: FixedColumnWidth(180),
                5: FixedColumnWidth(180),
                6: FixedColumnWidth(180),
                7: FixedColumnWidth(180),
                8: FixedColumnWidth(150),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: const [
                    _TableCell('Student Name', bold: true),
                    _TableCell('Student ID', bold: true),
                    _TableCell('Violation', bold: true),
                    _TableCell('Priority', bold: true, center: true),
                    _TableCell('Status', bold: true, center: true),
                    _TableCell('Reported By', bold: true),
                    _TableCell('Referred Date', bold: true),
                    _TableCell('Hearing Date', bold: true),
                    _TableCell('Actions', bold: true, center: true),
                  ],
                ),
                ...records.map((record) {
                  return TableRow(
                    children: [
                      _TableCell(record.studentName),
                      _TableCell(record.studentId),
                      _TableCell(
                        record.violation,
                        color: Colors.red,
                        bold: true,
                      ),
                      _TableCell(
                        record.priority ?? '-',
                        bgColor: Colors.red.shade100,
                        center: true,
                      ),
                      _TableCell(
                        record.status,
                        bgColor: Colors.blue.shade100,
                        center: true,
                      ),
                      _TableCell(record.reportedBy),
                      _TableCell(record.referredDate ?? '-'),
                      _TableCell(record.hearingDate ?? '-'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View',
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'Documents',
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter Dialog",
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              left: 1325,
              top: 33,
              child: Material(
                type: MaterialType.transparency,
                child: AlertDialog(
                  title: const Text('Filter Options'),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Status'),
                          CheckboxListTile(
                            title: const Text("First Offense"),
                            value: filterFirstOffense,
                            onChanged: (val) {
                              setState(() {
                                filterFirstOffense = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Second Offense"),
                            value: filterSecondOffense,
                            onChanged: (val) {
                              setState(() {
                                filterSecondOffense = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Third Offense"),
                            value: filterThirdOffense,
                            onChanged: (val) {
                              setState(() {
                                filterThirdOffense = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Action Status'),
                          CheckboxListTile(
                            title: const Text("Pending"),
                            value: filterPending,
                            onChanged: (val) {
                              setState(() {
                                filterPending = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Under Review"),
                            value: filterUnderReview,
                            onChanged: (val) {
                              setState(() {
                                filterUnderReview = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Reviewed"),
                            value: filterReviewed,
                            onChanged: (val) {
                              setState(() {
                                filterReviewed = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Violation Type'),
                          CheckboxListTile(
                            title: const Text("Improper Uniform"),
                            value: filterImproperUniform,
                            onChanged: (val) {
                              setState(() {
                                filterImproperUniform = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Late Attendance"),
                            value: filterLateAttendance,
                            onChanged: (val) {
                              setState(() {
                                filterLateAttendance = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Serious Misconduct"),
                            value: filterSeriousMisconduct,
                            onChanged: (val) {
                              setState(() {
                                filterSeriousMisconduct = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Reported By'),
                          CheckboxListTile(
                            title: const Text("Guard"),
                            value: filterGuard,
                            onChanged: (val) {
                              setState(() {
                                filterGuard = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("SASO Officer"),
                            value: filterSASOOfficer,
                            onChanged: (val) {
                              setState(() {
                                filterSASOOfficer = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Professor"),
                            value: filterProfessor,
                            onChanged: (val) {
                              setState(() {
                                filterProfessor = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Administration"),
                            value: filterAdministration,
                            onChanged: (val) {
                              setState(() {
                                filterAdministration = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          filterFirstOffense = false;
                          filterSecondOffense = false;
                          filterThirdOffense = false;
                          filterPending = false;
                          filterUnderReview = false;
                          filterReviewed = false;
                          filterImproperUniform = false;
                          filterLateAttendance = false;
                          filterSeriousMisconduct = false;
                          filterGuard = false;
                          filterSASOOfficer = false;
                          filterProfessor = false;
                          filterAdministration = false;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear Filters'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool center;
  final Color? color;
  final Color? bgColor;

  const _TableCell(
    this.text, {
    this.bold = false,
    this.center = false,
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(12),
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
          fontSize: 20,
        ),
      ),
    );
  }
}
