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
    'woolly', 'lib/assets/default-user.jpg', 'IFVJ7s8mhsbt1n7I2d5D', '', 'Run', 'run run run', '', DateTime(2023,11, 28, 10, 40, 28), 1, ['woolly'], 
    'https://firebasestorage.googleapis.com/v0/b/live-4-you.appspot.com/o/posts%2FCAP6097955994966011154.jpg?alt=media&token=4f6a7573-66d6-4593-96fa-1f803cf218e8'
  );

  await tester.runAsync(() async {
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
testWidgets('Spamming Like Button', (WidgetTester tester) async {
  // Create a mock post
  Post mockPost = Post(
    'woolly', 'lib/assets/default-user.jpg', 'IFVJ7s8mhsbt1n7I2d5D', '', 'Run', 'run run run', '', DateTime(2023, 11, 28, 10, 40, 28), 1, ['woolly'], 
    'https://firebasestorage.googleapis.com/v0/b/live-4-you.appspot.com/o/posts%2FCAP6097955994966011154.jpg?alt=media&token=4f6a7573-66d6-4593-96fa-1f803cf218e8'
  );

  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostCard(post: mockPost),
        ),
      ),
    );

    // Find the like button in the post
    Finder likeButtonFinder = find.byIcon(Icons.favorite);

    // Simulate spamming the like button multiple times
    for (int i = 0; i < 10; i++) {
      // Tap the like button
      await tester.tap(likeButtonFinder);

      // Rebuild the widget after the tap
      await tester.pump();

      // Delay to simulate user interaction frequency
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Verify the final state after spamming
    bool isLiked = (mockPost.likeCount % 2) == 1; // Toggle like state
    expect(find.byIcon(isLiked ? Icons.favorite : Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(isLiked ? Icons.favorite_rounded : Icons.favorite), findsNothing);
  });
});
}