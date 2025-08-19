import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

double expandedClass = 0.0;

class SummaryReportsPage extends StatefulWidget {
  const SummaryReportsPage({super.key});
  @override
  State<SummaryReportsPage> createState() => _SummaryReportsPageState();
}

class _SummaryReportsPageState extends State<SummaryReportsPage> {
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

  @override
  Widget build(BuildContext context) {
    final distribution = getViolationDistribution();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary of Reports',
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
                        width: 75,
                        height: 75,
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
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "This Week",
                          value: cases.length.toString(),
                          subtitle: "Total Violations",
                          icon: Icons.next_week_outlined,
                          iconColor: const Color.fromARGB(255, 240, 48, 48),
                        ),
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Resolved",
                          value: countByStatus('Under Review').toString(),
                          subtitle: "Case Closed",
                          icon: Icons.done,
                          iconColor: const Color.fromARGB(255, 52, 96, 241),
                        ),
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Pending",
                          value: countByStatus('Scheduled Hearing').toString(),
                          subtitle: "Awaiting Review",
                          icon: Icons.pending,
                          iconColor: const Color.fromARGB(255, 13, 200, 224),
                        ),
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Referred",
                          value: countByStatus('Pending').toString(),
                          subtitle: "To Council",
                          icon: Icons.move_down_outlined,
                          iconColor: const Color.fromARGB(255, 232, 235, 19),
                        ),
                      ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    String key =
                                                        entry.value.key;
                                                    int value =
                                                        entry.value.value;
                                                    return PieChartSectionData(
                                                      value: value.toDouble(),
                                                      title: key,
                                                      color:
                                                          Colors
                                                              .primaries[index %
                                                              Colors
                                                                  .primaries
                                                                  .length],
                                                      radius: 50,
                                                      titleStyle:
                                                          const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    );
                                                  })
                                                  .toList(),
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Most Common Violations",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        buildViolationItem(
                                          "Late Attendance",
                                          5,
                                        ),
                                        buildViolationItem(
                                          "Improper Uniform",
                                          10,
                                        ),
                                        buildViolationItem("Cheating", 4),
                                        buildViolationItem("Plagiarism", 25),
                                        buildViolationItem(
                                          "Disruptive Behavior",
                                          6,
                                        ),
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
          ],
        ),
      ),
    );
  }
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
