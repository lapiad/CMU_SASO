import 'dart:convert';
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
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final box = GetStorage();
      final userId = box.read('user_id');
      if (userId == null) throw Exception("User ID not found.");

      final serverUrl = GlobalConfiguration().getValue("server_url");
      if (serverUrl == null || serverUrl.isEmpty) {
        throw Exception("Server URL is not configured.");
      }

      final url = Uri.parse('$serverUrl/users/$userId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = [
            User(
              name: data['first_name']?.toString() ?? '',
              email: data['email']?.toString() ?? '',
              office: data['department']?.toString() ?? '',
              role: data['role']?.toString() ?? '',
              status: data['status']?.toString() ?? 'Active',
            ),
          ];
        });
      } else {
        debugPrint("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  void _editUser(int index) {
    final user = users[index];
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final officeController = TextEditingController(text: user.office);
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
                  office: officeController.text,
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
        _popupItem(Icons.person, 'Profile Settings', 'profile'),
        _popupItem(Icons.logout, 'Sign Out', 'signout'),
      ],
    );
    if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
      );
    } else if (result == 'signout') {
      final box = GetStorage();
      box.erase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    }
  }

  PopupMenuItem<String> _popupItem(IconData icon, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 26, color: const Color(0xFF446EAD)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: sideMenuSize,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF446EAD), Color(0xFF5F8EDC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Image.asset(
                'images/logos.png',
                height: 70,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "CMU_SASO DRMS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Colors.white54),
          _menuHeader("GENERAL"),
          _menuItem(Icons.home, "Dashboard", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard()),
            );
          }),
          _menuItem(Icons.list_alt, "Violation Logs", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ViolationLogsPage()),
            );
          }),
          _menuItem(Icons.pie_chart, "Summary of Reports", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SummaryReportsPage()),
            );
          }),
          const Divider(color: Colors.white54),
          _menuHeader("ADMINISTRATION"),
          _menuItem(Icons.person, "User Management", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserMgt()),
            );
          }),
        ],
      ),
    );
  }

  Widget _menuHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: Colors.white, size: 26),
    title: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    hoverColor: Colors.white10,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f9ff),
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF446EAD),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 32),
          onPressed: () =>
              setState(() => sideMenuSize = sideMenuSize == 0.0 ? 320.0 : 0.0),
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
                  icon: const Icon(Icons.person, color: Color(0xFF446EAD)),
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
          if (sideMenuSize != 0.0) _buildSideMenu(context),
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.grey.shade100,
                            ),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddNewUserDialog(),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF446EAD),
      ),
    );
  }
}
