import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:live4you/login_screen.dart';
import 'main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/firestore_service.dart';
import 'package:live4you/post_signup_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/user_data.dart';
import 'main.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:live4you/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/firestore_service.dart';
import 'main.dart';
import 'firebase_init_for_testing.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setupFirebaseAuthMocks();

  late MockGoogleSignIn googleSignIn;
  late MockFirebaseAuth firebaseAuth;
  late LoginScreen loginScreen;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    googleSignIn = MockGoogleSignIn();
    firebaseAuth = MockFirebaseAuth();
    loginScreen = LoginScreen(auth: firebaseAuth);
  });

  testWidgets('Google Sign-In success', (WidgetTester tester) async {
    // Simulate a successful sign-in.
    googleSignIn.signIn();

    await tester.pumpWidget(MaterialApp(home: loginScreen));
    await tester.tap(find.byKey(Key('loginGoogleButton')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Check that the widget has been replaced by the MainScreen.
    expect(find.byType(PostSignUpScreen),
        findsOneWidget); // Use the correct widget type
  });

  testWidgets('Google Sign-In cancelled', (WidgetTester tester) async {
    // Simulate a cancelled sign-in.
    googleSignIn.setIsCancelled(true);

    await tester.pumpWidget(MaterialApp(home: loginScreen));
    await tester.tap(find.byKey(Key('loginGoogleButton')), warnIfMissed: false);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Check that the widget is still showing the LoginScreen.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
