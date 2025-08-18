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
          alignment: Alignment.centerLeft,
        ),
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CMU-SASO DASHBOARD',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
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
                  icon: const Icon(Icons.person, color: Colors.black),
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
        width: 130,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            // Add new user logic here
          },
          backgroundColor: Colors.blue,
          tooltip: 'Add New User',
          child: const Icon(Icons.add, size: 50),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: sideMenuSize,
                  child: sideMenuSize != 0.0
                      ? Container(
                          decoration: BoxDecoration(color: Colors.blue[900]),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 30),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.asset(
                                    'images/logos.png',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 30),
                                const Text(
                                  "CMU_SASO DRMS",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 30),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'GENERAL',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    'Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  tileColor: Colors.white,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Dashboard(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.list_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    'Violation Logs',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  tileColor: Colors.white,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViolationLogsPage(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.pie_chart,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    'Summary of Reports',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  tileColor: Colors.white,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SummaryReportsPage(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.bookmark,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    'Referred to Council',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  tileColor: Colors.white,
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'ADMINISTRATION',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    'User management',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserMgt(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SizedBox(
                    child: Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 40),
                                    _InfoCard(
                                      title: "Total Cases",
                                      value: "3",
                                      subtitle: "Active Referrals",
                                      icon: Icons.cases_outlined,
                                      iconColor: Colors.red,
                                    ),
                                    const SizedBox(width: 30),
                                    _InfoCard(
                                      title: "Under Review",
                                      value: "1",
                                      subtitle: "Being Evaluated",
                                      icon: Icons.reviews,
                                      iconColor: Colors.blue,
                                    ),
                                    const SizedBox(width: 30),
                                    _InfoCard(
                                      title: "Scheduled",
                                      value: "1",
                                      subtitle: "Hearings Set",
                                      icon: Icons.schedule,
                                      iconColor: Colors.teal,
                                    ),
                                    const SizedBox(width: 30),
                                    _InfoCard(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Recent Violations',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        _ViolationEntry(
                                          name: 'Annie Batumbakal',
                                          description: 'Improper Uniform',
                                          offenseType: 'First Offense',
                                          offenseColor: Colors.amber,
                                        ),
                                        _ViolationEntry(
                                          name: 'Juan Dela Cruz',
                                          description: 'Late Attendance',
                                          offenseType: 'Second Offense',
                                          offenseColor: Colors.deepOrange,
                                        ),
                                        _ViolationEntry(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          width: 800,
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
                                          width: 800,
                                          height: 80,
                                          child: buildActionButton(
                                            Icons.article_outlined,
                                            " View Pending Reports",
                                            () {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    PendingReportsDialog(),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 800,
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
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(icon, color: iconColor, size: 40),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ViolationEntry extends StatelessWidget {
  final String name;
  final String description;
  final String offenseType;
  final Color offenseColor;

  const _ViolationEntry({
    required this.name,
    required this.description,
    required this.offenseType,
    required this.offenseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: offenseColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              offenseType,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
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
