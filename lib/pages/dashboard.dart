import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/GenerateReport.dart';
import 'package:flutter_application_1/components/createviolation.dart';
import 'package:flutter_application_1/components/userManual.dart';
import 'package:flutter_application_1/components/viewPending.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/components/violationEntryWidget.dart';

double sideMenuSize = 0.0;

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context) => const AdminDashboardPage();
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> recentViolations = [];
  String? userName;
  String? role;

  Map<String, dynamic> summaryData = {
    "totalCases": "0",
    "pending": "0",
    "inProgress": "0",
    "reviewed": "0",
  };

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchViolations();
    refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchViolations();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserName() async {
    try {
      final box = GetStorage();
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['first_name'] ?? "Unknown";
          role = data['role'];
        });
      } else {
        setState(() => userName = "Unknown");
      }
    } catch (e) {
      setState(() => userName = "Unknown");
    }
  }

  Future<void> fetchViolations() async {
    try {
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/violations',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> violationsList = [];

        if (data is List) {
          violationsList = data;
        } else if (data is Map<String, dynamic> &&
            data.containsKey('violations')) {
          violationsList = data['violations'] as List<dynamic>;
        }

        violationsList.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
          final dateB =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        setState(() {
          recentViolations = violationsList;
        });
        computeSummary();
      }
    } catch (e) {
      print("Error fetching violations: $e");
      setState(() {
        recentViolations = [];
        computeSummary();
      });
    }
  }

  void computeSummary() {
    int total = recentViolations.length;
    int pending = 0;
    int inProgress = 0;
    int reviewed = 0;

    for (var v in recentViolations) {
      String status = (v['status'] ?? '').toString().toLowerCase();
      if (status == 'pending') {
        pending++;
      } else if (status == 'in-progress' || status == 'under review')
        inProgress++;
      else if (status == 'reviewed' || status == 'referred')
        reviewed++;
    }

    setState(() {
      summaryData = {
        "totalCases": total.toString(),
        "pending": pending.toString(),
        "inProgress": inProgress.toString(),
        "reviewed": reviewed.toString(),
      };
    });
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: [
        _popupItem(Icons.person, 'Profile Settings', 'profile'),
        _popupItem(Icons.logout, 'Sign Out', 'signout'),
      ],
    );

    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
      );
    } else if (result == 'signout') {
      final box = GetStorage();
      box.erase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    }
  }

  PopupMenuItem<String> _popupItem(IconData icon, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 26, color: const Color(0xFF446EAD)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 5,
          backgroundColor: const Color(0xFF446EAD).withOpacity(0.9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Color getOffenseColor(String offenseLevel) {
    final level = offenseLevel.trim().toLowerCase();
    if (level.contains('first')) return Colors.amber;
    if (level.contains('second')) return Colors.orangeAccent;
    if (level.contains('third')) return Colors.redAccent;
    if (level.contains('pending')) return Colors.blueGrey;
    if (level.contains('none')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'CMU-SASO DASHBOARD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 8,
        shadowColor: Colors.black26,
        backgroundColor: const Color(0xFF446EAD),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 36, color: Colors.white),
          onPressed: () {
            setState(() => sideMenuSize = sideMenuSize == 0.0 ? 320.0 : 0.0);
          },
        ),
        actions: [
          // 🔔 Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => PendingReportsDialog(),
                  );
                  fetchViolations();
                },
              ),
              if (int.tryParse(summaryData["pending"] ?? "0") != null &&
                  int.parse(summaryData["pending"] ?? "0") > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    child: Text(
                      summaryData["pending"] ?? "0",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // 🆕 User Manual Button (navigate to new screen)
          IconButton(
            icon: const Icon(Icons.help_outline, size: 32, color: Colors.white),
            tooltip: 'User Manual',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserManualScreen()),
              );
            },
          ),

          // 👤 User Info
          Row(
            children: [
              Text(
                userName ?? "Loading...",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _showAdminMenu(context),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF446EAD)),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf7faff), Color(0xFFdce6ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sideMenuSize != 0.0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: sideMenuSize,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF446EAD), Color(0xFF5F8EDC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _buildSideMenu(context),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSummarySection(context),
                      const SizedBox(height: 24),
                      _buildBottomSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== SIDE MENU =====================
  Widget _buildSideMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Center(
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Image.asset(
              'images/logos.png',
              height: 70,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            "CMU_SASO DRMS",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const Divider(color: Colors.white54, indent: 16, endIndent: 16),
        _menuHeader("GENERAL"),
        _menuItem(Icons.home, "Dashboard", () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
          );
        }),
        _menuItem(Icons.list_alt, "Violation Logs", () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ViolationLogsPage()),
          );
        }),
        _menuItem(Icons.pie_chart, "Summary of Reports", () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SummaryReportsPage()),
          );
        }),
        const Divider(color: Colors.white54, indent: 16, endIndent: 16),
        if (role == 'admin') ...[
          _menuHeader("ADMINISTRATION"),
          _menuItem(Icons.person, "User Management", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserMgt()),
            );
          }),
        ],
      ],
    );
  }

  Widget _menuHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: Colors.white, size: 26),
    title: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    hoverColor: Colors.white10,
    onTap: onTap,
  );

  // ===================== SUMMARY SECTION =====================
  Widget _buildSummarySection(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ViolationLogsPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: MediaQuery.of(context).size.width > 770
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SummaryWidget(
                      title: "Total Cases",
                      value: summaryData["totalCases"] ?? "0",
                      subtitle: "All Recorded Cases",
                      icon: Icons.cases_outlined,
                      iconColor: Colors.indigo,
                    ),
                    SummaryWidget(
                      title: "Pending",
                      value: summaryData["pending"] ?? "0",
                      subtitle: "Awaiting Action",
                      icon: Icons.hourglass_bottom,
                      iconColor: Colors.orange,
                    ),
                    SummaryWidget(
                      title: "In Progress",
                      value: summaryData["inProgress"] ?? "0",
                      subtitle: "Currently Handled",
                      icon: Icons.autorenew,
                      iconColor: Colors.blueAccent,
                    ),
                    SummaryWidget(
                      title: "Reviewed",
                      value: summaryData["reviewed"] ?? "0",
                      subtitle: "Completed Cases",
                      icon: Icons.verified,
                      iconColor: Colors.green,
                    ),
                  ],
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SummaryWidget(
                      title: "Total Cases",
                      value: summaryData["totalCases"] ?? "0",
                      subtitle: "All Recorded Cases",
                      icon: Icons.cases_outlined,
                      iconColor: Colors.indigo,
                    ),
                    SummaryWidget(
                      title: "Pending",
                      value: summaryData["pending"] ?? "0",
                      subtitle: "Awaiting Action",
                      icon: Icons.hourglass_bottom,
                      iconColor: Colors.orange,
                    ),
                    SummaryWidget(
                      title: "In Progress",
                      value: summaryData["inProgress"] ?? "0",
                      subtitle: "Currently Handled",
                      icon: Icons.autorenew,
                      iconColor: Colors.blueAccent,
                    ),
                    SummaryWidget(
                      title: "Reviewed",
                      value: summaryData["reviewed"] ?? "0",
                      subtitle: "Completed Cases",
                      icon: Icons.verified,
                      iconColor: Colors.green,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ===================== BOTTOM SECTION =====================
  Widget _buildBottomSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _frostedCard(
            title: 'Recent Violations',
            child: recentViolations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      "No recent violations",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await fetchViolations();
                    },
                    child: Column(
                      children: recentViolations.take(3).map((v) {
                        return ViolationEntry(
                          name: v['student_name'] ?? "",
                          violationtype: v['violation_type'] ?? "",
                          offenselevel: v['offense_level'] ?? "Unknown",
                          offenseColor: getOffenseColor(
                            v['offense_level'] ??
                                v['violation_type'] ??
                                "Unknown",
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _frostedCard(
            title: 'Quick Actions',
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: buildActionButton(
                    Icons.add,
                    "Create New Violation Report",
                    () async {
                      await showDialog(
                        context: context,
                        builder: (_) => CreateViolationDialog(),
                      );
                      fetchViolations();
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: buildActionButton(
                    Icons.pending_actions,
                    "View Pending Reports",
                    () async {
                      await showDialog(
                        context: context,
                        builder: (_) => PendingReportsDialog(),
                      );
                      fetchViolations();
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: buildActionButton(
                    Icons.bar_chart,
                    "Generate Report",
                    () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ReportDialog(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===================== CARD WRAPPER =====================
  Widget _frostedCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF446EAD),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
