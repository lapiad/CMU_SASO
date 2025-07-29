import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Widget buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _InfoCard(
        title: title,
        value: value,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMU-SASO DASHBOARD'),
        backgroundColor: const Color.fromARGB(255, 182, 175, 175),
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              const Text(
                'ADMIN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 253, 250, 250),
                child: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const SizedBox(width: 40.0),
                SizedBox(
                  width: 400,
                  height: 200,
                  child: buildSummaryCard(
                    "Total Violations",
                    "9",
                    "This Week",
                    Icons.description,
                    const Color.fromARGB(255, 216, 230, 22),
                  ),
                ),
                const SizedBox(width: 30.0),
                SizedBox(
                  width: 400,
                  height: 200,
                  child: buildSummaryCard(
                    "Active Cases",
                    "8",
                    "Pending Review",
                    Icons.bookmark,
                    const Color.fromARGB(255, 12, 212, 22),
                  ),
                ),
                const SizedBox(width: 30.0),
                SizedBox(
                  width: 400,
                  height: 200,
                  child: buildSummaryCard(
                    "Student Involved",
                    "15",
                    "Unique Students",
                    Icons.people,
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(width: 30.0),
                SizedBox(
                  width: 430,
                  height: 200,
                  child: buildSummaryCard(
                    "Resolved",
                    "5",
                    "This week",
                    Icons.trending_up_sharp,
                    const Color.fromARGB(255, 216, 91, 69),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(100),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Violations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(100),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _QuickActionButton(text: 'Create New Violation Report'),
                        _QuickActionButton(text: 'View Pending Reports'),
                        _QuickActionButton(text: 'Generate Weekly Report'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 70.0,
                        maxWidth: 70.0,
                      ),
                      child: Image.asset('images/logos.png'),
                    ),
                    Text(
                      "CMU_SASO DRMS",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'GENERAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Dashboard'),
                tileColor: Colors.grey[300],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Violation Logs'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViolationLogsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Summary of Reports'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Referred to Council'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RefferedCnl()),
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
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserMgt()),
                  );
                },
              ),
            ],
          ),
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
      width: 300,
      height: 180,
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
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
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String text;

  const _QuickActionButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      width: double.infinity,
      child: Center(child: Text(text, style: const TextStyle(fontSize: 16))),
    );
  }
}
