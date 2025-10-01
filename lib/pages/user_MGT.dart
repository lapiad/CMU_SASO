import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/addNewuser.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/reffered_CNL.dart';
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
  final String office;
  final String role;
  final String status;

  User({
    required this.name,
    required this.email,
    required this.office,
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
  List<User> users = [
    User(
      name: "Nadine Lustre",
      email: "nadine.l@cityofmalabonuniversity.edu.ph",
      office: "Student Affairs Services Office",
      role: "SASO Officer",
      status: "Active",
    ),
  ];

  void _editUser(int index) {
    final user = users[index];
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final officeController = TextEditingController(text: user.office);

    // Role choices
    String roleValue = user.role;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left column
              Expanded(
                child: Column(
                  children: [
                    _buildTextField("Name", nameController),
                    _buildTextField("Email", emailController),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              /// Right column
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
                      onChanged: (value) {
                        if (value != null) roleValue = value;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                users[index] = User(
                  name: nameController.text,
                  email: emailController.text,
                  office: officeController.text,
                  role: roleValue,
                  status: user.status, // keep old status silently
                );
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              "Save",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Delete confirmation dialog
  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Text(
              "Delete User",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Row(
          children: [
            const Icon(Icons.person, size: 35, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Are you sure you want to delete '${users[index].name}'?",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0033A0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                users.removeAt(index);
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete, size: 20, color: Colors.white),
            label: const Text(
              "Delete",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  /// Reusable textfield builder
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Row(
              children: [
                Icon(Icons.person, size: 30),
                SizedBox(width: 16),
                Text('Profile Settings', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'signout',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Row(
              children: [
                Icon(Icons.logout, size: 30),
                SizedBox(width: 16),
                Text("Sign Out", style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      ],
    );

    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
      );
    }

    if (result == 'signout') {
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
              FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? snapshot.data! : "Loading...",
                    style: const TextStyle(
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
      body: Row(
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
                        Navigator.pushReplacement(
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
                      SummaryWidget(
                        title: "Total Users",
                        value: users.length.toString(),
                        subtitle: "Registered Users",
                        icon: Icons.supervised_user_circle_outlined,
                        iconColor: const Color.fromARGB(255, 76, 50, 221),
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
                        iconColor: const Color.fromARGB(255, 33, 243, 33),
                      ),
                      const SizedBox(width: 30),
                      SummaryWidget(
                        title: "SASO Officer",
                        value: users
                            .where((u) => u.role == "SASO Officer")
                            .length
                            .toString(),
                        subtitle: "Officers Assigned",
                        icon: Icons.shield,
                        iconColor: Colors.teal,
                      ),
                      const SizedBox(width: 30),
                      SummaryWidget(
                        title: "Guards",
                        value: users
                            .where((u) => u.role == "Guard")
                            .length
                            .toString(),
                        subtitle: "System Administrators",
                        icon: Icons.admin_panel_settings,
                        iconColor: const Color.fromARGB(255, 101, 54, 250),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 1900,
                    height: 650,
                    child: Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Office',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Role',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
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
                                    user.office,
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
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 25,
                                        ),
                                        onPressed: () => _editUser(index),
                                      ),
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
