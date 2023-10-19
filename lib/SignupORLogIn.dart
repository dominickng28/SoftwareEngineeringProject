import 'package:flutter/material.dart';
import 'loginscreen.dart'; // Import the login screen
import 'SignupScreen.dart'; // Import the sign-up screen

class SignupORLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE4YOU'),
        backgroundColor: Color.fromRGBO(0, 45, 107, 0.992),
      ),
      backgroundColor: Color.fromRGBO(153, 206, 255, 0.996),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo Image
            Image.asset(
              'lib/assets/Live4youLine.png',
              width: 200, // Adjust the width as needed
              height: 100, // Adjust the height as needed
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(0, 255, 104, 104),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the sign-up screen
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
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
    );
  }
}
