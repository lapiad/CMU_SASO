import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';

const List<Map<String, dynamic>> cases = [
  {
    'priority': 'High',
    'status': 'Scheduled Hearing',
    'name': 'John Doe',
    'id': '20230001',
    'violation': 'Cheating',
    'details': 'Caught cheating during midterm exams. Evidence submitted.',
    'referred': '2024-06-01',
  },
  {
    'priority': 'Medium',
    'status': 'Under Review',
    'name': 'Jane Smith',
    'id': '20230002',
    'violation': 'Plagiarism',
    'details': 'Plagiarized assignment. Awaiting further investigation.',
    'referred': '2024-06-03',
  },
  {
    'priority': 'Low',
    'status': 'Pending',
    'name': 'Alice Johnson',
    'id': '20230003',
    'violation': 'Disruptive Behavior',
    'details': 'Disrupted class repeatedly. Awaiting decision.',
    'referred': '2024-06-05',
  },
];

class SummaryReportsPage extends StatefulWidget {
  const SummaryReportsPage({super.key});
  @override
  State<SummaryReportsPage> createState() => _SummaryReportsPageState();
}

class _SummaryReportsPageState extends State<SummaryReportsPage> {
  Map<String, int> getViolationDistribution() {
    final Map<String, int> counts = {};
    for (var c in cases) {
      String violation = c['violation'] as String;
      counts[violation] = (counts[violation] ?? 0) + 1;
    }
    return counts;
  }

  int countByStatus(String statusMatch) {
    return cases
        .where((c) => (c['status'] as String).contains(statusMatch))
        .length;
  }

  void _showAdminMenu(BuildContext context) async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        PopupMenuItem(
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
        const PopupMenuItem<String>(
          value: 'signout',
          child: Text("Sign Out", style: TextStyle(fontSize: 20)),
        ),
      ],
    );

    if (selected == 'signout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final distribution = getViolationDistribution();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary of Reports'),
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
              GestureDetector(
                onTap: () => _showAdminMenu(context),
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 253, 250, 250),
                  child: Icon(Icons.person, color: Colors.black),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
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
                    const Text(
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
                    MaterialPageRoute(builder: (context) => const UserMgt()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "This Week",
                        cases.length.toString(),
                        "Total Violations",
                        Icons.next_week_outlined,
                        const Color.fromARGB(255, 240, 48, 48),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Resolved",
                        countByStatus('Under Review').toString(),
                        "Case Closed",
                        Icons.done,
                        const Color.fromARGB(255, 52, 96, 241),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Pending",
                        countByStatus('Scheduled Hearing').toString(),
                        "Awaiting Review",
                        Icons.pending,
                        const Color.fromARGB(255, 13, 200, 224),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Referred",
                        countByStatus('Pending').toString(),
                        "To Council",
                        Icons.move_down_outlined,
                        const Color.fromARGB(255, 232, 235, 19),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Violation Types Distribution",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        sections: distribution.entries
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              int index = entry.key;
                                              String key = entry.value.key;
                                              int value = entry.value.value;
                                              return PieChartSectionData(
                                                value: value.toDouble(),
                                                title: key,
                                                color:
                                                    Colors.primaries[index %
                                                        Colors
                                                            .primaries
                                                            .length],
                                                radius: 50,
                                                titleStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            })
                                            .toList(),
                                        borderData: FlBorderData(show: false),
                                        centerSpaceRadius: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Weekly Violation Trends",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: 20,
                                        barGroups: [
                                          BarChartGroupData(
                                            x: 1,
                                            barRods: [
                                              BarChartRodData(
                                                toY: 14,
                                                color: Colors.red,
                                                width: 20,
                                              ),
                                              BarChartRodData(
                                                toY: 16,
                                                color: Colors.orange,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          BarChartGroupData(
                                            x: 2,
                                            barRods: [
                                              BarChartRodData(
                                                toY: 18,
                                                color: Colors.red,
                                                width: 20,
                                              ),
                                              BarChartRodData(
                                                toY: 17,
                                                color: Colors.blueAccent,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Offense Level Distribution",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  buildProgressRow(
                                    "First Offense",
                                    45,
                                    Colors.blue,
                                  ),
                                  buildProgressRow(
                                    "Second Offense",
                                    50,
                                    Colors.blueAccent,
                                  ),
                                  buildProgressRow(
                                    "Third Offense",
                                    25,
                                    Colors.lightBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Most Common Violations",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  buildViolationItem("Late Attendance", 5),
                                  buildViolationItem("Improper Uniform", 10),
                                  buildViolationItem("Cheating", 4),
                                  buildViolationItem("Plagiarism", 25),
                                  buildViolationItem("Disruptive Behavior", 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

Widget buildSummaryCard(
  String title,
  String value,
  String subtitle,
  IconData icon,
  Color color,
) {
  return Container(
    width: 300,
    height: 150,
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    ),
  );
}

Widget buildProgressRow(String title, int value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      const SizedBox(height: 4),
      LinearProgressIndicator(
        value: value / 100,
        color: color,
        backgroundColor: Colors.grey[200],
      ),
      const SizedBox(height: 8),
    ],
  );
}

Widget buildViolationItem(String violation, int count) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(violation, style: const TextStyle(fontSize: 19)),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
