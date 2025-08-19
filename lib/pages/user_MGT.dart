import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
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
        title: const Text(
          'User Management',
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
            SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Total Users",
                          value: '15',
                          subtitle: "Registered Users",
                          icon: Icons.supervised_user_circle_outlined,
                          iconColor: const Color.fromARGB(255, 33, 31, 196),
                        ),
                        const SizedBox(width: 30.0),

                        SummaryWidget(
                          title: "Active Users",
                          value: users
                              .where((u) => u['status'] == 'Active')
                              .length
                              .toString(),
                          subtitle: "Currently Active",
                          icon: Icons.online_prediction,
                          iconColor: Color.fromARGB(255, 24, 206, 33),
                        ),
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "SASO Officers",
                          value: users
                              .where((u) => u['role'] == 'SASO Officer')
                              .length
                              .toString(),
                          subtitle: "Officers Assigned",
                          icon: Icons.shield,
                          iconColor: const Color.fromARGB(255, 47, 199, 204),
                        ),
                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Admins",
                          value: users
                              .where((u) => u['role'] == 'Admin')
                              .length
                              .toString(),
                          subtitle: "System Administrators",
                          icon: Icons.admin_panel_settings,
                          iconColor: const Color.fromARGB(255, 44, 71, 194),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search by name, ID, or violation...",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
}
