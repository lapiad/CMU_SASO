import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/Integrations.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:flutter_application_1/components/violationView.dart';
import 'package:flutter_application_1/components/violationedit.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ViolationLogsPage extends StatefulWidget {
  const ViolationLogsPage({super.key});

  @override
  State<ViolationLogsPage> createState() => _ViolationLogsPageState();
}

class _ViolationLogsPageState extends State<ViolationLogsPage> {
  ValueNotifier<List<ViolationRecord>> allRecordsNotifier = ValueNotifier([]);
  double sideMenuSize = 0.0;
  bool showFilters = false;

  DateTime? startDate;
  DateTime? endDate;

  // Filter states
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

  bool filterPending = false;
  bool filterUnderReview = false;
  bool filterReviewed = false;

  String searchQuery = "";

  DateTime? lastUpdated;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchViolations();

    // Automatically refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchViolations();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchViolations() async {
    final data = await Integration().fetchViolations();
    if (data != null) {
      final records = data
          .map(
            (item) => ViolationRecord(
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

      // Sort oldest → latest
      records.sort(
        (a, b) =>
            DateTime.parse(a.dateTime).compareTo(DateTime.parse(b.dateTime)),
      );

      allRecordsNotifier.value = records;
      setState(() => lastUpdated = DateTime.now());
    }
  }

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

  String formatDateTime(String dateTimeStr) {
    try {
      final date = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy  h:mm a').format(date);
    } catch (e) {
      return dateTimeStr;
    }
  }

  List<ViolationRecord> get filteredRecords {
    return allRecordsNotifier.value.where((record) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          record.studentName.toLowerCase().contains(query) ||
          record.studentId.toLowerCase().contains(query) ||
          record.violation.toLowerCase().contains(query);

      final matchesOffense =
          (!filterFirstOffense &&
              !filterSecondOffense &&
              !filterThirdOffense) ||
          (filterFirstOffense && record.offenseLevel == 'First Offense') ||
          (filterSecondOffense && record.offenseLevel == 'Second Offense') ||
          (filterThirdOffense && record.offenseLevel == 'Third Offense');

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

      final matchesStatus =
          (!filterPending && !filterUnderReview && !filterReviewed) ||
          (filterPending && record.status == 'Pending') ||
          (filterUnderReview && record.status == 'Under Review') ||
          (filterReviewed && record.status == 'Reviewed');

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
          matchesOffense &&
          matchesViolationType &&
          matchesDepartment &&
          matchesStatus &&
          matchesDate;
    }).toList();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellowAccent;
      case 'in progress':
        return const Color.fromARGB(255, 66, 184, 66);
      case 'reviewed':
        return Colors.orange;
      case 'referred':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getOffenseColor(String status) {
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

  void _clearFilters() {
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
      filterPending = false;
      filterUnderReview = false;
      filterReviewed = false;
      startDate = null;
      endDate = null;
    });
  }

  void _applyFilters() {
    setState(() {
      showFilters = false;
    });
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
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              );
            },
          ),
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
                      if (lastUpdated != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Text(
                            'Last updated: ${DateFormat('hh:mm:ss a').format(lastUpdated!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Expanded(child: _buildDataTable()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showFilters)
            GestureDetector(
              onTap: () => setState(() => showFilters = false),
              child: AnimatedOpacity(
                opacity: showFilters ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(color: Colors.black),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: showFilters ? 0 : -320,
            top: 0,
            bottom: 0,
            width: 300,
            child: _buildFilterDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
      ),
    );
  }

  // ------------------ FILTER DRAWER -------------------
  Widget _buildFilterDrawer() {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => showFilters = false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFilterSection("Priority", [
              _buildCheckbox(
                "First Offense",
                filterFirstOffense,
                (val) => setState(() => filterFirstOffense = val!),
              ),
              _buildCheckbox(
                "Second Offense",
                filterSecondOffense,
                (val) => setState(() => filterSecondOffense = val!),
              ),
              _buildCheckbox(
                "Third Offense",
                filterThirdOffense,
                (val) => setState(() => filterThirdOffense = val!),
              ),
            ]),
            const Divider(),
            _buildFilterSection("Report Status", [
              _buildCheckbox(
                "Pending",
                filterPending,
                (val) => setState(() => filterPending = val!),
              ),
              _buildCheckbox(
                "Under Review",
                filterUnderReview,
                (val) => setState(() => filterUnderReview = val!),
              ),
              _buildCheckbox(
                "Reviewed",
                filterReviewed,
                (val) => setState(() => filterReviewed = val!),
              ),
            ]),
            const Divider(),
            _buildFilterSection("Violation Type", [
              _buildCheckbox(
                "Improper Uniform",
                filterImproperUniform,
                (val) => setState(() => filterImproperUniform = val!),
              ),
              _buildCheckbox(
                "Late Attendance",
                filterLateAttendance,
                (val) => setState(() => filterLateAttendance = val!),
              ),
              _buildCheckbox(
                "Serious Misconduct",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
            ]),
            const Divider(),
            _buildFilterSection("Department", [
              _buildCheckbox(
                "CAS",
                filterCAS,
                (val) => setState(() => filterCAS = val!),
              ),
              _buildCheckbox(
                "CBA",
                filterCBA,
                (val) => setState(() => filterCBA = val!),
              ),
              _buildCheckbox(
                "CCS",
                filterCCS,
                (val) => setState(() => filterCCS = val!),
              ),
              _buildCheckbox(
                "CTE",
                filterCTE,
                (val) => setState(() => filterCTE = val!),
              ),
              _buildCheckbox(
                "CCJE",
                filterCCJE,
                (val) => setState(() => filterCCJE = val!),
              ),
            ]),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }

  // ------------------- SIDE MENU ---------------------
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

  // ------------------- DATA TABLE -------------------
  Widget _buildDataTable() {
    return ValueListenableBuilder<List<ViolationRecord>>(
      valueListenable: allRecordsNotifier,
      builder: (context, records, _) {
        final filtered = filteredRecords;
        return SingleChildScrollView(
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
                  width: 190,
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
            rows: filtered.map((record) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      record.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      record.studentId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      record.department,
                      style: const TextStyle(
                        fontSize: 16,
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
                        color: getOffenseColor(record.offenseLevel),
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
                      style: const TextStyle(fontSize: 21),
                    ),
                  ),
                  DataCell(
                    Text(
                      formatDateTime(record.dateTime),
                      style: const TextStyle(
                        fontSize: 16,
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
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ViolationFormPage(record: record),
                              ),
                            );
                            _fetchViolations();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditableViolationFormPage(record: record),
                              ),
                            );
                            _fetchViolations();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
