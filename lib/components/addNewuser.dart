import 'package:flutter/material.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String selectedRole = "Select user role";
  String selectedDepartment = "Select department";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person, size: 40, color: Colors.black),
          SizedBox(width: 10),
          Text(
            "Add New User",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400, // Adjusted to accommodate more fields
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter first name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter last name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email Address"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: "Role"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
                items: <String>['Select user role', 'Admin', 'User', 'Manager']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: InputDecoration(labelText: "Department"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue!;
                  });
                },
                items: <String>['Select department', 'HR', 'IT', 'Finance']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.blue[900], // Correct way to add color to the button
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Add the user here
              print(
                "User added: ${firstNameController.text} ${lastNameController.text}, ${emailController.text}, Role: $selectedRole, Department: $selectedDepartment",
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Add User",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
