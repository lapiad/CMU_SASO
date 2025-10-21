import 'package:flutter/material.dart';

class EditUserForms extends StatefulWidget {
  final User user;

  const EditUserForms({super.key, required this.user});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForms> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _initialController;
  late TextEditingController _passwordController;

  // Dropdown roles list (no duplicates, lowercase only)
  final List<String> _roles = ['admin', 'sao', 'guard'];

  // Selected dropdown value
  late String _selectedRole;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _departmentController = TextEditingController(text: widget.user.department);
    _initialController = TextEditingController(text: widget.user.initial);
    _passwordController = TextEditingController();

    // Normalize and validate the incoming role
    String normalizedRole = widget.user.role.trim().toLowerCase();
    if (_roles.contains(normalizedRole)) {
      _selectedRole = normalizedRole;
    } else {
      print(
        '⚠️ Warning: user role "${widget.user.role}" not found in roles list. Defaulting to first role.',
      );
      _selectedRole = _roles.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _initialController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Edit User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField('Name', _nameController),
                          const SizedBox(height: 16),
                          _buildTextField('Email', _emailController),
                          const SizedBox(height: 16),

                          // ✅ Role Dropdown (restored)
                          _buildDropdownField(),
                          const SizedBox(height: 16),

                          _buildTextField('Department', _departmentController),
                          const SizedBox(height: 16),
                          _buildTextField('Initial', _initialController),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Password',
                            _passwordController,
                            obscure: true,
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    widget.user.name = _nameController.text;
                                    widget.user.email = _emailController.text;
                                    widget.user.role = _selectedRole;
                                    widget.user.department =
                                        _departmentController.text;
                                    widget.user.initial =
                                        _initialController.text;

                                    print(
                                      '✅ User saved: ${widget.user.name}, role: $_selectedRole',
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text field builder
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  // ✅ Dropdown builder for role
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      value: _roles.contains(_selectedRole) ? _selectedRole : _roles.first,
      items: _roles.map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Role is required';
        }
        return null;
      },
    );
  }
}

// ✅ User model
class User {
  String name;
  String email;
  String role;
  String department;
  String initial;

  User({
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.initial,
  });
}
