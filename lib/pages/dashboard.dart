import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.dart';
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
    print(data['first_name']);
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
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('Profile Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        PopupMenuItem(
          value: 'system',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('System Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        PopupMenuItem(
          child: const Text("Sign Out", style: TextStyle(fontSize: 20)),
          onTap: () {
            final box = GetStorage();
            box.remove('user_id');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ],
    );

    if (result == 'signout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  final List<ViolationRecord> allRecords = [
    ViolationRecord(
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
    ViolationRecord(
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
    ViolationRecord(
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
    ViolationRecord(
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
          alignment: Alignment.centerLeft,
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
        ],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: SizedBox(
        width: 150,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            // Add new user logic here
          },
          backgroundColor: Colors.blue[900],
          tooltip: 'Add New User',
          child: const Text(
            'Add User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
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
                          Navigator.push(
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
                  Row(
                    children: [
                      const SizedBox(width: 10.0),
                      SummaryWidget(
                        title: "Total Cases",
                        value: allRecords.length.toString(),
                        subtitle: "Active Referrals",
                        icon: Icons.cases_outlined,
                        iconColor: const Color.fromARGB(255, 33, 31, 196),
                      ),

                      const SizedBox(width: 30.0),
                      SummaryWidget(
                        title: "Under Review",
                        value: countByStatus("Under Review").toString(),
                        subtitle: "Being Evaluated",
                        icon: Icons.reviews,
                        iconColor: const Color.fromARGB(255, 24, 206, 33),
                      ),

                      const SizedBox(width: 30.0),
                      SummaryWidget(
                        title: "Sceduled",
                        value: countByStatus("Sceduled").toString(),
                        subtitle: "Hearings Set",
                        icon: Icons.schedule,
                        iconColor: const Color.fromARGB(255, 97, 77, 197),
                      ),

                      const SizedBox(width: 30.0),
                      SummaryWidget(
                        title: "Pending",
                        value: countByStatus("Pending").toString(),
                        subtitle: "Awaiting Decision",
                        icon: Icons.pending,
                        iconColor: const Color.fromARGB(255, 44, 71, 194),
                      ),
                    ],
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
                                  () {},
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

class CreateViolationDialog extends StatelessWidget {
  const CreateViolationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      title: const Text(
        "Create New Violation Report",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Student ID"),
              buildTextField("Student Name"),
              buildDropdown("Violation Type"),
              buildOffenseDropdown("Offense Level"),
              buildDatePicker(context),
              buildFilePicker("Photo Evidence (optional)"),
              buildTextField("Reported by"),
              buildRoleDropdown("Role"),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget buildDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          "Bullying",
          "Cheating",
          "Vandalism",
          "Disrespect",
          "Dress Code Violation",
          "Substance Abuse",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget buildOffenseDropdown(String offenseType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: offenseType,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          "First Offense",
          "Second Offense",
          "Third Offense",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget buildRoleDropdown(String roleLabel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: roleLabel,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          "SASO Officer",
          "School Guard",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Date of Incident",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
        },
      ),
    );
  }

  Widget buildFilePicker(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.attach_file),
        ),
        onTap: () {},
      ),
    );
  }
}

class PendingReportsDialog extends StatelessWidget {
  const PendingReportsDialog({super.key});

  void _confirmAction(BuildContext context, String action) {
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report $action'),
        backgroundColor: action == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }

  void _showRejectConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.cancel, color: Colors.red, size: 48),
        content: Text(
          'Are you sure you want to reject this violation report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pending Violation Reports"),
      content: SizedBox(
        width: 900,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              pendingReportTile(
                context,
                id: "1",
                student: "Annie Batumbakal",
                violation: "Improper Uniform",
                offense: "First Offense",
              ),
              pendingReportTile(
                context,
                id: "2",
                student: "Juan Dela Cruz",
                violation: "Late Attendance",
                offense: "Second Offense",
              ),
              pendingReportTile(
                context,
                id: "3",
                student: "James Reid",
                violation: "Serious Misconduct",
                offense: "Third Offense",
              ),
              pendingReportTile(
                context,
                id: "4",
                student: "burnok",
                violation: "Serious Misconduct",
                offense: "Third Offense",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget pendingReportTile(
    BuildContext context, {
    required String id,
    required String student,
    required String violation,
    required String offense,
  }) {
    Color offenseColor = offense == 'Third Offense'
        ? Colors.red
        : offense == 'Second Offense'
        ? Colors.orange
        : Colors.amber;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('$id - $student'),
        subtitle: Text(violation),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(offense, style: TextStyle(color: offenseColor)),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _confirmAction(context, 'approved'),
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _showRejectConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}

class ViolationRecord {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String? priority;
  final String? referredDate;
  final String? hearingDate;

  ViolationRecord({
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
