import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

class AddNewUserDialog extends StatefulWidget {
  const AddNewUserDialog({super.key});

  @override
  State<AddNewUserDialog> createState() => _AddNewUserDialogState();
}

class _AddNewUserDialogState extends State<AddNewUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _middleName;
  String? _password;
  String? _firstName;
  String? _lastName;
  String? _emailAddress;
  String? _selectedRole;
  String? _selectedDepartment;

  final List<String> _roles = ['admin', 'guard'];
  final List<String> _departments = [
    'Security Department',
    'Guard Department',
    'SASO Department',
  ];

  Future<void> createUser() async {
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users',
    );

    final Map<String, dynamic> payload = {
      "username": _username,
      "password": _password,
      "first_name": _firstName,
      "middle_name": _middleName,
      "last_name": _lastName,
      "email": _emailAddress,
      "role": _selectedRole,
      "department": _selectedDepartment,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added successfully.")),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add user: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth < 700 ? screenWidth * 0.95 : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.person_add, color: Colors.black, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      "Add New User",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 25,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Avatar initials
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3F51B5),
                  ),
                  child: Center(
                    child: Text(
                      (_firstName != null && _firstName!.isNotEmpty) &&
                              (_lastName != null && _lastName!.isNotEmpty)
                          ? "${_firstName![0]}${_lastName![0]}".toUpperCase()
                          : "NEW",
                      style: const TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        labelText: "Username",
                        hintText: "Enter username",
                        onSaved: (val) => _username = val,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Enter username'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        labelText: "Password",
                        hintText: "Enter password",
                        onSaved: (val) => _password = val,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Enter password'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // First + Last Name
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        labelText: "First Name",
                        hintText: "Enter first name",
                        onSaved: (val) => _firstName = val,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Enter first name'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        labelText: "Middle Name",
                        hintText: "Enter middle name",
                        onSaved: (val) => _middleName = val,
                        validator: (val) => null, // No validation, optional
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Email
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        labelText: "Last Name",
                        hintText: "Enter last name",
                        onSaved: (val) => _lastName = val,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Enter last name'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        labelText: "Email Address",
                        hintText: "Enter email address",
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (val) => _emailAddress = val,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter email address';
                          }
                          final emailRegex = RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ); // Simple email validation
                          if (!emailRegex.hasMatch(val)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role + Department
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        labelText: "Role",
                        hintText: "Select user role",
                        value: _selectedRole,
                        items: _roles,
                        onChanged: (val) => setState(() => _selectedRole = val),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Select role' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        labelText: "Department",
                        hintText: "Select department",
                        value: _selectedDepartment,
                        items: _departments,
                        onChanged: (val) =>
                            setState(() => _selectedDepartment = val),
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Select department'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0033A0),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          createUser();
                        }
                      },

                      child: const Text(
                        "Add User",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
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
    );
  }

  // Helpers
  Widget _buildTextField({
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      value: value,
      onChanged: onChanged,
      validator: validator,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
