import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditable = false; // Add this line to define isEditable

  String userFirstName = "Loading...";
  String userInitials = "AD";
  String userRole = "ADMIN"; // default role

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final box = GetStorage();
    final userId = box.read('user_id');
    final serverUrl = GlobalConfiguration().getValue("server_url");

    if (userId == null || serverUrl == null) {
      loadSampleData();
      return;
    }

    try {
      final url = Uri.parse('$serverUrl/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userFirstName = data['first_name'] ?? "Unknown";
          firstNameController.text = data['first_name'] ?? '';
          lastNameController.text = data['last_name'] ?? '';
          emailController.text =
              data['email'] ?? 'admin@cityofmalabonuniversity.edu.ph';
          userInitials = getInitials(data['first_name'], data['last_name']);
          userRole = data['role'] ?? "ADMIN";
        });
      } else {
        loadSampleData();
      }
    } catch (e) {
      loadSampleData();
    }
  }

  void loadSampleData() {
    setState(() {
      userFirstName = "Anthony";
      firstNameController.text = "Morales";
      lastNameController.text = "Santos";
      emailController.text = "anthony.morales@example.com";
      userInitials = getInitials("Anthony", "Morales");
      userRole = "ADMIN";
    });
  }

  String getInitials(String? first, String? last) {
    final f = (first?.isNotEmpty ?? false) ? first![0] : '';
    final l = (last?.isNotEmpty ?? false) ? last![0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontSize: 22)),
        backgroundColor: const Color.fromARGB(255, 68, 110, 173),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildProfileDetails(),
          ],
        ),
      ),
    );
  }

  /// Profile Header (Avatar + Name + Role)
  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Row(
          children: [
            CircleAvatar(
              radius: 130,
              backgroundColor: const Color.fromARGB(255, 68, 110, 173),
              child: Text(
                userInitials,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$userFirstName ${lastNameController.text}",
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile Details (TextFields with shadow)
  Widget _buildProfileDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildLabeledField(
                    "First Name",
                    firstNameController,
                    readOnly: !isEditable,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: buildLabeledField(
                    "Last Name",
                    lastNameController,
                    readOnly: !isEditable,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildLabeledField(
              "Email Address",
              emailController,
              readOnly: !isEditable,
              icon: Icons.email,
            ),
          ],
        ),
      ),
    );
  }

  /// Custom TextField with shadow
  Widget buildLabeledField(
    String label,
    TextEditingController controller, {
    bool readOnly = true,
    bool obscureText = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 25,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 23),
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.blue[700])
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
} // <-- Add this closing bracket for _ProfileSettingsPageState
