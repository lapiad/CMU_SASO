import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';

class ViolationLogsPage extends StatelessWidget {
  const ViolationLogsPage({super.key});

  void _showAdminMenu(BuildContext context) async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        const PopupMenuItem(value: "profile", child: Text("Profile Settings")),
        const PopupMenuItem(value: "settings", child: Text("System Settings")),
        const PopupMenuItem(value: "logout", child: Text("Sign Out")),
      ],
    );

    if (selected == "logout") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ViolationRecord> records = [
      ViolationRecord(
        studentName: 'Burnok Sual',
        studentId: '202298765',
        violation: 'Improper Uniform',
        status: 'Third Offense',
        reportstatus: 'Referred',
        reportedBy: 'Mang Tani',
        dateTime: '02-14-2025 11:11AM',
      ),
      ViolationRecord(
        studentName: 'Bebot Tibay',
        studentId: '202245673',
        violation: 'Late Attendance',
        status: 'First Offense',
        reportstatus: 'Pending',
        reportedBy: 'Nadine Lustre',
        dateTime: '11-29-2025 12:45AM',
      ),
      ViolationRecord(
        studentName: 'Rebron James',
        studentId: '202223985',
        violation: 'Noise Disturbance',
        status: 'Second Offense',
        reportstatus: 'Reviewed',
        reportedBy: 'Leonard Pascal',
        dateTime: '04-15-2025 3:05PM',
      ),
      ViolationRecord(
        studentName: 'Juan Dela Cruz',
        studentId: '202212345',
        violation: 'Smoking on Campus',
        status: 'Third Offense',
        reportstatus: 'Referred',
        reportedBy: 'Nadine Lustre',
        dateTime: '07-15-2025 5:30PM',
      ),
      ViolationRecord(
        studentName: 'Annie Batumbakal',
        studentId: '202201234',
        violation: 'Improper Uniform',
        status: 'Second Offense',
        reportstatus: 'Pending',
        reportedBy: 'Mang Tani',
        dateTime: '02-15-2025 4:05PM',
      ),
      ViolationRecord(
        studentName: 'Jun-jun Valdez',
        studentId: '202292453',
        violation: 'Littering',
        status: 'Third Offense',
        reportstatus: 'Reviewed',
        reportedBy: 'Leonard Pascal',
        dateTime: '09-15-2025 9:10AM',
      ),
      ViolationRecord(
        studentName: 'Coco Panday',
        studentId: '202201111',
        violation: 'Vandalism',
        status: 'First Offense',
        reportstatus: 'Pending',
        reportedBy: 'Nadine Lustre',
        dateTime: '06-15-2025 7:40AM',
      ),
    ];

    Color getActionStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return Colors.yellow;
        case 'Reviewed':
          return Colors.green;
        case 'Referred':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'first offense':
          return Colors.yellowAccent;
        case 'second offense':
          return Colors.orange;
        case 'third offense':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Logs'),
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
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 253, 250, 250),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () => _showAdminMenu(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Violation Logs"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text("Summary of Reports"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryReportsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text("Referred to Council"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RefferedCnl()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("User management"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserMgt()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text(
                    "Filter By",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(250),
                      1: FixedColumnWidth(250),
                      2: FixedColumnWidth(250),
                      3: FixedColumnWidth(250),
                      4: FixedColumnWidth(250),
                      5: FixedColumnWidth(250),
                      6: FixedColumnWidth(250),
                      7: FixedColumnWidth(135),
                    },
                    border: TableBorder.all(color: Colors.black12),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                        ),
                        children: const [
                          _TableHeader('Student Name'),
                          _TableHeader('Student ID'),
                          _TableHeader('Violation'),
                          _TableHeader('Status'),
                          _TableHeader('Report Status'),
                          _TableHeader('Reported By'),
                          _TableHeader('Date & Time'),
                          _TableHeader('Actions'),
                        ],
                      ),
                      for (var record in records)
                        TableRow(
                          children: [
                            _TableCell(record.studentName),
                            _TableCell(record.studentId),
                            _TableCell(record.violation, color: Colors.red),
                            _ColoredCell(
                              record.status,
                              bgColor: getStatusColor(record.status),
                            ),
                            _ColoredCell(
                              record.reportstatus,
                              bgColor: getActionStatusColor(
                                record.reportstatus,
                              ),
                            ),
                            _TableCell(record.reportedBy),
                            _TableCell(record.dateTime),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      // View logic here
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // Edit logic here
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === UI Helpers ===

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  final Color? color;
  const _TableCell(this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        value,
        style: TextStyle(fontSize: 18, color: color ?? Colors.black),
      ),
    );
  }
}

class _ColoredCell extends StatelessWidget {
  final String value;
  final Color bgColor;
  const _ColoredCell(this.value, {required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// === Model ===

class ViolationRecord {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportstatus;
  final String reportedBy;
  final String dateTime;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportstatus,
    required this.reportedBy,
    required this.dateTime,
  });
}
