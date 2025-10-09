import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/violationView.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
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

  // 🔹 Added for date filtering
  DateTime? startDate;
  DateTime? endDate;

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
        PopupMenuItem(
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
      );
    }
    if (result == 'signout') {
      final box = GetStorage();
      box.remove('user_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  // 🔹 Filter booleans
  bool filterFirstOffense = false;
  bool filterSecondOffense = false;
  bool filterThirdOffense = false;
  bool filterPending = false;
  bool filterUnderReview = false;
  bool filterReviewed = false;
  bool filterImproperUniform = false;
  bool filterLateAttendance = false;
  bool filterSeriousMisconduct = false;
  bool filterCAS = false;
  bool filterCBA = false;
  bool filterCCS = false;
  bool filterCTE = false;
  bool filterCCJE = false;

  String searchQuery = "";

  Future<void> fetchViolations() async {
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/violations',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Check if decoded is a Map and contains the expected key
        if (decoded is Map<String, dynamic> && decoded['violations'] is List) {
          final List<dynamic> data = decoded['violations'];
          setState(() {
            allRecords = data
                .map(
                  (item) => ViolationRecord(
                    studentName: item['student_name']?.toString() ?? '',
                    studentId: item['student_id']?.toString() ?? '',
                    violation: item['violation_type']?.toString() ?? '',
                    status: item['status']?.toString() ?? '',
                    reportedBy: item['reported_by']?.toString() ?? '',
                    dateTime: item['date_of_incident']?.toString() ?? '',
                    department: item['student_department']?.toString() ?? '',
                    base64Imagestring: item['photo_evidence']?.toString() ?? '',
                  ),
                )
                .toList();
          });
        } else {
          print('Unexpected JSON structure: missing "violations" list');
        }
      } else {
        print('Failed to load violations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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

      // 🔹 Date Filter Logic
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
    fetchViolations();
  }

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.yellowAccent;
        case 'reviewed':
          return Colors.orange;
        case 'referred':
          return Colors.red;
        default:
          return Colors.grey; // fallback color for unknown statuses
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Logs', style: TextStyle(fontSize: 30)),
        foregroundColor: Colors.white,
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  snapshot.hasData ? snapshot.data! : "Loading...",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
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
      ),
      body: Stack(
        children: [
          Row(
            children: [
              if (sideMenuSize != 0.0) _buildSideMenu(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildSearchAndFilterRow(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Student Name',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Student ID',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Department',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Violation',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Reported By',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 170,
                                    child: Text(
                                      'Date & Time',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        fontSize: 27,
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
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.studentId,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.department,
                                        style: const TextStyle(
                                          fontSize: 24,
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
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(record.status),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          record.status,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.reportedBy,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        record.dateTime,
                                        style: const TextStyle(
                                          fontSize: 24,
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
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViolationDetails(
                                                        record: record,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.green,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViolationDetails(
                                                        record: record,
                                                        isEditable: true,
                                                      ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 🔹 Filter Drawer (same original style)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: showFilters ? 0 : -300,
            top: 0,
            bottom: 0,
            width: 300,
            child: Material(
              elevation: 16,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => showFilters = false),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          _filterSection("Status", [
                            _buildCheckbox(
                              "First Offense",
                              filterFirstOffense,
                              (v) => setState(() => filterFirstOffense = v),
                            ),
                            _buildCheckbox(
                              "Second Offense",
                              filterSecondOffense,
                              (v) => setState(() => filterSecondOffense = v),
                            ),
                            _buildCheckbox(
                              "Third Offense",
                              filterThirdOffense,
                              (v) => setState(() => filterThirdOffense = v),
                            ),
                          ]),
                          _filterSection("Violation Type", [
                            _buildCheckbox(
                              "Improper Uniform",
                              filterImproperUniform,
                              (v) => setState(() => filterImproperUniform = v),
                            ),
                            _buildCheckbox(
                              "Late Attendance",
                              filterLateAttendance,
                              (v) => setState(() => filterLateAttendance = v),
                            ),
                            _buildCheckbox(
                              "Serious Misconduct",
                              filterSeriousMisconduct,
                              (v) =>
                                  setState(() => filterSeriousMisconduct = v),
                            ),
                          ]),
                          _filterSection("Department", [
                            _buildCheckbox(
                              "CAS",
                              filterCAS,
                              (v) => setState(() => filterCAS = v),
                            ),
                            _buildCheckbox(
                              "CBA",
                              filterCBA,
                              (v) => setState(() => filterCBA = v),
                            ),
                            _buildCheckbox(
                              "CCS",
                              filterCCS,
                              (v) => setState(() => filterCCS = v),
                            ),
                            _buildCheckbox(
                              "CTE",
                              filterCTE,
                              (v) => setState(() => filterCTE = v),
                            ),
                            _buildCheckbox(
                              "CCJE",
                              filterCCJE,
                              (v) => setState(() => filterCCJE = v),
                            ),
                          ]),

                          // 🔹 Date Range Section (new)
                          _filterSection("Date Range", [
                            ListTile(
                              title: Text(
                                startDate == null
                                    ? "Start Date"
                                    : "Start: ${startDate!.toLocal()}".split(
                                        ' ',
                                      )[0],
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => startDate = picked);
                                }
                              },
                            ),
                            ListTile(
                              title: Text(
                                endDate == null
                                    ? "End Date"
                                    : "End: ${endDate!.toLocal()}".split(
                                        ' ',
                                      )[0],
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => endDate = picked);
                                }
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              filterFirstOffense = false;
                              filterSecondOffense = false;
                              filterThirdOffense = false;
                              filterImproperUniform = false;
                              filterLateAttendance = false;
                              filterSeriousMisconduct = false;
                              filterCAS = false;
                              filterCBA = false;
                              filterCCS = false;
                              filterCTE = false;
                              filterCCJE = false;
                              startDate = null;
                              endDate = null;
                            });
                          },
                          child: const Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => setState(() => showFilters = false),
                          child: const Text(
                            "Apply",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }

  Widget _menuTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 14,
      ),
    ),
  );

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    onTap: onTap,
  );

  Widget _buildSideMenu(BuildContext context) => SizedBox(
    width: sideMenuSize,
    child: Container(
      color: Colors.blue[900],
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'images/logos.png',
              height: 80,
              color: Colors.white,
            ),
          ),
          const Text(
            "  CMU_SASO DRMS",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _menuTitle('GENERAL'),
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
          _menuItem(Icons.pie_chart, 'Summary of Reports', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SummaryReportsPage()),
            );
          }),
          const SizedBox(height: 20),
          _menuTitle('ADMINISTRATION'),
          _menuItem(Icons.person, 'User Management', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserMgt()),
            );
          }),
        ],
      ),
    ),
  );

  Widget _buildSearchAndFilterRow() => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search student name, ID, or violation...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton.icon(
        onPressed: () => setState(() => showFilters = true),
        icon: const Icon(Icons.filter_list),
        label: const Text("Filters"),
      ),
    ],
  );

  Widget _filterSection(String title, List<Widget> options) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      ...options,
      const Divider(),
    ],
  );

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) =>
      CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: (val) => onChanged(val ?? false),
      );
}
