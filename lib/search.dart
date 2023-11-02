import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'profile_screen.dart';
import 'main.dart';
import 'friend_service.dart';
import 'user_data.dart';

class MySearch extends StatefulWidget {
  const MySearch({super.key, required this.title});

  final String title;

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search for a username",
                suffixIcon: IconButton(
                  onPressed: () async {
                    String username = _searchController.text;
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(username)
                        .get();
                    if (userDoc.exists) {
                      // If the user exists, send a friend request
                      _friendService.sendFriendRequest(
                          UserData.userName, username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Friend request sent to $username')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'No user found with the username $username')),
                      );
                    }
                  },
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _friendService
                  .receivedFriendRequestsStream(UserData.userName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> friendRequests = snapshot.data!;
                  return ListView.builder(
                    itemCount: friendRequests.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(friendRequests[index]),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Accept the friend request
                            _friendService.acceptFriendRequest(
                                UserData.userName, friendRequests[index]);
                          },
                          child: Text('Accept'),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading friend requests'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
