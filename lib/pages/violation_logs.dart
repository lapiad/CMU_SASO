import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/violationView.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  ); // Replace with your FastAPI URL
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['first_name']);
    return data['first_name'];
  } else {
    // error message
    return "null";
  }
}

class ViolationLogsPage extends StatefulWidget {
  const ViolationLogsPage({super.key});

  @override
  State<ViolationLogsPage> createState() => _ViolationLogsPageState();
}

class _ViolationLogsPageState extends State<ViolationLogsPage> {
  double sideMenuSize = 0.0;
  Future<String> getName() async {
    final box = GetStorage();
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
    ); // Replace with your FastAPI URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['first_name']);
      return data['first_name'];
    } else {
      // error message
      return "null";
    }
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        const PopupMenuItem(
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
        PopupMenuItem(
          child: const Text("Sign Out", style: TextStyle(fontSize: 20)),
          onTap: () {
            final box = GetStorage();
            box.remove('user_id');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ],
    );

    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
      );
    }

    if (result == 'signout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  // Filter variables
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

  String searchQuery = "";

  final List<ViolationRecord> allRecords = [
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

  List<ViolationRecord> get filteredRecords {
    return allRecords.where((record) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          record.studentName.toLowerCase().contains(query) ||
          record.studentId.toLowerCase().contains(query) ||
          record.violation.toLowerCase().contains(query);

      final matchesStatus =
          ((!filterFirstOffense &&
              !filterSecondOffense &&
              !filterThirdOffense) ||
          (filterFirstOffense && record.status == 'First Offense') ||
          (filterSecondOffense && record.status == 'Second Offense') ||
          (filterThirdOffense && record.status == 'Third Offense'));

      final matchesReportStatus =
          ((!filterPending && !filterUnderReview && !filterReviewed) ||
          (filterPending && record.reportStatus == 'Pending') ||
          (filterUnderReview && record.reportStatus == 'Under Review') ||
          (filterReviewed && record.reportStatus == 'Reviewed'));

      final matchesViolationType =
          ((!filterImproperUniform &&
              !filterLateAttendance &&
              !filterSeriousMisconduct) ||
          (filterImproperUniform && record.violation == 'Improper Uniform') ||
          (filterLateAttendance && record.violation == 'Late Attendance') ||
          (filterSeriousMisconduct &&
              record.violation == 'Serious Misconduct'));

      return matchesSearch &&
          matchesStatus &&
          matchesReportStatus &&
          matchesViolationType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Color getActionStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return Colors.yellow;
        case 'Reviewed':
          return Colors.green;
        case 'Referred':
          return Colors.red;
        case 'Under Review':
          return Colors.orange;
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
        title: const Text(
          'Violation Logs',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 40, color: Colors.white),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              sideMenuSize = sideMenuSize == 0.0 ? 350.0 : 0.0;
            });
          },
        ),
        actions: [
          Row(
            children: [
              FutureBuilder(
                future: getName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? snapshot.data! : "Loading...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 253, 250, 250),
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 25,
                    color: Color.fromARGB(255, 10, 44, 158),
                  ),
                  onPressed: () => _showAdminMenu(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sideMenuSize != 0.0)
            SizedBox(
              width: sideMenuSize,
              height: 900,
              child: Container(
                decoration: BoxDecoration(color: Colors.blue[900]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'images/logos.png',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "  CMU_SASO DRMS",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'GENERAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.list_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        'Violation Logs',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViolationLogsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.pie_chart,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        'Summary of Reports',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummaryReportsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        'Referred to Council',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RefferedCnl(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ADMINISTRATION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        'User management',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
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
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() => searchQuery = val);
                          },
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
                        onPressed: _showFilterDialog,
                        icon: const Icon(Icons.filter_list),
                        label: const Text("Filter By"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 1900,
                    height: 796,
                    child: Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
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
                                width: 200,
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
                                width: 185,
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
                          rows: filteredRecords.map((record) {
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
                                      color: Colors.red,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(record.status),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      record.status,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: getActionStatusColor(
                                        record.reportStatus,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      record.reportStatus,
                                      style: const TextStyle(fontSize: 20),
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
                                        icon: const Icon(Icons.remove_red_eye),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ViolationDetailsDialogs(
                                                allRecords: allRecords.first,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ViolationDetailsDialogs(
                                                allRecords: record,
                                              );
                                            },
                                          );
                                        },
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
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              alignment: AlignmentGeometry.xy(1.06, 9.90),
              title: const Text("Filter Options"),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 400,
                  height: 747,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Status"),
                      CheckboxListTile(
                        title: const Text("First Offense"),
                        value: filterFirstOffense,
                        onChanged: (val) => setStateDialog(
                          () => filterFirstOffense = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Second Offense"),
                        value: filterSecondOffense,
                        onChanged: (val) => setStateDialog(
                          () => filterSecondOffense = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Third Offense"),
                        value: filterThirdOffense,
                        onChanged: (val) => setStateDialog(
                          () => filterThirdOffense = val ?? false,
                        ),
                      ),
                      const Divider(),
                      const Text("Report Status"),
                      CheckboxListTile(
                        title: const Text("Pending"),
                        value: filterPending,
                        onChanged: (val) =>
                            setStateDialog(() => filterPending = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text("Under Review"),
                        value: filterUnderReview,
                        onChanged: (val) => setStateDialog(
                          () => filterUnderReview = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Reviewed"),
                        value: filterReviewed,
                        onChanged: (val) =>
                            setStateDialog(() => filterReviewed = val ?? false),
                      ),
                      const Divider(),
                      const Text("Violation Type"),
                      CheckboxListTile(
                        title: const Text("Improper Uniform"),
                        value: filterImproperUniform,
                        onChanged: (val) => setStateDialog(
                          () => filterImproperUniform = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Late Attendance"),
                        value: filterLateAttendance,
                        onChanged: (val) => setStateDialog(
                          () => filterLateAttendance = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Serious Misconduct"),
                        value: filterSeriousMisconduct,
                        onChanged: (val) => setStateDialog(
                          () => filterSeriousMisconduct = val ?? false,
                        ),
                      ),
                      const Divider(),
                      const Text('Reported By'),
                      CheckboxListTile(
                        title: const Text("Guard"),
                        value: filterGuard,
                        onChanged: (val) =>
                            setStateDialog(() => filterGuard = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text("SASO Officer"),
                        value: filterSASOOfficer,
                        onChanged: (val) => setStateDialog(
                          () => filterSASOOfficer = val ?? false,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Professor"),
                        value: filterProfessor,
                        onChanged: (val) => setStateDialog(
                          () => filterProfessor = val ?? false,
                        ),
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
                    "Clear",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {}); // refresh parent
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Apply",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
