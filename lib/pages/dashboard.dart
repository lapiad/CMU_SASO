import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/GenerateReport.dart';
import 'package:flutter_application_1/components/createviolation.dart';
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
  Widget build(BuildContext context) {
    return const AdminDashboardPage();
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> recentViolations = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchRecentViolations();
  }

  // Fetch logged-in user name
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
        });
      } else {
        setState(() {
          userName = "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Unknown";
      });
    }
  }

  // Fetch recent violations from backend
  Future<void> fetchRecentViolations() async {
    try {
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/violations/recent',
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

        setState(() {
          recentViolations = violationsList;
        });
      } else {
        setState(() {
          recentViolations = [];
        });
      }
    } catch (e) {
      print("Error fetching violations: $e");
      setState(() {
        recentViolations = [];
      });
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
        const PopupMenuItem(
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
        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
      );
    }

    if (result == 'signout') {
      final box = GetStorage();
      box.erase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
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
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.black,
          alignment: Alignment.center,
        ),
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
      ),
    );
  }

  Color getOffenseColor(String offenseLevel) {
    // Normalize input (handle nulls, case differences, spacing)
    final level = offenseLevel.trim().toLowerCase();

    if (level.contains('first')) {
      return Colors.amber; // 🟡 First Offense
    } else if (level.contains('second')) {
      return Colors.deepOrange; // 🟠 Second Offense
    } else if (level.contains('third')) {
      return Colors.red; // 🔴 Third Offense
    } else if (level.contains('pending')) {
      return Colors.blueGrey; // ⚪ Optional: Pending
    } else if (level.contains('none')) {
      return Colors.green; // ✅ Clean record (optional)
    } else {
      return Colors.grey; // ⚫ Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CMU-SASO DASHBOARD',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 110, 173),
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
              Text(
                userName ?? "Loading...",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 253, 250, 250),
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 25,
                    color: Color.fromARGB(255, 68, 110, 173),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side menu
            if (sideMenuSize != 0.0)
              SizedBox(
                width: sideMenuSize,
                height: MediaQuery.of(context).size.height,
                child: Container(
                  color: const Color.fromARGB(255, 68, 110, 173),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          'images/logos.png',
                          height: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "CMU_SASO DRMS",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Divider(color: Colors.white),
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
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(),
                          ),
                        ),
                      ),
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
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViolationLogsPage(),
                          ),
                        ),
                      ),
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
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummaryReportsPage(),
                          ),
                        ),
                      ),

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
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => UserMgt()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Summary widgets
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: MediaQuery.of(context).size.width > 770
                        ? Row(
                            children: [
                              const SizedBox(width: 40),
                              SummaryWidget(
                                title: "Total Cases",
                                value: "3",
                                subtitle: "Active Referrals",
                                icon: Icons.cases_outlined,
                                iconColor: Colors.red,
                              ),
                              SummaryWidget(
                                title: "Under Review",
                                value: "1",
                                subtitle: "Being Evaluated",
                                icon: Icons.reviews,
                                iconColor: Colors.blue,
                              ),
                              SummaryWidget(
                                title: "Scheduled",
                                value: "1",
                                subtitle: "Hearings Set",
                                icon: Icons.schedule,
                                iconColor: Colors.teal,
                              ),
                              SummaryWidget(
                                title: "Pending",
                                value: "1",
                                subtitle: "Awaiting Decision",
                                icon: Icons.pending,
                                iconColor: Colors.yellow,
                              ),
                            ],
                          )
                        : Container(
                            margin: const EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: GridView.count(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              children: [
                                SummaryWidget(
                                  title: "Total Cases",
                                  value: "3",
                                  subtitle: "Active Referrals",
                                  icon: Icons.cases_outlined,
                                  iconColor: Colors.red,
                                ),
                                SummaryWidget(
                                  title: "Under Review",
                                  value: "1",
                                  subtitle: "Being Evaluated",
                                  icon: Icons.reviews,
                                  iconColor: Colors.blue,
                                ),
                                SummaryWidget(
                                  title: "Scheduled",
                                  value: "1",
                                  subtitle: "Hearings Set",
                                  icon: Icons.schedule,
                                  iconColor: Colors.teal,
                                ),
                                SummaryWidget(
                                  title: "Pending",
                                  value: "1",
                                  subtitle: "Awaiting Decision",
                                  icon: Icons.pending,
                                  iconColor: Colors.yellow,
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Violations
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Violations',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 20),
                              recentViolations.isEmpty
                                  ? const Text("No recent violations")
                                  : Column(
                                      children: recentViolations.map((
                                        violation,
                                      ) {
                                        return ViolationEntry(
                                          name: violation['student_name'] ?? "",
                                          violationtype:
                                              violation['violation_type'] ?? "",
                                          offenselevel:
                                              violation['offense_level'] ??
                                              "Unknown",
                                          offenseColor: getOffenseColor(
                                            violation['offense_level'] ??
                                                violation['violation_type'] ??
                                                "Unknown",
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Quick Actions
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Quick Actions",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                      builder: (_) =>
                                          const CreateViolationDialog(),
                                    );
                                    fetchRecentViolations(); // Refresh after creating
                                  },
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: buildActionButton(
                                  Icons.article_outlined,
                                  "View Pending Reports",
                                  () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => PendingReportsDialog(),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: buildActionButton(
                                  Icons.bar_chart,
                                  "Generate Weekly Report",
                                  () {
                                    showDialog(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
