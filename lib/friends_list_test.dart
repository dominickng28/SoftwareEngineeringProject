// import 'friends_screen.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'mock.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:live4you/friend.dart';

// void main() {
//   setupFirebaseAuthMocks();
//   setUpAll(() async {
//     await Firebase.initializeApp();
//   });

//   testWidgets(
//       '"Friends" should display on the scaffold at the top of the screen',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: MyFriends(title: 'Friends'),
//         ),
//       ),
//     );

//     expect(find.text('Friends').first, findsOneWidget);
//   });

//   testWidgets('Display "No friends yet..."', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MyFriends(title: 'Friends'),
//       ),
//     );

//     expect(find.text('No friends yet...'), findsOneWidget);
//   });

//   testWidgets('Display list of friends', (WidgetTester tester) async {
//     List<Friend> mockFriends = [
//       Friend('Friend 1', 'lib/assets/default-user.jpg'),
//       Friend('Friend 2', 'lib/assets/default-user.jpg'),
//     ];

//     await tester.pumpWidget(
//       MaterialApp(
//         home: MyFriendsList(),
//       ),
//     );

//     MyFriendsListState state = tester.state(find.byType(MyFriendsList));
//     state.setState(() {
//       state.friendsList = mockFriends;
//       state.isLoading = false;
//     });
//     print('Friends list length: ${state.friendsList.length}');
//     expect(find.byType(FriendBar), findsNWidgets(mockFriends.length));
//   });
// }
