import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserManagementPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class User {
  final String name;
  final String email;
  final String office;
  final String role;
  final String status;

  User({
    required this.name,
    required this.email,
    required this.office,
    required this.role,
    required this.status,
  });
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> users = [
    User(
      name: "Nadine Lustre",
      email: "nadine.l@cityofmalabonuniversity.edu.ph",
      office: "Student Affairs Services Office",
      role: "SASO Officer",
      status: "Active",
    ),
    User(
      name: "Mang Tani",
      email: "tani.guard@cityofmalabonuniversity.edu.ph",
      office: "Safety and Security Office",
      role: "Guard",
      status: "Active",
    ),
    User(
      name: "Sarah Geronimo",
      email: "sarahg@cityofmalabonuniversity.edu.ph",
      office: "Safety and Security Office",
      role: "Guard",
      status: "Active",
    ),
    User(
      name: "Admin User",
      email: "admin@cityofmalabonuniversity.edu.ph",
      office: "Student Affairs Services Office",
      role: "Admin",
      status: "Active",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.grey[800],
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSummaryCard(
                  "Total Users",
                  users.length.toString(),
                  Colors.purple[100]!,
                ),
                buildSummaryCard(
                  "Active Users",
                  users.where((u) => u.status == "Active").length.toString(),
                  Colors.green[100]!,
                ),
                buildSummaryCard(
                  "SASO Officers",
                  users
                      .where((u) => u.role == "SASO Officer")
                      .length
                      .toString(),
                  Colors.blue[100]!,
                ),
                buildSummaryCard(
                  "Admins",
                  users.where((u) => u.role == "Admin").length.toString(),
                  Colors.deepPurple[100]!,
                ),
              ],
            ),
            SizedBox(height: 20),

            // User List
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(user.name[0])),
                      title: Text(user.name),
                      subtitle: Text("${user.email}\n${user.office}"),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(user.role),
                            backgroundColor: Colors.blue[100],
                          ),
                          SizedBox(width: 6),
                          Chip(
                            label: Text(user.status),
                            backgroundColor: Colors.green[100],
                          ),
                          SizedBox(width: 6),
                          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
