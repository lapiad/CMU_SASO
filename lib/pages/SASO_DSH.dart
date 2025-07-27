import 'package:flutter/material.dart';

class SasoDsh extends StatefulWidget {
  const SasoDsh({super.key});

  @override
  State<SasoDsh> createState() => _SasoDshState();
}

class _SasoDshState extends State<SasoDsh> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 248, 247, 247),
        title: Text("SASO_DASHBOARD"),
      ),
      backgroundColor: Color.fromARGB(255, 129, 128, 128),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 4, 8, 231),
        child: Column(
          children: [
            Image.asset(
              "Images/track.png",
              color: Colors.white,
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
            Text(
              "CMU SASO-DRMS",
              style: TextStyle(
                color: Color.fromARGB(255, 248, 245, 245),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Color.fromARGB(255, 250, 249, 249),
              ),
              title: Text(
                "D A S H B O A R D",
                style: TextStyle(color: Color.fromARGB(255, 247, 245, 245)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
