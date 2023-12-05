import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/main.dart';

void main() async {
  // Initialize Firebase before running the test
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  testWidgets('Navigate to Sign Up screen from Login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(),
    ));

    // Verify that the login screen UI is rendered correctly.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);

    // Tap the "Don't have an account? Sign Up" button.
    await tester.tap(find.text("Don't have an account? Sign Up"));

    // Wait for animations to complete.
    await tester.pumpAndSettle();

    // Verify that the navigation to the sign-up screen occurred.
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
