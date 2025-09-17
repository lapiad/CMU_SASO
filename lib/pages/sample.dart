import 'package:flutter/material.dart';

class AddNewUserScreen extends StatefulWidget {
  const AddNewUserScreen({super.key});

  @override
  _AddNewUserScreenState createState() => _AddNewUserScreenState();
}

class _AddNewUserScreenState extends State<AddNewUserScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _role;
  String? _department;

  final List<String> roles = ['Admin', 'User', 'Manager'];

  void _addUser() {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        _role != null &&
        _department != null) {
      // Add user logic here
      print(
        "User added: $firstName $lastName, $email, Role: $_role, Department: $_department",
      );
    } else {
      // Show validation message
      print("Please fill in all fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: InputDecoration(labelText: 'Role'),
              items: roles.map((String role) {
                return DropdownMenuItem<String>(value: role, child: Text(role));
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _role = value;
                });
              },
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _addUser, child: Text('Add User')),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Cancel action (e.g., reset fields)
                    _firstNameController.clear();
                    _lastNameController.clear();
                    _emailController.clear();
                    setState(() {
                      _role = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(iconColor: Colors.grey),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
