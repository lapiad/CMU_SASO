import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  DateTime? startDate;
  DateTime? endDate;
  String? reportType;

  final List<String> reportTypes = ['Summary', 'Detailed', 'Violations Only'];

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Generate Weekly Report"),
      content: SizedBox(
        height: 300,
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Report Configuration",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// Start Date
            TextFormField(
              readOnly: true,
              onTap: () => _pickDate(context, true),
              decoration: InputDecoration(
                labelText: "Start Date",
                hintText: "Pick start date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: startDate != null
                    ? "${startDate!.toLocal()}".split(' ')[0]
                    : '',
              ),
            ),
            const SizedBox(height: 30),

            /// End Date
            TextFormField(
              readOnly: true,
              onTap: () => _pickDate(context, false),
              decoration: InputDecoration(
                labelText: "End Date",
                hintText: "Pick end date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: endDate != null
                    ? "${endDate!.toLocal()}".split(' ')[0]
                    : '',
              ),
            ),
            const SizedBox(height: 30),

            /// Report Type
            DropdownButtonFormField<String>(
              value: reportType,
              decoration: InputDecoration(
                labelText: "Report Type",
                border: OutlineInputBorder(),
              ),
              items: reportTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  reportType = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Handle report generation
            print("Generating report...");
          },
          icon: Icon(Icons.download, color: Colors.white),
          label: Text(
            "Generate & Download Report",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
        ),
      ],
    );
  }
}
