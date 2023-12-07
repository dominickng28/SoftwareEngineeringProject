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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  BuildContext? _scaffoldContext;

  Future<void> _loginWithGoogle() async {
    try {
      await widget._googleSignIn.signOut();
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

        if (userCredential.additionalUserInfo!.isNewUser) {
          Timestamp joinedTimestamp = Timestamp.now();
          String defaultUsername = user!.email!.split('@')[0];

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
          String? username =
              await firestoreService.getUsernameFromEmail(user!.email!);

          UserData.userName = username!;
          Navigator.of(_scaffoldContext!).pushReplacement(
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      profile: UserData.userName,
                      index: 0,
                    )),
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
      final FirebaseAuth auth = widget.auth;
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        UserData.userName = (await firestoreService
            .getUsernameFromEmail(_emailController.text))!;
        Navigator.of(_scaffoldContext!).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  MainScreen(profile: UserData.userName, index: 0)),
        );
      } else {
        ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
          const SnackBar(content: Text('Unable to sign in. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'DMSans',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/Live4youWhite.png',
                      width: 325,
                      height: 225,
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        key: Key('emailField'),
                        controller: _emailController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'DNSans',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'DNSans',
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        key: Key('passwordField'),
                        controller: _passwordController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'DNSans',
                        ),
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'DNSans',
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      key: Key("loginButton"),
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.login, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'DNSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          key: Key("loginGoogleButton"),
                          onPressed: _loginWithGoogle,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'lib/assets/GoogleIcon.png',
                                height: 24,
                                width: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'DNSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          key: Key("loginAppleButton"),
                          onPressed: () {
                            print(
                                "Apple login functionality not implemented yet.");
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'lib/assets/appleIcon.png',
                                height: 24,
                                width: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Apple",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'DNSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'DNSans',
                          color: Color.fromARGB(248, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
