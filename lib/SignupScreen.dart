import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUp() {
    // Implement your sign-up logic here
    // You can use Firebase or any other authentication service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Sign Up',
    style: TextStyle(
      color: Colors.white, // Set text color to white
      fontWeight: FontWeight.bold, // Set text to bold
      fontSize: 24, // Set font size to a larger value
    ),
  ),
  backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
),
      backgroundColor: const Color.fromRGBO(153, 206, 255, 0.996),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Image
              Image.asset(
                'lib/assets/Live4youLine.png',
                width: 200, // Adjust the width as needed
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 14, 105, 171)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 14, 105, 171)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Change button color
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(0, 255, 104, 104),
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