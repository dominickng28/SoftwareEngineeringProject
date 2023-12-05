import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/firestore_service.dart';
import 'package:live4you/post_signup_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/user_data.dart';
import 'main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginScreen({Key? key, required this.auth}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  //final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  BuildContext? _scaffoldContext;

  Future<void> _loginWithGoogle() async {
    try {
      // Sign out the current user
      await widget._googleSignIn.signOut();

      // Now call signIn()
      GoogleSignInAccount? googleUser = await widget._googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

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
          Navigator.of(_scaffoldContext!).pushReplacement(
            MaterialPageRoute(builder: (context) => const PostSignUpScreen()),
          );
        } else {
          // This is an existing user, fetch their username from Firestore
          String? username =
              await firestoreService.getUsernameFromEmail(user!.email!);

          UserData.userName = username!;
          Navigator.of(_scaffoldContext!).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _login() async {
    try {
      // Use the FirebaseAuth instance passed in
      final FirebaseAuth auth = widget.auth;

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
        Navigator.of(_scaffoldContext!).pushReplacement(
          // Use the stored Scaffold context here
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
          // Use the stored Scaffold context here
          const SnackBar(content: Text('Unable to sign in. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        // Use the stored Scaffold context here
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Set text to bold
            fontSize: 24, // Set font size to a larger value
            fontFamily: 'DMSans',
          ),
        ),
        backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      ),
      backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context; // Store Scaffold context
          return Center(
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
                          border: Border.all(
                              color: const Color.fromARGB(255, 255, 255, 255)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          key: Key('emailField'),
                          controller: _emailController,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'DNSans'),
                          decoration: const InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(
                                color: Colors.white, fontFamily: 'DNSans'),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person,
                                color:
                                    Colors.white), // Add an icon as the prefix
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
                          key: Key('passwordField'),
                          controller: _passwordController,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'DNSans'),
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                color: Colors.white, fontFamily: 'DNSans'),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock,
                                color:
                                    Colors.white), // Add an icon as the prefix
                          ),
                        ),
                      ),

                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        key: Key("loginButton"),
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
                      const SizedBox(height: 5.0),

                      ElevatedButton(
                        key: Key("loginGoogleButton"),
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Change button color
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login with Google",
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
                                builder: (context) => SignUpScreen()),
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
                )),
          );
        },
      ),
    );
  }
}
