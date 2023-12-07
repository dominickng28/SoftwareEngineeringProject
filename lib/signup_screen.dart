import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live4you/firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:live4you/user_data.dart';
import 'post_signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService firestoreService = FirestoreService();
  BuildContext? _scaffoldContext;

  Future<void> _createAccountWithGoogle(BuildContext context) async {
    try {
      // Sign out the current user
      await _googleSignIn.signOut();

      // Now call signIn()
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        // Check if the user is new or existing
        if (userCredential.additionalUserInfo!.isNewUser) {
          // This is a new user, so you need to set up their account

          // Get the current timestamp
          Timestamp joinedTimestamp = Timestamp.now();

          // Here you might want to ask the user for a username or other info
          // For now, let's just use the part of their email before '@' as a default username
          String defaultUsername = user!.email!.split('@')[0];

          // Add the user to Firestore
          await firestoreService.addUserToFirestore(
            defaultUsername,
            user.email!,
            user.uid,
            joinedTimestamp,
          );

          UserData.userName = defaultUsername;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PostSignUpScreen()),
          );
        } else {
          // This is an existing user, fetch their username from Firestore
          String? username =
              await firestoreService.getUsernameFromEmail(user!.email!);

          UserData.userName = username!;
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(profile: UserData.userName, index: 0)),
          );
        }
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    _scaffoldContext = context;

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
              _scaffoldContext!,
              MaterialPageRoute(
                builder: (context) => const PostSignUpScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
              const SnackBar(content: Text('Email is already in use.')),
            );
          }
        } else {
          ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
            const SnackBar(content: Text('Username is already in use.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
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
        backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      ),
      backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
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
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
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
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 15,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
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
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
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
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
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
                const SizedBox(height: 3.0),
                /*ElevatedButton(
                  onPressed: () => _createAccountWithGoogle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 255, 255, 255), // Change button color
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sign Up with Google",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
