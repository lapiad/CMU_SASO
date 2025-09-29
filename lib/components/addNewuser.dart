import 'package:flutter/material.dart';

class AddNewUserDialog extends StatefulWidget {
  const AddNewUserDialog({super.key});

  @override
  State<AddNewUserDialog> createState() => _AddNewUserDialogState();
}

class _AddNewUserDialogState extends State<AddNewUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _emailAddress;
  String? _selectedRole;
  String? _selectedDepartment;

  final List<String> _roles = ['Admin', 'SASO Officer', 'Guard'];
  final List<String> _departments = [
    'Student Affairs Services Office',
    'Safety and Security Office',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.all(
        16,
      ), // prevents dialog from touching screen edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth < 700 ? screenWidth * 0.95 : 600, // responsive
          maxHeight:
              MediaQuery.of(context).size.height * 0.9, // prevent overflow
        ),
        child: SingleChildScrollView(
          // makes dialog scrollable on small screens
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
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3F51B5),
                  ),
                  child: Center(
                    child: Text(
                      _firstName != null && _lastName != null
                          ? "${_firstName![0]}${_lastName![0]}".toUpperCase()
                          : "NU",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

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
                        labelText: "Last Name",
                        hintText: "Enter last name",
                        onSaved: (val) => _lastName = val,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Enter last name'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  labelText: "Email Address",
                  hintText: "user@cityofmalabonuniversity.edu.ph",
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) => _emailAddress = val,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter email';
                    if (!val.contains('@')) return 'Enter valid email';
                    return null;
                  },
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Adding user: $_firstName $_lastName ($_emailAddress), Role: $_selectedRole',
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
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
      onChanged: onChanged,
      validator: validator,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
