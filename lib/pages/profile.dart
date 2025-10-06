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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // New password controllers
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String userFirstName = "Loading...";
  String userLastName = "Loading...";
  String userEmail = "Loading...";
  String userInitials = "AD";
  String userRole = "ADMIN";
  bool isEditable = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          userFirstName = userData["first_name"] ?? "Loading...";
          userLastName = userData["last_name"] ?? "Loading...";
          userEmail = userData["email"] ?? "Loading...";
          userRole = userData["role"] ?? "ADMIN";
          userInitials = getInitials(userFirstName, userLastName);

          firstNameController.text = userFirstName;
          lastNameController.text = userLastName;
          emailController.text = userEmail;

          // Clear password fields on fetch
          newPasswordController.clear();
          confirmPasswordController.clear();
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

  Future<void> updateUserData() async {
    final box = GetStorage();
    final userId = box.read('user_id');

    if (userId == null) {
      print("No user ID found in storage.");
      return;
    }

    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/$userId',
    );

    final Map<String, String> updatedData = {
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "email": emailController.text.trim(),
    };

    // Include password only if provided and matching
    if (newPasswordController.text.isNotEmpty) {
      if (newPasswordController.text == confirmPasswordController.text) {
        updatedData["password"] = newPasswordController.text;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        // Clear password fields after successful update
        newPasswordController.clear();
        confirmPasswordController.clear();

        fetchUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontSize: 30)),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  Form(key: _formKey, child: _buildProfileDetails()),
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
              radius: 100,
              backgroundColor: Colors.blue[700],
              child: Text(
                userInitials,
                style: const TextStyle(
                  fontSize: 60,
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

  /// Profile Details
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
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'First name required'
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: buildLabeledField(
                    "Last Name",
                    lastNameController,
                    readOnly: !isEditable,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Last name required'
                        : null,
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
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Email required';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                  return 'Enter a valid email';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Custom TextField Builder
  Widget buildLabeledField(
    String label,
    TextEditingController controller, {
    required bool readOnly,
    IconData? icon,
    String? Function(String?)? validator,
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
            validator: validator,
            style: const TextStyle(fontSize: 25),
            obscureText: label.toLowerCase().contains("password"),
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
