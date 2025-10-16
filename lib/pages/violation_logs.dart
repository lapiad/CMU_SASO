import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/Integrations.dart';
import 'package:flutter_application_1/components/violationView.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:flutter_application_1/components/violationedit.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class ViolationLogsPage extends StatefulWidget {
  const ViolationLogsPage({super.key});

  @override
  State<ViolationLogsPage> createState() => _ViolationLogsPageState();
}

class _ViolationLogsPageState extends State<ViolationLogsPage> {
  List<ViolationRecord> allRecords = [];
  double sideMenuSize = 0.0;
  bool showFilters = false;

  DateTime? startDate;
  DateTime? endDate;

  bool filterFirstOffense = false;
  bool filterSecondOffense = false;
  bool filterThirdOffense = false;
  bool filterImproperUniform = false;
  bool filterLateAttendance = false;
  bool filterSeriousMisconduct = false;
  bool filterCAS = false;
  bool filterCBA = false;
  bool filterCCS = false;
  bool filterCTE = false;
  bool filterCCJE = false;

  String searchQuery = "";

  Future<String> getName() async {
    try {
      final box = GetStorage();
      final userId = box.read('user_id');
      if (userId == null) return "User";

      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/users/$userId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['first_name'] ?? "User";
      }
    } catch (e) {
      debugPrint("Error fetching name: $e");
    }
    return "User";
  }

  List<ViolationRecord> get filteredRecords {
    return allRecords.where((record) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          record.studentName.toLowerCase().contains(query) ||
          record.studentId.toLowerCase().contains(query) ||
          record.violation.toLowerCase().contains(query);

      final matchesStatus =
          (!filterFirstOffense &&
              !filterSecondOffense &&
              !filterThirdOffense) ||
          (filterFirstOffense && record.status == 'First Offense') ||
          (filterSecondOffense && record.status == 'Second Offense') ||
          (filterThirdOffense && record.status == 'Third Offense');

      final matchesViolationType =
          (!filterImproperUniform &&
              !filterLateAttendance &&
              !filterSeriousMisconduct) ||
          (filterImproperUniform && record.violation == 'Improper Uniform') ||
          (filterLateAttendance && record.violation == 'Late Attendance') ||
          (filterSeriousMisconduct && record.violation == 'Serious Misconduct');

      final matchesDepartment =
          (!filterCAS &&
              !filterCBA &&
              !filterCCS &&
              !filterCTE &&
              !filterCCJE) ||
          (filterCAS && record.department == 'CAS') ||
          (filterCBA && record.department == 'CBA') ||
          (filterCCS && record.department == 'CCS') ||
          (filterCTE && record.department == 'CTE') ||
          (filterCCJE && record.department == 'CCJE');

      final recordDate = DateTime.tryParse(record.dateTime);
      final matchesDate =
          (startDate == null && endDate == null) ||
          (recordDate != null &&
              (startDate == null ||
                  recordDate.isAfter(
                    startDate!.subtract(const Duration(days: 1)),
                  )) &&
              (endDate == null ||
                  recordDate.isBefore(endDate!.add(const Duration(days: 1)))));

      return matchesSearch &&
          matchesStatus &&
          matchesViolationType &&
          matchesDepartment &&
          matchesDate;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Integration().fetchViolations().then((data) {
      if (data != null) {
        setState(() {
          allRecords = data
              .map(
                (item) => ViolationRecord(
                  studentName: item['student_name']?.toString() ?? '',
                  studentId: item['student_id']?.toString() ?? '',
                  violation: item['violation_type']?.toString() ?? '',
                  status: item['status']?.toString() ?? '',
                  role: item['role']?.toString() ?? '',
                  reportedBy: item['reported_by']?.toString() ?? '',
                  dateTime: item['date_of_incident']?.toString() ?? '',
                  department: item['student_department']?.toString() ?? '',
                  base64Imagestring: item['photo_evidence']?.toString() ?? '',
                  offenseLevel: item['offense_level']?.toString() ?? '',
                  violationId: item['id'] ?? '',
                ),
              )
              .toList();
        });
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellowAccent;
      case 'reviewed':
        return Colors.orange;
      case 'referred':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getoffenseColor(String status) {
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

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 30),
              SizedBox(width: 16),
              Text('Profile Settings', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 30),
              SizedBox(width: 16),
              Text("Sign Out", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ],
    );

    if (result == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
      );
    } else if (result == 'signout') {
      final box = GetStorage();
      await box.erase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Violation Logs',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 40, color: Colors.white),
          onPressed: () {
            setState(() {
              sideMenuSize = sideMenuSize == 0.0 ? 350.0 : 0.0;
            });
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
                        color: Color.fromARGB(255, 10, 44, 158),
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildSearchAndFilterRow(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildDataTable()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED SIDE MENU
  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: sideMenuSize,
      color: Colors.blue[900],
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
          const SizedBox(height: 10),
          _menuItem(Icons.home, 'Dashboard', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard()),
            );
          }),
          _menuItem(Icons.list_alt, 'Violation Logs', () {}),
          _menuItem(Icons.pie_chart, 'Summary of Reports', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SummaryReportsPage()),
            );
          }),
          const Divider(color: Colors.white),
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
          _menuItem(Icons.person, 'User Management', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserMgt()),
            );
          }),
        ],
      ),
    );
  }

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

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(
              label: SizedBox(
                width: 190,
                child: Text(
                  'Student Name',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Student ID',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Department',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Violation',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Offense Level',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Reported By',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Date & Time',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Actions',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    record.studentId,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    record.department,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    record.violation,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                      color: getoffenseColor(record.offenseLevel),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      record.offenseLevel,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    record.reportedBy,
                    style: const TextStyle(fontSize: 21, color: Colors.black),
                  ),
                ),
                DataCell(
                  Text(
                    record.dateTime,
                    style: const TextStyle(
                      fontSize: 21,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViolationFormPage(record: record),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditableViolationFormPage(record: record),
                            ),
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
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search student name, ID, or violation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => setState(() => showFilters = !showFilters),
          icon: const Icon(Icons.filter_list),
          label: const Text("Filters"),
        ),
      ],
    );
  }
}
