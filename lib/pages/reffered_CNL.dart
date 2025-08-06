import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';

class RefferedCnl extends StatelessWidget {
  final List<Map<String, dynamic>> cases = [
    {
      'name': 'Film Rachanu',
      'id': '202202215',
      'violation': 'Academic Dishonesty',
      'details': 'Cheating on final examination',
      'priority': 'High',
      'status': 'Scheduled Hearing',
      'referred': '02-12-2025',
    },
    {
      'name': 'Sponge Cola',
      'id': '202202803',
      'violation': 'Vandalism',
      'details': 'Damage to school property',
      'priority': 'Medium',
      'status': 'Pending Decision',
      'referred': '02-10-2025',
    },
    {
      'name': 'Natoy Laham',
      'id': '202202803',
      'violation': 'Wearing Earings',
      'details': 'Wearing Earings',
      'priority': 'Meduim',
      'status': 'Sceduled Hearing',
      'referred': '09-5-2025',
    },
    {
      'name': 'Film Rachanu',
      'id': '202202215',
      'violation': 'Academic Dishonesty',
      'details': 'Cheating on final examination',
      'priority': 'High',
      'status': 'Scheduled Hearing',
      'referred': '02-12-2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referred To Council'),
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
              const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 253, 250, 250),
                child: Icon(Icons.person, color: Colors.black),
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
                    MaterialPageRoute(builder: (context) => Dashboard()),
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
                      builder: (context) => ViolationLogsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Summary of Reports'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryReportsPage(),
                    ),
                  );
                },
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
                        "Total Cases",
                        "3",
                        "Active Referrals",
                        Icons.cases_outlined,
                        const Color.fromARGB(255, 240, 48, 48),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Under Review",
                        "1",
                        "Being Evaluated",
                        Icons.reviews,
                        const Color.fromARGB(255, 52, 96, 241),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Scheduled",
                        "1",
                        "Hearings Set",
                        Icons.schedule,
                        const Color.fromARGB(255, 13, 200, 224),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: buildSummaryCard(
                        "Pending",
                        "1",
                        "Awaiting Decision",
                        Icons.pending,
                        const Color.fromARGB(255, 232, 235, 19),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final caseData = cases[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  '${caseData['priority']} Priority',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: caseData['priority'] == 'High'
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              SizedBox(width: 10),
                              Chip(
                                label: Text(
                                  caseData['status'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    caseData['status'] == 'Scheduled Hearing'
                                    ? Colors.purple
                                    : Colors.orange,
                              ),
                            ],
                          ),
                          Text(
                            '${caseData['name']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text('Student ID: ${caseData['id']}'),
                          SizedBox(height: 20),
                          Text(
                            '${caseData['violation']}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text('${caseData['details']}'),
                          SizedBox(height: 20),
                          Text('📅 Referred: ${caseData['referred']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.visibility),
                                label: const Text("View Details"),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.description),
                                label: const Text("Documents"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
      height: 180,
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
}
