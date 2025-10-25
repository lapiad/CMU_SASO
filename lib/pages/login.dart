import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/Schoolguard.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void _onItemTapped(BuildContext context) async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/users/${box.read('user_id')}',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    box.write('user_details', data);
    if (data['role'] == 'guard') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchoolGuardHome()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }
}

bool isloading = false;

Future<String?> loginUser(String username, String password) async {
  final box = GetStorage();
  final url = Uri.parse(
    '${GlobalConfiguration().getValue("server_url")}/login',
  );
  Map<String, String> body = {'username': username, 'password': password};
  Map<String, String> headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    box.write('user_id', data['user_id']);
    return data['message'];
  } else {
    return null;
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0033A0), Color(0xFF005BBB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LoginPage(title: 'Login Page'),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          width: 500,
          height: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20.0),
              Image.asset('images/logos.png', height: 100.0, width: 100.0),
              const SizedBox(height: 16),
              const Text(
                'CMU SASO',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0033A0),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Disciplinary Records Management System',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0033A0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final username = usernameController.text;
                    final password = passwordController.text;

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter both username and password.',
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isloading = true;
                    });
                    final token = await loginUser(username, password);
                    setState(() {
                      isloading = false;
                    });
                    if (token != null) {
                      _onItemTapped(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login failed. Please try again.'),
                        ),
                      );
                    }
                  },
                  child: !isloading
                      ? const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
