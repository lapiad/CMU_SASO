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

class _ViolationLogsPageState extends State<ViolationLogsPage>
    with SingleTickerProviderStateMixin {
  ValueNotifier<List<ViolationRecord>> allRecordsNotifier = ValueNotifier([]);
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
  bool filterPending = false;
  bool filterUnderReview = false;
  bool filterReviewed = false;

  String searchQuery = "";

  DateTime? lastUpdated;
  Timer? _refreshTimer;

  late AnimationController _drawerController;

  @override
  void initState() {
    super.initState();
    _fetchViolations();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchViolations();
    });

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _drawerController.dispose();
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
        return Colors.orange.shade200;
      case 'in progress':
        return const Color.fromARGB(255, 66, 184, 66).withOpacity(0.18);
      case 'reviewed':
        return Colors.lightBlue.shade100;
      case 'referred':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getOffenseColor(String status) {
    switch (status.toLowerCase()) {
      case 'first offense':
        return Colors.yellow.shade200;
      case 'second offense':
        return Colors.orange.shade200;
      case 'third offense':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
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
      _drawerController.reverse();
    });
  }

  void _toggleSideMenu() {
    setState(() {
      sideMenuSize = sideMenuSize == 0.0 ? 300.0 : 0.0;
    });
  }

  void _toggleFilters() {
    setState(() {
      showFilters = !showFilters;
      if (showFilters) {
        _drawerController.forward();
      } else {
        _drawerController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // theme colors
    final accent = const Color(0xFF446EAD);
    final softBg = const Color(0xFFF6F9FF);

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'Violation Logs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: accent,
        elevation: 6,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 32, color: Colors.white),
          onPressed: _toggleSideMenu,
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
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(right: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.person,
                        size: 22,
                        color: Color(0xFF446EAD),
                      ),
                      onPressed: () {},
                    ),
                  ),
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
              // Side menu (animated width)
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                width: sideMenuSize,
                height: MediaQuery.of(context).size.height,
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(3, 0),
                    ),
                  ],
                ),
                child: sideMenuSize > 0
                    ? _buildSideMenu(context)
                    : const SizedBox.shrink(),
              ),

              // Main area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _buildSearchAndFilterRow(accent),
                      if (lastUpdated != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Text(
                            'Last updated: ${DateFormat('hh:mm:ss a').format(lastUpdated!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Expanded(child: _buildTableCard(accent)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Backdrop when filters open
          if (showFilters)
            GestureDetector(
              onTap: _toggleFilters,
              child: AnimatedOpacity(
                opacity: showFilters ? 0.45 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),

          // Filter drawer (right)
          Align(
            alignment: Alignment.centerRight,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _drawerController,
                curve: Curves.easeInOut,
              ),
              axisAlignment: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: showFilters ? 320 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: _buildFilterDrawer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 22),
                  hintText: 'Search student name, ID, or violation...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _toggleFilters,
            icon: const Icon(Icons.filter_list),
            label: const Text("Filters"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: accent,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDrawer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: SingleChildScrollView(
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
                  onPressed: () => _toggleFilters(),
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
                "In Progress",
                filterUnderReview,
                (val) => setState(() => filterUnderReview = val!),
              ),
              _buildCheckbox(
                "Reviewed",
                filterReviewed,
                (val) => setState(() => filterReviewed = val!),
              ),
              // keep original behavior (Referred maps to Reviewed toggle in original) - preserved
              _buildCheckbox(
                "Referred",
                filterReviewed,
                (val) => setState(() => filterReviewed = val!),
              ),
            ]),
            const Divider(),
            _buildFilterSection("Violation Type", [
              _buildCheckbox(
                "Dress Code",
                filterImproperUniform,
                (val) => setState(() => filterImproperUniform = val!),
              ),
              _buildCheckbox(
                "Behavioral Misconduct",
                filterLateAttendance,
                (val) => setState(() => filterLateAttendance = val!),
              ),
              _buildCheckbox(
                "Unauthorized Entry of Outsider",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Bringing Deadly Weapons",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Cheating exam",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Vandalism",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "NO ID",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Not Using Lanyard of CMU",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Vape",
                filterSeriousMisconduct,
                (val) => setState(() => filterSeriousMisconduct = val!),
              ),
              _buildCheckbox(
                "Bullying",
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    "Clear",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF446EAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
      activeColor: const Color(0xFF446EAD),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withOpacity(0.12),
              child: Image.asset(
                'images/logos.png',
                color: Colors.white,
                height: 60,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "CMU_SASO DRMS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const Text(
            'GENERAL',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
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
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'ADMINISTRATION',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
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
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  Widget _buildTableCard(Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: ValueListenableBuilder<List<ViolationRecord>>(
        valueListenable: allRecordsNotifier,
        builder: (context, records, _) {
          final filtered = filteredRecords;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 56,
                dataRowHeight: 68,
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 190,
                      child: Text(
                        'Student Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text(
                        'Student ID',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Department',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 180,
                      child: Text(
                        'Violation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 160,
                      child: Text(
                        'Offense Level',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        'Reported By',
                        style: TextStyle(
                          fontSize: 18,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          record.studentId,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          record.department,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      DataCell(
                        Text(
                          record.violation,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(record.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record.status,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getOffenseColor(record.offenseLevel),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record.offenseLevel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          record.reportedBy,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      DataCell(
                        Text(
                          formatDateTime(record.dateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            _actionIconButton(
                              Icons.remove_red_eye,
                              Colors.blue,
                              () async {
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
                            const SizedBox(width: 6),
                            _actionIconButton(
                              Icons.edit,
                              Colors.green,
                              () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditableViolationFormPage(
                                      record: record,
                                    ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _actionIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}
