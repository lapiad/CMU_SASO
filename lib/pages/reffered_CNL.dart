import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RefferedCnl extends StatefulWidget {
  final bool isEditable;
  const RefferedCnl({super.key, this.isEditable = false});

  @override
  State<RefferedCnl> createState() => _RefferedCnlState();
}

class _RefferedCnlState extends State<RefferedCnl> {
  List<ViolationRecords> allRecord = [];
  double sideMenuSize = 0.0;
  bool showFilters = false;
  String searchQuery = "";

  // filter states
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

  @override
  void initState() {
    super.initState();
    fetchViolations();
  }

  Future<void> fetchViolations() async {
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/violations',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allRecord = data
              .map(
                (item) => ViolationRecords(
                  studentName: item['student_name'],
                  studentId: item['student_id'],
                  department: item['department'],
                  violation: item['violation'],
                  status: item['status'],
                  reportedBy: item['reported_by'],
                  dateTime: item['date_time'],
                  priority: item['priority'],
                  hearingDate: item['hearing_Date'],
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

  Future<String> getName() async {
    final box = GetStorage();
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['first_name'] ?? "Unknown";
    } else {
      return "Guest";
    }
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: const [
        PopupMenuItem(
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  List<ViolationRecords> get filteredRecords {
    return allRecord.where((record) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          record.studentName.toLowerCase().contains(query) ||
          record.studentId.toLowerCase().contains(query) ||
          record.violation.toLowerCase().contains(query);

      final matchesPriority =
          (!filterFirstOffense &&
              !filterSecondOffense &&
              !filterThirdOffense) ||
          (filterFirstOffense && record.priority == 'First Offense') ||
          (filterSecondOffense && record.priority == 'Second Offense') ||
          (filterThirdOffense && record.priority == 'Third Offense');

      final matchesStatus =
          (!filterPending && !filterUnderReview && !filterReviewed) ||
          (filterPending && record.status == 'Pending') ||
          (filterUnderReview && record.status == 'Under Review') ||
          (filterReviewed && record.status == 'Reviewed');

      final matchesViolation =
          (!filterImproperUniform &&
              !filterLateAttendance &&
              !filterSeriousMisconduct) ||
          (filterImproperUniform && record.violation == 'Improper Uniform') ||
          (filterLateAttendance && record.violation == 'Late Attendance') ||
          (filterSeriousMisconduct && record.violation == 'Serious Misconduct');

      final matchesdepartment =
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
          matchesPriority &&
          matchesStatus &&
          matchesViolation &&
          matchesdepartment;
    }).toList();
  }

  int countByStatus(String statusMatch) {
    return filteredRecords.where((c) => c.status == statusMatch).length;
  }

  Color getActionStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.yellow;
      case 'Reviewed':
        return Colors.green;
      case 'Referred':
        return Colors.red;
      case 'Under Review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String priority) {
    switch (priority.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Referred To Council',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 40, color: Colors.white),
          onPressed: () {
            setState(() {
              sideMenuSize = sideMenuSize == 0.0 ? 350.0 : 0.0;
            });
          },
        ),
        actions: [
          Row(
            children: [
              FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? snapshot.data! : "Loading...",
                    style: const TextStyle(
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
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sideMenuSize != 0.0) _buildSideMenu(context),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSummaryRow(),
                      const SizedBox(height: 24),
                      _buildSearchAndFilter(),
                      const SizedBox(height: 14),
                      Expanded(child: _buildDataTable()),
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
                            fontSize: 20,
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
                          _plainFilterSection("Priority", [
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
                          _plainFilterSection("Report Status", [
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
                          _plainFilterSection("Violation Type", [
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
                          _plainFilterSection("department", [
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
                          child: const Text("Clear"),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showFilters = false;
                            });
                          },
                          child: const Text("Apply"),
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
      child: Container(
        color: Colors.blue[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('images/logos.png', color: Colors.white),
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
            _buildMenuItem(
              context,
              icon: Icons.home,
              label: 'Dashboard',
              page: const Dashboard(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.list_alt,
              label: 'Violation Logs',
              page: const ViolationLogsPage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.pie_chart,
              label: 'Summary of Reports',
              page: const SummaryReportsPage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.bookmark,
              label: 'Referred to Council',
              page: const RefferedCnl(),
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
            _buildMenuItem(
              context,
              icon: Icons.person,
              label: 'User Management',
              page: UserMgt(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        SummaryWidget(
          title: "Total Cases",
          value: allRecord.length.toString(),
          subtitle: "Active Referrals",
          icon: Icons.cases_outlined,
          iconColor: Colors.blue,
        ),
        const SizedBox(width: 20),
        SummaryWidget(
          title: "Under Review",
          value: countByStatus("Under Review").toString(),
          subtitle: "Being Evaluated",
          icon: Icons.reviews,
          iconColor: Colors.green,
        ),
        const SizedBox(width: 20),
        SummaryWidget(
          title: "Reviewed",
          value: countByStatus("Reviewed").toString(),
          subtitle: "Finalized Cases",
          icon: Icons.check_circle_outline,
          iconColor: Colors.purple,
        ),
        const SizedBox(width: 20),
        SummaryWidget(
          title: "Pending",
          value: countByStatus("Pending").toString(),
          subtitle: "Awaiting Decision",
          icon: Icons.pending,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by student name, ID, or violation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
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

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: 1900,
        height: 809,
        child: DataTable(
          columns: [
            DataColumn(
              label: SizedBox(
                width: 175,
                child: Text(
                  'Student Name',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Student ID',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Department',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Violation',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Priority',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  'Reported By',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 160,
                child: Text(
                  'Hearing Date',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
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
                  Text(record.studentId, style: const TextStyle(fontSize: 20)),
                ),
                DataCell(
                  Text(record.department, style: const TextStyle(fontSize: 20)),
                ),
                DataCell(
                  Text(record.violation, style: const TextStyle(fontSize: 20)),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: getStatusColor(record.priority ?? ''),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      record.priority ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: getActionStatusColor(record.status),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      record.status,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                DataCell(
                  Text(record.reportedBy, style: const TextStyle(fontSize: 20)),
                ),
                DataCell(
                  Text(
                    record.hearingDate ?? '-',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Refferedview(
                                record: record,
                                isEditable: false,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Refferedview(
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
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _plainFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
        const Divider(),
      ],
    );
  }
}

class Refferedview extends StatefulWidget {
  final ViolationRecords record;
  final bool isEditable;

  const Refferedview({
    super.key,
    required this.record,
    this.isEditable = false,
  });

  @override
  State<Refferedview> createState() => _RefferedviewState();
}

class _RefferedviewState extends State<Refferedview> {
  late TextEditingController nameController;
  late TextEditingController studentIdController;
  late TextEditingController violationController;
  late TextEditingController departmentController;
  late TextEditingController reportedByController;
  late TextEditingController statusController;
  late TextEditingController priorityController;
  late TextEditingController hearingDateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.record.studentName);
    studentIdController = TextEditingController(text: widget.record.studentId);
    violationController = TextEditingController(text: widget.record.violation);
    departmentController = TextEditingController(
      text: widget.record.department,
    );
    reportedByController = TextEditingController(
      text: widget.record.reportedBy,
    );
    statusController = TextEditingController(text: widget.record.status);
    priorityController = TextEditingController(
      text: widget.record.priority ?? "",
    );
    hearingDateController = TextEditingController(
      text: widget.record.hearingDate ?? "",
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    violationController.dispose();
    departmentController.dispose();
    reportedByController.dispose();
    statusController.dispose();
    priorityController.dispose();
    hearingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0033A0),
        leading: const Icon(Icons.person, color: Colors.white),
        title: Text(
          widget.isEditable ? "Edit Case Details" : "Case Details",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image placeholder
            Container(
              width: isWide ? 220 : 160,
              height: isWide ? 220 : 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                size: isWide ? 100 : 70,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 32),

            // Right: Two-column details
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildDetailField("Student Name", nameController),
                          buildDetailField(
                            "Student Number",
                            studentIdController,
                          ),
                          buildDetailField("Violation", violationController),
                          buildDetailField("department", departmentController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          buildDetailField("Reported By", reportedByController),
                          buildDetailField("Status", statusController),
                          buildDetailField("Priority", priorityController),
                          buildDetailField(
                            "Hearing Date",
                            hearingDateController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Save/Cancel buttons (only when editable)
      bottomNavigationBar: widget.isEditable
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "studentName": nameController.text,
                        "studentId": studentIdController.text,
                        "violation": violationController.text,
                        "department": departmentController.text,
                        "reportedBy": reportedByController.text,
                        "status": statusController.text,
                        "priority": priorityController.text,
                        "hearingDate": hearingDateController.text,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget buildDetailField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          widget.isEditable
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    controller.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
        ],
      ),
    );
  }
}

class ViolationRecords {
  final String studentName;
  final String studentId;
  final String department;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String? priority;
  final String? hearingDate;

  ViolationRecords({
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
    this.priority,
    this.hearingDate,
  });
}
