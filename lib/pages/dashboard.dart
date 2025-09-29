import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/GenerateReport.dart';
import 'package:flutter_application_1/components/createviolation.dart';
import 'package:flutter_application_1/components/viewPending.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/components/violationEntryWidget.dart';

Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  ); // Replace with your FastAPI URL
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['first_name'];
  } else {
    // error message
    return "null";
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardPage();
  }
}

double sideMenuSize = 0.0;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
          value: 'system',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Row(
              children: [
                Icon(Icons.settings, size: 30),
                SizedBox(width: 16),
                Text('System Settings', style: TextStyle(fontSize: 20)),
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

  final List<ViolationRecords> allRecords = [
    ViolationRecords(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Under Review',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecords(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Referred',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
    ViolationRecords(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Pending',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecords(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Reviewed',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
  ];

  Widget buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
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

  int countByStatus(String statusMatch) {
    return cases
        .where((c) => (c['status'] as String).contains(statusMatch))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CMU-SASO DASHBOARD',
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
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Row(
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
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: MediaQuery.of(context).size.width > 770
                        ? Row(
                            children: [
                              SizedBox(width: 40),
                              SummaryWidget(
                                title: "Total Cases",
                                value: "3",
                                subtitle: "Active Referrals",
                                icon: Icons.cases_outlined,
                                iconColor: Colors.red,
                              ),
                              SizedBox(width: 30),
                              SummaryWidget(
                                title: "Under Review",
                                value: "1",
                                subtitle: "Being Evaluated",
                                icon: Icons.reviews,
                                iconColor: Colors.blue,
                              ),
                              SizedBox(width: 30),
                              SummaryWidget(
                                title: "Scheduled",
                                value: "1",
                                subtitle: "Hearings Set",
                                icon: Icons.schedule,
                                iconColor: Colors.teal,
                              ),
                              SizedBox(width: 30),
                              SummaryWidget(
                                title: "Pending",
                                value: "1",
                                subtitle: "Awaiting Decision",
                                icon: Icons.pending,
                                iconColor: Colors.yellow,
                              ),
                              SizedBox(width: 30),
                            ],
                          )
                        : Container(
                            margin: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
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
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Recent Violations',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              SizedBox(height: 20),
                              ViolationEntry(
                                name: 'Annie Batumbakal',
                                description: 'Improper Uniform',
                                offenseType: 'First Offense',
                                offenseColor: Colors.amber,
                              ),
                              ViolationEntry(
                                name: 'Juan Dela Cruz',
                                description: 'Late Attendance',
                                offenseType: 'Second Offense',
                                offenseColor: Colors.deepOrange,
                              ),
                              ViolationEntry(
                                name: 'James Reid',
                                description: 'Serious Misconduct',
                                offenseType: 'Third Offense',
                                offenseColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                  () {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const CreateViolationDialog(),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: buildActionButton(
                                  Icons.article_outlined,
                                  " View Pending Reports",
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

class ViolationRecords {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String? priority;
  final String? referredDate;
  final String? hearingDate;

  ViolationRecords({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
    this.priority,
    this.referredDate,
    this.hearingDate,
  });
}
