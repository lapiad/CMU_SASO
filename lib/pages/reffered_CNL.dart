import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/summaryWidget.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/summarryReports.dart';
import 'package:flutter_application_1/pages/user_MGT.dart';
import 'package:flutter_application_1/pages/violation_logs.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getName() async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  ); // Replace with your FastAPI URL
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['first_name']);
    return data['first_name'];
  } else {
    // error message
    return "null";
  }
}

class RefferedCnl extends StatefulWidget {
  RefferedCnl({super.key});

  @override
  State<RefferedCnl> createState() => _RefferedCnlState();
}

class _RefferedCnlState extends State<RefferedCnl> {
  Future<String> getName() async {
    final box = GetStorage();
    final url = Uri.parse(
      '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
    ); // Replace with your FastAPI URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['first_name']);
      return data['first_name'];
    } else {
      // error message
      return "null";
    }
  }

  void _showAdminMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('Profile Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        PopupMenuItem(
          value: 'system',
          child: SizedBox(
            width: 300,
            height: 70,
            child: Text('System Settings', style: TextStyle(fontSize: 20)),
          ),
        ),
        PopupMenuItem(
          child: const Text("Sign Out", style: TextStyle(fontSize: 20)),
          onTap: () {
            final box = GetStorage();
            box.remove('user_id');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ],
    );

    if (result == 'signout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  final List<ViolationRecord> records = [
    ViolationRecord(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Under Review',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecord(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Referred',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
    ViolationRecord(
      studentName: 'Burnok Sual',
      studentId: '202298765',
      violation: 'Improper Uniform',
      status: 'Pending',
      reportedBy: 'Mang Tani',
      dateTime: '02-14-2025 11:11AM',
      priority: 'High',
      referredDate: '02-15-2025',
      hearingDate: '02-20-2025',
    ),
    ViolationRecord(
      studentName: 'Juan Dela Cruz',
      studentId: '202212345',
      violation: 'Smoking on Campus',
      status: 'Reviewed',
      reportedBy: 'Nadine Lustre',
      dateTime: '07-15-2025 5:30PM',
      priority: 'High',
      referredDate: '07-16-2025',
      hearingDate: '07-20-2025',
    ),
  ];

  Color getActionStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.yellow;
      case 'Reviewed':
        return Colors.green;
      case 'Referred':
        return Colors.red;
      case 'Under Review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'first offense':
        return Colors.yellowAccent;
      case 'second offense':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int countByStatus(String status) =>
      records.where((r) => r.status == status).length;

  bool filterFirstOffense = false;
  bool filterSecondOffense = false;
  bool filterThirdOffense = false;

  bool filterPending = false;
  bool filterUnderReview = false;
  bool filterReviewed = false;

  bool filterImproperUniform = false;
  bool filterLateAttendance = false;
  bool filterSeriousMisconduct = false;

  bool filterGuard = false;
  bool filterSASOOfficer = false;
  bool filterProfessor = false;
  bool filterAdministration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Referred To Council',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 40, color: Colors.white),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              sideMenuSize = sideMenuSize == 0.0 ? 350.0 : 0.0;
            });
          },
        ),
        actions: [
          Row(
            children: [
              FutureBuilder(
                future: getName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData ? snapshot.data! : "Loading...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 25,
                    color: Color.fromARGB(255, 10, 44, 158),
                  ),
                  onPressed: () => _showAdminMenu(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sideMenuSize != 0.0)
              SizedBox(
                width: sideMenuSize,
                height: 900,
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue[900]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: Image.asset(
                          'images/logos.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "  CMU_SASO DRMS",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'GENERAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: const Text(
                          'Dashboard',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Dashboard(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.list_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: const Text(
                          'Violation Logs',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViolationLogsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.pie_chart,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: const Text(
                          'Summary of Reports',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SummaryReportsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: const Text(
                          'Referred to Council',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RefferedCnl(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'ADMINISTRATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: const Text(
                          'User management',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => UserMgt()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 10.0),
                        SummaryWidget(
                          title: "Total Cases",
                          value: records.length.toString(),
                          subtitle: "Active Referrals",
                          icon: Icons.cases_outlined,
                          iconColor: const Color.fromARGB(255, 33, 31, 196),
                        ),

                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Under Review",
                          value: countByStatus("Under Review").toString(),
                          subtitle: "Being Evaluated",
                          icon: Icons.reviews,
                          iconColor: const Color.fromARGB(255, 24, 206, 33),
                        ),

                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Reviewed",
                          value: countByStatus("Reviewed").toString(),
                          subtitle: "Finalized Cases",
                          icon: Icons.check_circle_outline,
                          iconColor: const Color.fromARGB(255, 97, 77, 197),
                        ),

                        const SizedBox(width: 30.0),
                        SummaryWidget(
                          title: "Pending",
                          value: countByStatus("Pending").toString(),
                          subtitle: "Awaiting Decision",
                          icon: Icons.pending,
                          iconColor: const Color.fromARGB(255, 44, 71, 194),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText:
                                  'Search by student name, student ID, or violation...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showFilterDialog();
                          },
                          icon: const Icon(Icons.filter_list),
                          label: const Text(
                            "Filter By",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 1900,
                      height: 700,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Student Name',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Student ID',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Violation',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Priority',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Reported By',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Referred Date',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Hearing Date',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: records.map((record) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    record.studentName,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    record.studentId,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    record.violation,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        record.priority ?? '',
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      record.priority ?? '',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getActionStatusColor(
                                        record.status,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      record.status,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    record.reportedBy,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    record.referredDate ?? '-',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    record.hearingDate ?? '-',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 25,
                                        ),
                                        tooltip: 'View',
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 25),
                                        tooltip: 'Documents',
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 25),
                                        tooltip: 'Edit',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter Dialog",
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              left: 1325,
              top: 33,
              child: Material(
                type: MaterialType.transparency,
                child: AlertDialog(
                  title: const Text('Filter Options'),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Status'),
                          CheckboxListTile(
                            title: const Text("First Offense"),
                            value: filterFirstOffense,
                            onChanged: (val) {
                              setState(() {
                                filterFirstOffense = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Second Offense"),
                            value: filterSecondOffense,
                            onChanged: (val) {
                              setState(() {
                                filterSecondOffense = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Third Offense"),
                            value: filterThirdOffense,
                            onChanged: (val) {
                              setState(() {
                                filterThirdOffense = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Action Status'),
                          CheckboxListTile(
                            title: const Text("Pending"),
                            value: filterPending,
                            onChanged: (val) {
                              setState(() {
                                filterPending = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Under Review"),
                            value: filterUnderReview,
                            onChanged: (val) {
                              setState(() {
                                filterUnderReview = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Reviewed"),
                            value: filterReviewed,
                            onChanged: (val) {
                              setState(() {
                                filterReviewed = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Violation Type'),
                          CheckboxListTile(
                            title: const Text("Improper Uniform"),
                            value: filterImproperUniform,
                            onChanged: (val) {
                              setState(() {
                                filterImproperUniform = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Late Attendance"),
                            value: filterLateAttendance,
                            onChanged: (val) {
                              setState(() {
                                filterLateAttendance = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Serious Misconduct"),
                            value: filterSeriousMisconduct,
                            onChanged: (val) {
                              setState(() {
                                filterSeriousMisconduct = val ?? false;
                              });
                            },
                          ),
                          const Divider(),
                          const Text('Reported By'),
                          CheckboxListTile(
                            title: const Text("Guard"),
                            value: filterGuard,
                            onChanged: (val) {
                              setState(() {
                                filterGuard = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("SASO Officer"),
                            value: filterSASOOfficer,
                            onChanged: (val) {
                              setState(() {
                                filterSASOOfficer = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Professor"),
                            value: filterProfessor,
                            onChanged: (val) {
                              setState(() {
                                filterProfessor = val ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Administration"),
                            value: filterAdministration,
                            onChanged: (val) {
                              setState(() {
                                filterAdministration = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          filterFirstOffense = false;
                          filterSecondOffense = false;
                          filterThirdOffense = false;
                          filterPending = false;
                          filterUnderReview = false;
                          filterReviewed = false;
                          filterImproperUniform = false;
                          filterLateAttendance = false;
                          filterSeriousMisconduct = false;
                          filterGuard = false;
                          filterSASOOfficer = false;
                          filterProfessor = false;
                          filterAdministration = false;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ViolationRecord {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String? priority;
  final String? referredDate;
  final String? hearingDate;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
    this.priority,
    this.referredDate,
    this.hearingDate,
  });
}
