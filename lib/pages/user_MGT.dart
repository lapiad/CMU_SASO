import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/addNewuser.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['first_name'];
  } else {
    return "Unknown";
  }
}

class User {
  final String name;
  final String email;
  final String department;
  final String role;
  final String status;

  User({
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.status,
  });
}

class UserMgt extends StatefulWidget {
  const UserMgt({super.key});
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserMgt> {
  double sideMenuSize = 0.0;
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final box = GetStorage();
      final serverUrl = GlobalConfiguration().getValue("server_url");
      if (serverUrl == null || serverUrl.isEmpty) {
        throw Exception("Server URL is not configured.");
      }

      final url = Uri.parse('$serverUrl/users'); // Endpoint to fetch all users
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure data['users'] exists and is a list
        if (data['users'] != null && data['users'] is List) {
          setState(() {
            users = (data['users'] as List).map((user) {
              return User(
                name: user['username']?.toString() ?? '',
                email: user['email']?.toString() ?? '',
                department: user['department']?.toString() ?? '',
                role: user['role']?.toString() ?? '',
                status: user['status']?.toString() ?? 'Active',
              );
            }).toList();
          });
        } else {
          debugPrint("No users found in response");
        }
      } else {
        debugPrint("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  void _editUser(int index) {
    final user = users[index];
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final officeController = TextEditingController(text: user.department);
    String roleValue = user.role;
    String statusValue = user.status;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue, size: 30),
            SizedBox(width: 8),
            Text(
              "Edit User",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTextField("Name", nameController),
                    _buildTextField("Email", emailController),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField("Office", officeController),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: roleValue,
                      decoration: _inputDecoration("Role"),
                      items: ["SASO Officer", "School Guard"]
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (value) => roleValue = value ?? roleValue,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: statusValue,
                      decoration: _inputDecoration("Status"),
                      items: ["Active", "Inactive"]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) => statusValue = value ?? statusValue,
                    ),
                  ],
                ),
              ),
            ],
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
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                users[index] = User(
                  name: nameController.text,
                  email: emailController.text,
                  department: officeController.text,
                  role: roleValue,
                  status: statusValue,
                );
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              "Save",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Text(
              "Delete User",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete '${users[index].name}'?",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => users.removeAt(index));
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text(
              "Delete",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey[100],
  );

  Widget _buildTextField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: controller,
          decoration: _inputDecoration(label),
        ),
      );

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 16),
              Text('Profile Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 16),
              Text('Sign Out'),
            ],
          ),
        ),
      ],
    );

    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
      );
    } else if (result == 'signout') {
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 40),
          onPressed: () =>
              setState(() => sideMenuSize = sideMenuSize == 0.0 ? 350.0 : 0.0),
        ),
        actions: [
          Row(
            children: [
              FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) => Text(
                  snapshot.data ?? "Loading...",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Color(0xFF0A2C9E)),
                  onPressed: () => _showAdminMenu(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      body: Row(
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
                    const SizedBox(height: 10),
                    const Text(
                      "  CMU_SASO DRMS",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const Divider(color: Colors.white),
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

                    const Divider(color: Colors.white),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      SummaryWidget(
                        title: "Total Users",
                        value: users.length.toString(),
                        subtitle: "Registered Users",
                        icon: Icons.supervised_user_circle_outlined,
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(width: 30),
                      SummaryWidget(
                        title: "Active Users",
                        value: users
                            .where((u) => u.status == "Active")
                            .length
                            .toString(),
                        subtitle: "Currently Active",
                        icon: Icons.online_prediction,
                        iconColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Office',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Role',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 280,
                              child: Text(
                                'Actions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: users.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.email,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.department,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.role,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              DataCell(
                                Chip(
                                  label: Text(
                                    user.status,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  backgroundColor: user.status == "Active"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    const SizedBox(width: 20),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      onPressed: () => _deleteUser(index),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 150,
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddNewUserDialog(),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 30),
          label: const Text(
            "Add User",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[900],
        ),
      ),
    );
  }
}
