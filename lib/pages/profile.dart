import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String userFirstName = "Loading...";
  String userLastName = "Loading...";
  String userEmail = "Loading...";
  String userInitials = "AD";
  String userRole = "ADMIN"; // Default role

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the page loads
  }

  void fetchUserData() async {
    final box = GetStorage();
    final userId = box.read('user_id');

    if (userId == null) {
      print("No user ID found in storage.");
      return;
    }

    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/$userId',
    );

    try {
      // Example: Using http package to fetch data from API
      // You need to add `http` package in pubspec.yaml: http: ^0.13.5
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          userFirstName = userData["first_name"] ?? "Loading...";
          userLastName = userData["last_name"] ?? "Loading...";
          userEmail = userData["email"] ?? "Loading...";
          userRole = userData["role"] ?? "ADMIN";
          userInitials = getInitials(userFirstName, userLastName);

          // Populate the controllers with fetched data
          firstNameController.text = userFirstName;
          lastNameController.text = userLastName;
          emailController.text = userEmail;
        });
      } else {
        print("Failed to load user data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
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
        backgroundColor: Colors.blue[900],
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
              radius: 50,
              backgroundColor: Colors.blue[700],
              child: Text(
                userInitials,
                style: const TextStyle(
                  fontSize: 32,
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
                    "$userFirstName $userLastName",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 18,
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
            buildLabeledField("First Name", firstNameController),
            buildLabeledField("Last Name", lastNameController),
            buildLabeledField(
              "Email Address",
              emailController,
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
            fontSize: 20,
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
            style: const TextStyle(fontSize: 20),
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
}
