import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live4you/home_feed.dart';
import 'package:live4you/post.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Like and Unlike a Post', (WidgetTester tester) async {
  // Create a mock post
  Post mockPost = Post(
    // Populate the mock post with necessary data
    // ...
  );

  await tester.runAsync(() async {
    // Pump the PostCard widget with the mock post
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostCard(post: mockPost),
        ),
      ),
    );

    // Find the like button in the post
    Finder likeButtonFinder = find.byIcon(Icons.favorite);

    // Verify that the initial state of the like button is not liked
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Tap the like button
    await tester.tap(likeButtonFinder);

    // Rebuild the widget after the tap
    await tester.pump();

    // Verify that the post is now liked
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Tap the like button again to unlike the post
    await tester.tap(likeButtonFinder);

    // Rebuild the widget after the second tap
    await tester.pump();

    // Verify that the post is now unliked
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });
});
}