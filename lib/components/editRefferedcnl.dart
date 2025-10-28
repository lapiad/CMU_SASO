import 'package:flutter/material.dart';

class EditCaseDialog extends StatefulWidget {
  const EditCaseDialog({super.key});

  @override
  _EditCaseDialogState createState() => _EditCaseDialogState();
}

class _EditCaseDialogState extends State<EditCaseDialog> {
  String priority = 'High Priority';
  String status = 'Under Review';
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(17),
        child: Row(
          children: [
            Icon(Icons.edit, size: 30, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Edit Case",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      content: SizedBox(
        height: 310,
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                initialValue: priority,
                items: ['High Priority', 'Medium Priority', 'Low Priority']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  suffixIcon: Icon(Icons.priority_high, color: Colors.red),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => priority = value!),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select priority' : null,
              ),
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: ['Under Review', 'Resolved', 'Pending']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Status',
                  suffixIcon: Icon(Icons.reviews_rounded, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => status = value!),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select status' : null,
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hearing Date',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.year}'
                        : 'Select Date',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
          child: Text(
            "Save Changes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Save logic here
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
