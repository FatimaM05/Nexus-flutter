import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "../auth/signup.dart";
import '../home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(160, 156, 176, 100),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Logo.png', 
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign in to your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please enter your credentials to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Login Form
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // Email login
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password with toggle eye
                  TextField(
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.blueGrey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Color.fromRGBO(182, 184, 184, 100),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        splashRadius: 24, 
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password', style: TextStyle(color: Color.fromRGBO(63, 49, 116, 100),)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // Save login state 
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', true);

                          // Get the username from Firebase
                          String username = userCredential.user?.displayName ?? "User";

                          // Save login state locally
                          await prefs.setBool('isLoggedIn', true);
                          await prefs.setString('username', username); 

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage(username: username)),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(160, 156, 176, 100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Google signin thingy
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton.icon(
                      onPressed: (){
                          // gotta add logic here ughhh
                      },
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have account? ", style: TextStyle(color: Color.fromRGBO(182, 182, 184, 100))),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Color.fromRGBO(63, 49, 116, 100),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
