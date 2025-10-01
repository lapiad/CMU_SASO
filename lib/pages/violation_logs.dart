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

class ViolationLogsPage extends StatefulWidget {
  const ViolationLogsPage({super.key});

  @override
  State<ViolationLogsPage> createState() => _ViolationLogsPageState();
}

class _ViolationLogsPageState extends State<ViolationLogsPage> {
  List<ViolationRecord> allRecords = [];
  double sideMenuSize = 0.0;
  bool showFilters = false;

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
          child: SizedBox(
            width: 300,
            height: 70,
            child: Row(
              children: [
                Icon(Icons.person, size: 30),
                SizedBox(width: 16),
                Text('Profile Settings', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'signout',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Row(
              children: [
                Icon(Icons.logout, size: 30),
                SizedBox(width: 16),
                Text("Sign Out", style: TextStyle(fontSize: 20)),
              ],
            ),
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
    ); // Replace with your IP
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allRecords = data
              .map(
                (item) => ViolationRecord(
                  studentName: item['student_name'],
                  studentId: item['student_id'],
                  violation: item['violation'],
                  status: item['status'],
                  reportStatus: item['report_status'],
                  reportedBy: item['reported_by'],
                  dateTime: item['date_time'],
                  department: item['department'],
                ),
              )
              .toList();
        });
      } else {
        print('Failed to load violations');
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

      final matchesReportStatus =
          (!filterPending && !filterUnderReview && !filterReviewed) ||
          (filterPending && record.reportStatus == 'Pending') ||
          (filterUnderReview && record.reportStatus == 'Under Review') ||
          (filterReviewed && record.reportStatus == 'Reviewed');

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

      return matchesSearch &&
          matchesStatus &&
          matchesReportStatus &&
          matchesViolationType &&
          matchesDepartment;
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
        title: const Text('Violation Logs', style: TextStyle(fontSize: 26)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 32, color: Colors.white),
          onPressed: () {
            setState(() {
              sideMenuSize = sideMenuSize == 0.0 ? 300.0 : 0.0;
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
                    fontSize: 16,
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
                size: 22,
                color: Color.fromARGB(255, 10, 44, 158),
              ),
              onPressed: () => _showAdminMenu(context),
            ),
          ),
          const SizedBox(width: 20),
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
                      SizedBox(
                        width: 1900,
                        height: 809,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: SizedBox(
                                    width: 180,
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
                                    width: 150,
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
                                    width: 150,
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
                                    width: 170,
                                    child: Text(
                                      'Report Status',
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
                                    width: 150,
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
                                    width: 150,
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
                                        record.department,
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
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
                                            icon: const Icon(
                                              Icons.remove_red_eye,
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
                                            icon: const Icon(Icons.edit),
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
                          onPressed: () {
                            setState(() {
                              showFilters = false;
                            });
                          },
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
                              (val) => setState(() => filterFirstOffense = val),
                            ),
                            _buildCheckbox(
                              "Second Offense",
                              filterSecondOffense,
                              (val) =>
                                  setState(() => filterSecondOffense = val),
                            ),
                            _buildCheckbox(
                              "Third Offense",
                              filterThirdOffense,
                              (val) => setState(() => filterThirdOffense = val),
                            ),
                          ]),
                          _filterSection("Report Status", [
                            _buildCheckbox(
                              "Pending",
                              filterPending,
                              (val) => setState(() => filterPending = val),
                            ),
                            _buildCheckbox(
                              "Under Review",
                              filterUnderReview,
                              (val) => setState(() => filterUnderReview = val),
                            ),
                            _buildCheckbox(
                              "Reviewed",
                              filterReviewed,
                              (val) => setState(() => filterReviewed = val),
                            ),
                          ]),
                          _filterSection("Violation Type", [
                            _buildCheckbox(
                              "Improper Uniform",
                              filterImproperUniform,
                              (val) =>
                                  setState(() => filterImproperUniform = val),
                            ),
                            _buildCheckbox(
                              "Late Attendance",
                              filterLateAttendance,
                              (val) =>
                                  setState(() => filterLateAttendance = val),
                            ),
                            _buildCheckbox(
                              "Serious Misconduct",
                              filterSeriousMisconduct,
                              (val) =>
                                  setState(() => filterSeriousMisconduct = val),
                            ),
                          ]),
                          _filterSection("Department", [
                            _buildCheckbox(
                              "CAS",
                              filterCAS,
                              (val) => setState(() => filterCAS = val),
                            ),
                            _buildCheckbox(
                              "CBA",
                              filterCBA,
                              (val) => setState(() => filterCBA = val),
                            ),
                            _buildCheckbox(
                              "CCS",
                              filterCCS,
                              (val) => setState(() => filterCCS = val),
                            ),
                            _buildCheckbox(
                              "CTE",
                              filterCTE,
                              (val) => setState(() => filterCTE = val),
                            ),
                            _buildCheckbox(
                              "CCJE",
                              filterCCJE,
                              (val) => setState(() => filterCCJE = val),
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
                              filterPending = false;
                              filterUnderReview = false;
                              filterReviewed = false;
                              filterImproperUniform = false;
                              filterLateAttendance = false;
                              filterSeriousMisconduct = false;
                              filterCAS = false;
                              filterCBA = false;
                              filterCCS = false;
                              filterCTE = false;
                              filterCCJE = false;
                            });
                          },
                          child: const Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showFilters = false;
                            });
                          },

                          child: const Text(
                            "Apply",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0033A0),
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

  Widget _buildSideMenu(BuildContext context) {
    return SizedBox(
      width: sideMenuSize,
      height: MediaQuery.of(context).size.height,
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _menuTitle('GENERAL'),
            _menuItem(Icons.home, 'Dashboard', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            }),
            _menuItem(Icons.list_alt, 'Violation Logs', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViolationLogsPage(),
                ),
              );
            }),
            _menuItem(Icons.pie_chart, 'Summary of Reports', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SummaryReportsPage(),
                ),
              );
            }),
            _menuItem(Icons.bookmark, 'Referred to Council', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RefferedCnl()),
              );
            }),
            const SizedBox(height: 20),
            _menuTitle('ADMINISTRATION'),
            _menuItem(Icons.person, 'User Management', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserMgt()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuTitle(String title) {
    return Padding(
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
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) {
              setState(() => searchQuery = val);
            },
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
          onPressed: () {
            setState(() {
              showFilters = true;
            });
          },
          icon: const Icon(Icons.filter_list),
          label: const Text("Filters"),
        ),
      ],
    );
  }

  Widget _filterSection(String title, List<Widget> options) {
    return Column(
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
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
