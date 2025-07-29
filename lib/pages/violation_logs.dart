import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';

class ViolationLogsPage extends StatelessWidget {
  const ViolationLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Logs'),
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

      drawer: Drawer(
        child: ListView(
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
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Violation Logs"),
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
              title: const Text("Summary of Reports"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text("Referred to Council"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RefferedCnl()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("User management"),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText:
                          'Search by student name, student ID, or violation...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 50),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text(
                    "Filter By",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 1, 1, 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ViolationCard(
                    name: 'Annie Batumbakal',
                    studentId: '202202549',
                    violationTitle: 'Improper Uniform',
                    description:
                        'Student wearing improper school uniform - missing ID lace',
                    reportedBy: 'Mang Tani (Guard)',
                    dateTime: '02-15-2025 4:05PM',
                    offenseLevel: 'First Offense',
                    status: 'Pending',
                    color: Colors.orange,
                  ),
                  ViolationCard(
                    name: 'Juan Dela Cruz',
                    studentId: '202202453',
                    violationTitle: 'Late Attendance',
                    description:
                        'Student arrived 15 minutes late to first period',
                    reportedBy: 'Nadine Lustre (SASO Officer)',
                    dateTime: '02-15-2025 5:30PM',
                    offenseLevel: 'Second Offense',
                    status: 'Reviewed',
                    color: Colors.green,
                  ),
                  ViolationCard(
                    name: 'James Reid',
                    studentId: '202202549',
                    violationTitle: 'Multiple Violations',
                    description: 'Violation referred to council',
                    reportedBy: '',
                    dateTime: '',
                    offenseLevel: 'Third Offense',
                    status: 'Referred',
                    color: Colors.red,
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

class ViolationCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String violationTitle;
  final String description;
  final String reportedBy;
  final String dateTime;
  final String offenseLevel;
  final String status;
  final Color color;

  const ViolationCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.violationTitle,
    required this.description,
    required this.reportedBy,
    required this.dateTime,
    required this.offenseLevel,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(studentId),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Violation title
            Text(
              violationTitle,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Description
            Text(description),
            const SizedBox(height: 6),

            // Reported by and dateTime
            if (reportedBy.isNotEmpty && dateTime.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(reportedBy),
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(dateTime),
                ],
              ),

            const SizedBox(height: 8),

            // Offense level and status
            Row(
              children: [
                Chip(
                  label: Text(offenseLevel),
                  backgroundColor: const Color.fromARGB(255, 102, 100, 97),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(status),
                  backgroundColor: color,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy DashboardPage to avoid errors during navigation
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard content goes here')),
    );
  }
}
