// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:flutter/material.dart';
// import 'package:live4you/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:live4you/firestore_service.dart';
// import '../lib/main.dart';
// import '../lib/firebase_init_for_testing.dart';
// import 'package:firebase_core/firebase_core.dart';

// class FirebaseAuthWrapper {
//   final FirebaseAuth _auth;

//   FirebaseAuthWrapper(this._auth);

//   Future<UserCredential> signInWithEmailAndPassword(
//       {required String email, required String password}) {
//     return _auth.signInWithEmailAndPassword(email: email, password: password);
//   }
// }

// class MockFirebaseAuth extends Mock implements FirebaseAuth {
//   @override
//   Future<UserCredential> signInWithEmailAndPassword(
//       {required String email, required String password}) async {
//     return Future.value(MockUserCredential());
//   }
// }

// class MockFirestoreService extends Mock implements FirestoreService {}

// class MockUserCredential extends Mock implements UserCredential {
//   @override
//   User get user => MockUser();
// }

// class MockUser extends Mock implements User {
//   @override
//   String get uid => '0';
//   @override
//   String get email => 'email@test.com';
// }

// void main() {
//   setupFirebaseAuthMocks();
//   group('LoginScreen', () {
//     late MockFirestoreService mockFirestoreService;
//     late MockFirebaseAuth mockAuth;

//     setUpAll(() async {
//       WidgetsFlutterBinding.ensureInitialized();
//       await Firebase.initializeApp();

//       mockFirestoreService = MockFirestoreService();
//       mockAuth = MockFirebaseAuth();
//     });

//     testWidgets('renders LoginScreen', (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//         home: LoginScreen(auth: mockAuth),
//       ));

//       expect(find.byType(LoginScreen), findsOneWidget);
//     });

//     testWidgets('successful login navigates to MainScreen',
//         (WidgetTester tester) async {
//       when(mockAuth.signInWithEmailAndPassword(
//         email: 'email@test.com',
//         password: 'password',
//       )).thenAnswer((_) async => MockUserCredential());

//       when(mockFirestoreService.getUsernameFromEmail('email@test.com'))
//           .thenAnswer((_) async => 'testUser');

//       await tester.pumpWidget(MaterialApp(
//         home: LoginScreen(auth: mockAuth),
//       ));

//       await tester.enterText(find.byKey(const Key('emailField')), 'email@test.com');
//       await tester.enterText(find.byKey(const Key('passwordField')), 'password');
//       await tester.tap(find.byKey(const Key('loginButton')));

//       await tester.pumpAndSettle();

//       expect(find.byType(MainScreen), findsOneWidget);
//     });
//   });
// }
