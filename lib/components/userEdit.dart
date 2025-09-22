import 'package:flutter/material.dart';

class EditUserForms extends StatefulWidget {
  final User user;

  const EditUserForms({super.key, required this.user});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForms> {
  // Form key to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers for the form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _departmentController;
  late TextEditingController _initialController;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the current values from the User object
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _roleController = TextEditingController(text: widget.user.role);
    _departmentController = TextEditingController(text: widget.user.department);
    _initialController = TextEditingController(text: widget.user.initial);
  }

  @override
  void dispose() {
    // Dispose controllers when done
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _initialController.dispose();
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
                    Text('Edit User'),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey, // Attach form key to validate
                      child: Column(
                        children: [
                          _buildTextField('Name', _nameController),
                          const SizedBox(height: 16),
                          _buildTextField('Email', _emailController),
                          const SizedBox(height: 16),
                          _buildTextField('Role', _roleController),
                          const SizedBox(height: 16),
                          _buildTextField('Department', _departmentController),
                          const SizedBox(height: 16),
                          _buildTextField('Initial', _initialController),
                          const SizedBox(height: 20),
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
                                    // Handle saving changes here
                                    widget.user.name = _nameController.text;
                                    widget.user.email = _emailController.text;
                                    widget.user.role = _roleController.text;
                                    widget.user.department =
                                        _departmentController.text;
                                    widget.user.initial =
                                        _initialController.text;

                                    print(
                                      'User details saved: ${widget.user.name}',
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

  // Helper method to build form text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

// Assuming you have a User model class like this:
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
