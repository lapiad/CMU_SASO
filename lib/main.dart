import 'package:flutter/material.dart';

import 'package:flutter_application_1/pages/violation_logs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VioTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ViolationLogsPage(),
    );
  }
}
