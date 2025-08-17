import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';

double expandedClass = 400.0;

class ViolationLogsPage extends StatefulWidget {
  const ViolationLogsPage({super.key});

  @override
  State<ViolationLogsPage> createState() => _ViolationLogsPageState();
}

class _ViolationLogsPageState extends State<ViolationLogsPage> {
  void _showAdminMenu(BuildContext context) {
    showMenu(
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
  }

  int countByStatus(String status, List<ViolationRecord> records) =>
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
    List<ViolationRecord> records = [
      ViolationRecord(
        studentName: 'Burnok Sual',
        studentId: '202298765',
        violation: 'Improper Uniform',
        status: 'Third Offense',
        reportStatus: 'Referred',
        reportedBy: 'Mang Tani',
        dateTime: '02-14-2025 11:11AM',
      ),
      ViolationRecord(
        studentName: 'Bebot Tibay',
        studentId: '202245673',
        violation: 'Late Attendance',
        status: 'First Offense',
        reportStatus: 'Pending',
        reportedBy: 'Nadine Lustre',
        dateTime: '11-29-2025 12:45AM',
      ),
      ViolationRecord(
        studentName: 'Rebron James',
        studentId: '202223985',
        violation: 'Noise Disturbance',
        status: 'Second Offense',
        reportStatus: 'Reviewed',
        reportedBy: 'Leonard Pascal',
        dateTime: '04-15-2025 3:05PM',
      ),
      ViolationRecord(
        studentName: 'Burnok Sual',
        studentId: '202298765',
        violation: 'Improper Uniform',
        status: 'Third Offense',
        reportStatus: 'Referred',
        reportedBy: 'Mang Tani',
        dateTime: '02-14-2025 11:11AM',
      ),
      ViolationRecord(
        studentName: 'Bebot Tibay',
        studentId: '202245673',
        violation: 'Late Attendance',
        status: 'First Offense',
        reportStatus: 'Pending',
        reportedBy: 'Nadine Lustre',
        dateTime: '11-29-2025 12:45AM',
      ),
      ViolationRecord(
        studentName: 'Rebron James',
        studentId: '202223985',
        violation: 'Noise Disturbance',
        status: 'Second Offense',
        reportStatus: 'Reviewed',
        reportedBy: 'Leonard Pascal',
        dateTime: '04-15-2025 3:05PM',
      ),
      ViolationRecord(
        studentName: 'Burnok Sual',
        studentId: '202298765',
        violation: 'Improper Uniform',
        status: 'Third Offense',
        reportStatus: 'Referred',
        reportedBy: 'Mang Tani',
        dateTime: '02-14-2025 11:11AM',
      ),
      ViolationRecord(
        studentName: 'Bebot Tibay',
        studentId: '202245673',
        violation: 'Late Attendance',
        status: 'First Offense',
        reportStatus: 'Pending',
        reportedBy: 'Nadine Lustre',
        dateTime: '11-29-2025 12:45AM',
      ),
      ViolationRecord(
        studentName: 'Rebron James',
        studentId: '202223985',
        violation: 'Noise Disturbance',
        status: 'Second Offense',
        reportStatus: 'Reviewed',
        reportedBy: 'Leonard Pascal',
        dateTime: '04-15-2025 3:05PM',
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
                  onPressed: () {
                    _showFilterDialog();
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text(
                    "Filter By",
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 1900,
              height: 700,
              child: Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Student Name',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Student ID',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Violation',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Report Status',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Reported By',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 185,
                          child: Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 190,
                          child: Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: records.map((record) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              record.studentName,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          DataCell(
                            Text(
                              record.studentId,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          DataCell(
                            Text(
                              record.violation,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(record.status),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                record.status,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getActionStatusColor(
                                  record.reportStatus,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                record.reportStatus,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              record.reportedBy,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          DataCell(
                            Text(
                              record.dateTime,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    size: 30,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 30),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                      child: const Text(
                        'Clear Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
  final String reportStatus;
  final String reportedBy;
  final String dateTime;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportStatus,
    required this.reportedBy,
    required this.dateTime,
  });
}
