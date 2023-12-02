import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live4you/firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:live4you/user_data.dart';
import 'post_signup_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _signUp() async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      try {
        // Check if the username is already in use
        final usernameSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .get();

        if (!usernameSnapshot.exists) {
          // Check if the email is already in use
          final emailSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          if (emailSnapshot.docs.isEmpty) {
            UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            User? user = userCredential.user;

            // Updating display name in Firebase Authentication
            user!.updateDisplayName(username).then((_) {
              user.reload(); // Ensure the user’s displayName is refreshed
            });
            UserData.userName = username;
            // Add the user to Firestore
            FirestoreService()
                .addUserToFirestore(username, email, user.uid, Timestamp.now());
            // Navigate to the PostSignUpScreen to set the bio etc.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostSignUpScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email is already in use.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username is already in use.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Set text to bold
            fontSize: 24,
            fontFamily: 'DNSans' // Set font size to a larger value
          ),
        ),
        backgroundColor: Color.fromARGB(251, 17, 18, 18),
      ),
      backgroundColor: Color.fromARGB(251, 17, 18, 18),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/assets/Live4youWhite.png',
                width: 300, // Adjust the width as needed
                height: 250, // Adjust the height as needed
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white,fontFamily: 'DNSans'),
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email,
                        color: Colors.white), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  maxLengthEnforcement: MaxLengthEnforcement.enforced, controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 12,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person,
                        color: Colors.white), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Add an icon as the prefix
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255))),
                child: TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock,
                        color: Colors.white), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Add an icon as the prefix
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255))),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  style: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock,
                        color: Colors.white), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _signUp(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // Change button color
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'DNSans',
                    color: Color.fromARGB(255, 0, 0, 0),
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
