import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live4you/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Load Title', (WidgetTester tester) async {
        await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MySearch(title: 'Search'),
          ),
        ),
      );

      // Verify that the initial state shows 'Search' text at the top
      expect(find.text('Search').first, findsOneWidget);
    });
  });

  testWidgets('Load Text in Search Bar', (WidgetTester tester) async {
      await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySearch(title: 'Search'),
        ),
      ),
    );

    // Verify that the search box shows Search for a username
    expect(find.byType(TextField).first, findsOneWidget); 
    // Check for the text within the input decoration
    expect(find.text('Search for a username'), findsOneWidget); 
  });
});

testWidgets('Load Input as Text in Search Bar', (WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySearch(title: 'Search'),
        ),
      ),
    );

    // Enter text into the search bar
    await tester.enterText(find.byType(TextField).first, 'TestUser');

    // Verify that the entered text is present in the search bar
    expect(find.text('TestUser'), findsOneWidget);
  });
});

testWidgets('User not in database', (WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySearch(title: 'Search'),
        ),
      ),
    );
    
    String username = "TestUser";
    // Enter text into the search bar
    await tester.enterText(find.byType(TextField).first, username);

    // Simulate pressing the enter key
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(find.text(username), findsOneWidget);

    //await Future.delayed(const Duration(seconds: 2));

    // Verify that the Snackbar appears for a non-existent user
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('No user found with the username $username'), findsOneWidget); 
  });
}); 

testWidgets('User in database', (WidgetTester tester) async {
  await tester.runAsync(() async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySearch(title: 'Search'),
        ),
      ),
    );

    String username = "TestUser";
    await tester.enterText(find.byType(TextField).first, username);
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // Verify if the ListTile appears for the existing user
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text(username), findsOneWidget);
  });
});

}