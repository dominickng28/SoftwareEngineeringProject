import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/home_feed.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _login() async {
    try {
      // Get a reference to the auth service
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Sign in
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If the sign in was successful, navigate to the home screen
      if (userCredential.user != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MyFeed(title: 'Home')),
        );
      } else {
        // If the user is not signed in, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to sign in. Please try again.')),
        );
      }
    } catch (e) {
      // If an error occurs, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Login',
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
                height: 200, // Adjust the height as needed
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
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0), // Change button color
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Login",
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