import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/guardscreen.dart';
import 'package:flutter_application_1/pages/dashboard.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> passwordVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    passwordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 54, 113, 202),
                Color.fromARGB(255, 78, 196, 231),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80.0),
              Container(
                height: 600,
                width: 600,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 245, 242, 242),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.0),
                    Image.asset(
                      'images/logos.png',
                      height: 100.0,
                      width: 100.0,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'CMU-SASO Disciplinary Records\n         Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    const SizedBox(height: 20.0),
                    SizedBox(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 189),
                            child: Text(
                              "Username",
                              style: TextStyle(
                                color: Color.fromARGB(255, 2, 2, 2),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your Username',
                          suffix: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0),

                    const SizedBox(height: 20.0),
                    SizedBox(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 189),
                            child: Text(
                              "Password",
                              style: TextStyle(
                                color: Color.fromARGB(255, 2, 2, 2),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: passwordVisible,
                        builder: (context, value, child) {
                          return TextField(
                            controller: passwordController,
                            obscureText: !value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  passwordVisible.value = !value;
                                },
                              ),
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 40.0),

                    GestureDetector(
                      onTap: () {
                        print('Username: ${usernameController.text}');
                        print('Password: ${passwordController.text}');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Guardscreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 130, 153, 229),
                              Color.fromARGB(255, 46, 183, 207),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
