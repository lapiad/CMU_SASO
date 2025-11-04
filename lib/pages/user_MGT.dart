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

/// Fetch the name of the current logged-in user
Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['first_name'] ?? "Unknown";
  } else {
    return "Unknown";
  }
}

/// User model
class User {
  final String id;
  final String name;
  final String email;
  final String office;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.office,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'] ?? json['user_id'] ?? '').toString(),
      name: json['first_name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      office: json['department'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

/// User Management Page
class UserMgt extends StatefulWidget {
  const UserMgt({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserMgt> {
  double sideMenuSize = 0.0;
  List<User> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final serverUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$serverUrl/users-details');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        if (jsonBody.containsKey('users')) {
          final List<dynamic> userList = jsonBody['users'];
          setState(() {
            users = userList.map((u) => User.fromJson(u)).toList();
          });
        }
      } else {
        debugPrint("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteUser(int index) async {
    final user = users[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Are you sure you want to delete '${user.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final serverUrl = GlobalConfiguration().getValue("server_url");
      final url = Uri.parse('$serverUrl/users/${user.id}');
      final resp = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        setState(() => users.removeAt(index));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${user.name} deleted')));
        await fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openAddUserDialog() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const AddNewUserDialog(),
    );
    if (result == true) await fetchUsers();
  }

  void _openEditUserDialog(User user) async {
    final result = await showDialog(
      context: context,
      builder: (_) => EditUserDialog(user: user),
    );
    if (result == true) await fetchUsers();
  }

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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    Colors.grey.shade100,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: SizedBox(
                                        width: 320,
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
                                        width: 320,
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
                                        width: 300,
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
                                        width: 300,
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
                                        width: 300,
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
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.email,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.office,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.role,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () =>
                                                    _openEditUserDialog(user),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _deleteUser(index),
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
        onPressed: _openAddUserDialog,
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

/// Edit User Dialog
class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController officeController;
  late TextEditingController roleController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    officeController = TextEditingController(text: widget.user.office);
    roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    officeController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      const serverUrl = 'http://localhost:8080'; // Replace with actual URL
      final url = Uri.parse('$serverUrl/users/${widget.user.id}');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'department': officeController.text.trim(),
          'role': roleController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        _showSnackbar(context, 'User updated successfully! 🎉', isError: false);
      } else {
        Navigator.pop(context, false);
        _showSnackbar(
          context,
          'Failed to update user: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Theme.of(context).primaryColor,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 300,
          maxWidth: screenWidth * 0.5,
          maxHeight: screenHeight * 0.8, // Limit height and allow scrolling
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Edit User Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name Field
                  _buildTextField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'Enter user\'s full name',
                    icon: Icons.person,
                    validator: (val) => _validateRequired(val, 'Name'),
                  ),

                  // Email Field
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'user@example.com',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  // Office/Department Field
                  _buildTextField(
                    controller: officeController,
                    label: 'Office/Department',
                    hint: 'e.g., Sales, HR',
                    icon: Icons.location_city,
                    validator: (val) => _validateRequired(val, 'Office'),
                  ),

                  // Role Field
                  _buildTextField(
                    controller: roleController,
                    label: 'Role/Position',
                    hint: 'e.g., Manager, Developer',
                    icon: Icons.work,
                    validator: (val) => _validateRequired(val, 'Role'),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey[100],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
