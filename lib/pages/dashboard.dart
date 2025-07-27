import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text("SASO DASHBOARD"),
      ),
      backgroundColor: Color.fromARGB(199, 141, 140, 140),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(209, 156, 154, 154),
        child: Column(
          children: const [
            DrawerHeader(child: Icon(Icons.favorite)),
            Text(
              "CMU SASO- DRMS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("D A S H B O A R D"),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("V I O L A T I O N  L O G S"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("S U M M A R Y R E P O R T"),
            ),
            ListTile(leading: Icon(Icons.logout), title: Text("L O G O U T")),
          ],
        ),
      ),
    );
  }
}
