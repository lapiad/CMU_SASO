import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/classes/Integrations.dart';
import 'package:flutter_application_1/classes/ViolationRecords.dart';
import 'package:flutter_application_1/page/IDScanner.dart';
import 'package:flutter_application_1/page/Stud_info.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SchoolGuardHome extends StatefulWidget {
  const SchoolGuardHome({super.key});

  @override
  State<SchoolGuardHome> createState() => _SchoolGuardHomeState();
}

class _SchoolGuardHomeState extends State<SchoolGuardHome> {
  List<ViolationRecord> scanData = [];
  String searchQuery = "";
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchViolations();
  }

  Future<void> _fetchViolations() async {
    setState(() => _isFetching = true);
    try {
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
            .where(
              (record) =>
                  record.department.isNotEmpty &&
                  record.department.toLowerCase() != 'n/a' &&
                  record.offenseLevel.isNotEmpty &&
                  record.offenseLevel.toLowerCase() != 'n/a',
            )
            .toList();

        setState(() {
          scanData = records;
        });
      }
    } catch (e) {
      debugPrint('Error fetching violations: $e');
    } finally {
      setState(() => _isFetching = false);
    }
  }

  List<ViolationRecord> get filteredData {
    return scanData
        .where(
          (scan) =>
              scan.studentId.contains(searchQuery) ||
              scan.studentName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a.dateTime) ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.dateTime) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchViolations,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildScannerCard(context),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_isFetching)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Colors.indigo),
                    ),
                  )
                else
                  _buildRecentScans(filteredData),
                const SizedBox(height: 16),
                _buildViewAllButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final violationsToday = scanData.where((s) {
      try {
        final recordDate = DateTime.parse(s.dateTime);
        return DateFormat('yyyy-MM-dd').format(recordDate) == todayStr;
      } catch (_) {
        return false;
      }
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'images/logos.png',
                color: Colors.white,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "CMU Safety and Security",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox(scanData.length.toString(), "Total Records"),
              Container(height: 40, width: 1, color: Colors.white38),
              _statBox(violationsToday.toString(), "Today's Incidents"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search student ID or name...",
        prefixIcon: const Icon(Icons.search, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildScannerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.badge, size: 50, color: Colors.indigo.shade600),
          const SizedBox(height: 12),
          const Text(
            "Ready to Scan ID",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            "Scan the student ID card or use manual entry.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentIDScannerApp(),
                      ),
                    );
                    if (result != null && result is ViolationRecord) {
                      if (result.department.isNotEmpty &&
                          result.department.toLowerCase() != 'n/a' &&
                          result.offenseLevel.isNotEmpty &&
                          result.offenseLevel.toLowerCase() != 'n/a') {
                        setState(() => scanData.insert(0, result));
                      }
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Scan ID"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showManualEntryDialog(context),
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Manual"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    foregroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.indigo.shade200, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ MANUAL ENTRY ------------------
  void _showManualEntryDialog(BuildContext context) {
    final TextEditingController studentNoController = TextEditingController();
    bool isLoading = false;
    Map<String, dynamic>? studentInfo;
    String? errorMessage;

    Future<void> fetchStudent(StateSetter setModalState) async {
      setModalState(() {
        isLoading = true;
        errorMessage = null;
        studentInfo = null;
      });

      final studentId = studentNoController.text.trim();
      if (studentId.isEmpty) {
        setModalState(() {
          errorMessage = "Please enter a Student ID.";
          isLoading = false;
        });
        return;
      }

      try {
        final url = Uri.parse(
          '${GlobalConfiguration().getValue("server_url")}/students/student-info/$studentId',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded != null && decoded['student'] != null) {
            setModalState(() {
              studentInfo = Map<String, dynamic>.from(decoded['student']);
            });
          } else {
            setModalState(() {
              errorMessage = "Student not found.";
            });
          }
        } else {
          setModalState(() {
            errorMessage = "Lookup failed. Status: ${response.statusCode}";
          });
        }
      } catch (e) {
        setModalState(() {
          errorMessage = "Error connecting to server.";
        });
      } finally {
        setModalState(() => isLoading = false);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Manual Student Lookup",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: studentNoController,
                        decoration: InputDecoration(
                          labelText: "Enter Student ID Number",
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: Colors.indigo,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => fetchStudent(setModalState),
                        icon: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          isLoading ? "Searching..." : "Lookup Student",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Center(
                          child: Text(
                            "🚨 $errorMessage",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else if (studentInfo != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  studentInfo!['student_name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                _buildInfoRow(
                                  Icons.person_outline,
                                  "ID:",
                                  studentInfo!['student_no'] ?? '',
                                ),
                                _buildInfoRow(
                                  Icons.business_outlined,
                                  "Dept:",
                                  studentInfo!['department'] ?? '',
                                ),
                                _buildInfoRow(
                                  Icons.school_outlined,
                                  "Course:",
                                  studentInfo!['course'] ?? '',
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text("Record Violation"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViolationScreen(
                                          studentNo: studentInfo!['student_no'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.indigo.shade400),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ------------------ RECENT SCANS ------------------
  Widget _buildRecentScans(List<ViolationRecord> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Incident Logs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No records found.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ...data.take(5).map((scan) => _scanTile(scan)),
      ],
    );
  }

  Widget _scanTile(ViolationRecord scan) {
    String formattedTime = '';
    try {
      final dateTime = DateTime.parse(scan.dateTime);
      formattedTime = DateFormat('MMM dd, hh:mm a').format(dateTime.toLocal());
    } catch (_) {
      formattedTime = scan.dateTime;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: const Icon(Icons.person_2_outlined, color: Colors.indigo),
        ),
        title: Text(
          scan.studentName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID: ${scan.studentId}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Violation: ${scan.violation}",
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              "Department: ${scan.department}",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: _offenseBadge(scan.offenseLevel, formattedTime),
      ),
    );
  }

  Widget _offenseBadge(String offense, String time) {
    final mapping = {
      "1st": ["1st Offense", Colors.green.shade600],
      "2nd": ["2nd Offense", Colors.amber.shade700],
      "3rd": ["3rd/Major", Colors.red.shade600],
    };
    final info =
        mapping[offense.toLowerCase()] ?? ["Unknown", Colors.grey.shade600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: info[1] as Color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            info[0] as String,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: _ScanHistoryModal(scanData: scanData),
            ),
          );
        },
        icon: const Icon(Icons.list_alt_outlined),
        label: const Text("View All Records"),
      ),
    );
  }
}

// ------------------ VIEW ALL MODAL ------------------
class _ScanHistoryModal extends StatelessWidget {
  final List<ViolationRecord> scanData;

  const _ScanHistoryModal({required this.scanData, super.key});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<ViolationRecord>.from(scanData)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a.dateTime) ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.dateTime) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const Text(
          "All Violation Records",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sortedData.length,
            itemBuilder: (context, index) {
              final scan = sortedData[index];
              String formattedTime = '';
              try {
                final dateTime = DateTime.parse(scan.dateTime);
                formattedTime = DateFormat(
                  'MMM dd, yyyy hh:mm a',
                ).format(dateTime.toLocal());
              } catch (_) {
                formattedTime = scan.dateTime;
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: const Icon(
                      Icons.person_2_outlined,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text(
                    scan.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${scan.studentId}"),
                      Text("Violation: ${scan.violation}"),
                      Text("Department: ${scan.department}"),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _offenseBadge(scan.offenseLevel),
                      const SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _offenseBadge(String offense) {
    final mapping = {
      "1st": ["1st Offense", Colors.green.shade600],
      "2nd": ["2nd Offense", Colors.amber.shade700],
      "3rd": ["3rd/Major", Colors.red.shade600],
    };
    final info =
        mapping[offense.toLowerCase()] ?? ["Unknown", Colors.grey.shade600];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: info[1] as Color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        info[0] as String,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- Logout Confirmation Dialog ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.logout, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to log out?\nAny unsaved scan data will be lost.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final box = GetStorage();
                        box.erase(); // clear all saved user data

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const Login()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final user = box.read('user_details') ?? {};

    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final email = user['email'] ?? 'N/A';
    final department = user['department'] ?? 'Safety and Security Office';

    // Generate initials for avatar
    final initials =
        (firstName.isNotEmpty ? firstName[0] : '') +
        (lastName.isNotEmpty ? lastName[0] : '');
    final displayInitials = initials.isNotEmpty ? initials.toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white24,
                child: Text(
                  displayInitials,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "$firstName $lastName".trim().isEmpty
                    ? "Unknown User"
                    : "$firstName $lastName".trim(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Info Fields
              _buildInfoField(
                label: "Email Address",
                value: email,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "First Name",
                value: firstName,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "Last Name",
                value: lastName,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "Department / Office",
                value: department,
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "Account Status",
                value: "Active",
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: 40),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Info Field Builder ---
  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
