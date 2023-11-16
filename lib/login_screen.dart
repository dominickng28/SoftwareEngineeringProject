import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/firestore_service.dart';
import 'package:live4you/home_feed.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/user_data.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

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
        UserData.userName = (await firestoreService
            .getUsernameFromEmail(_emailController.text))!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
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
        SnackBar(content: Text('Error error: ${e.toString()}')),
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
              fontFamily: 'DMSans',
            ),
          ),
          backgroundColor: Color.fromARGB(251, 17, 18, 18),
        ),
        backgroundColor: Color.fromARGB(251, 17, 18, 18),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo Image
                  Image.asset(
                    'lib/assets/Live4youWhite.png',
                    width: 350, // Adjust the width as needed
                    height: 350, // Adjust the height as needed
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(255, 255, 255, 255)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                            color: Colors.white, fontFamily: 'DNSans'),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person,
                            color: Colors.white), // Add an icon as the prefix
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                            color: Colors.white, fontFamily: 'DNSans'),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock,
                            color: Colors.white), // Add an icon as the prefix
                      ),
                    ),
                  ),

                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Change button color
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'DNSans',
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'DNSans',
                        color: Color.fromARGB(248, 255, 255,
                            255), // Change this to your preferred color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
