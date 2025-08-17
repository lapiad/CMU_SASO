import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';

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

class UserMgt extends StatefulWidget {
  const UserMgt({super.key});

  @override
  State<UserMgt> createState() => _UserMgtState();
}

class _UserMgtState extends State<UserMgt> {
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

  static const List<Map<String, dynamic>> _initialUsers = [
    {
      'name': 'Nadine Lustre',
      'email': 'nadine.l@cityofmalabonuniversity.edu.ph',
      'role': 'SASO Officer',
      'status': 'Active',
      'lastLogin': '2025-02-15 10:30 AM',
      'office': 'Student Affairs Services Office',
    },
    {
      'name': 'Mang Tani',
      'email': 'tani.guard@cityofmalabonuniversity.edu.ph',
      'role': 'Guard',
      'status': 'Active',
      'lastLogin': '2025-02-15 10:30 AM',
      'office': 'Safety and Security Office',
    },
    {
      'name': 'Sarah Geronimo',
      'email': 'sarahg@cityofmalabonuniversity.edu.ph',
      'role': 'Guard',
      'status': 'Active',
      'lastLogin': '2025-02-15 10:30 AM',
      'office': 'Safety and Security Office',
    },
    {
      'name': 'Admin User',
      'email': 'admin@cityofmalabonuniversity.edu.ph',
      'role': 'Admin',
      'status': 'Active',
      'lastLogin': '2025-02-15 10:30 AM',
      'office': 'Student Affairs Services Office',
    },
  ];

  List<Map<String, dynamic>> users = List.from(_initialUsers);

  Future<void> _showPopupMenu(BuildContext context) async {
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
        const PopupMenuItem(
          value: 'system',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('System Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text("Sign Out", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );

    if (result == 'signout') {
      final box = GetStorage();
      box.remove('user_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color.fromARGB(255, 182, 175, 175),
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              FutureBuilder(
                future: getName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? snapshot.data! : "Loading...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  );
                },
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () => _showPopupMenu(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: SizedBox(
        width: 130,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Implement Add New User action
          },
          child: const Icon(Icons.add, size: 50),
          tooltip: 'Add New User',
          backgroundColor: Colors.blue,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 30.0),
                  _buildSummaryCard(
                    "Total Users",
                    users.length.toString(),
                    "Registered Users",
                    Icons.supervised_user_circle_outlined,
                    const Color.fromARGB(255, 33, 31, 196),
                  ),
                  const SizedBox(width: 30.0),
                  _buildSummaryCard(
                    "Active Users",
                    users
                        .where((u) => u['status'] == 'Active')
                        .length
                        .toString(),
                    "Currently Active",
                    Icons.online_prediction,
                    const Color.fromARGB(255, 24, 206, 33),
                  ),
                  const SizedBox(width: 30.0),
                  _buildSummaryCard(
                    "SASO Officers",
                    users
                        .where((u) => u['role'] == 'SASO Officer')
                        .length
                        .toString(),
                    "Officers Assigned",
                    Icons.shield,
                    const Color.fromARGB(255, 47, 199, 204),
                  ),
                  const SizedBox(width: 30.0),
                  _buildSummaryCard(
                    "Admins",
                    users.where((u) => u['role'] == 'Admin').length.toString(),
                    "System Administrators",
                    Icons.admin_panel_settings,
                    const Color.fromARGB(255, 44, 71, 194),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                hintText: "Search by name, ID, or violation...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(users[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 430,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user['name'].substring(0, 2).toUpperCase()),
        ),
        title: Text(user['name']),
        subtitle: Text("${user['email']}\n${user['office']}"),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(user['role']),
              backgroundColor: user['role'] == 'Admin'
                  ? Colors.red[200]
                  : Colors.blue[200],
            ),
            Chip(
              label: Text(user['status']),
              backgroundColor: Colors.green[300],
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
                  const SizedBox(height: 8),
                  const Text(
                    "CMU_SASO DRMS",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              tileColor: Colors.grey[300],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Violation Logs'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViolationLogsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Summary of Reports'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryReportsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Referred to Council'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RefferedCnl()),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ADMINISTRATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User management'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserMgt()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
