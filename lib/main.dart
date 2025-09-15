import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Guard_DSH.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';

void main() async {
  await GetStorage.init();
  await GlobalConfiguration().loadFromPath('cfg/app_settings.json');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Widget firstScreen(BuildContext context) {
  final box = GetStorage();
  if (box.read('user_id') != null) {
    if (box.read('user_role') == 'guard') {
      return SchoolGuardHome();
    } else {
      return Dashboard();
    }
  } else {
    return Login();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VioTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: firstScreen(context),
    );
  }
}
