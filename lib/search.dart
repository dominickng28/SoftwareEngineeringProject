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
          title: Text(
            'Search',
            style: TextStyle(
              color: Color.fromARGB(249, 253, 208, 149), // Set text color to white
              fontWeight: FontWeight.bold, // Set text to bold
              fontSize: 24, // Set font size to a larger value
            ),
          ),
          backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
        ),
        backgroundColor: const Color.fromARGB(249, 253, 208, 149),

        
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyUserProfilePage(title: 'User Profile', profileUserName: username),
                        ),
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
                stream: _friendService.receivedFriendRequestsStream(UserData.userName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> friendRequests = snapshot.data!;

                    return ListView.builder(
                      itemCount: friendRequests.length,
                      itemBuilder: (context, index) {
                        // Retrieve user document for the friend request
                        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(friendRequests[index]);
                        ImageProvider imageProvider;
                        return StreamBuilder<DocumentSnapshot>(
                          stream: userDoc.snapshots(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.hasData) {
                              var userFriend = userSnapshot.data!.data() as Map<String, dynamic>;
                              var profilePicUrl = userFriend['profilePicURL'] ?? 'lib/assets/default-user.jpg';
                              if (profilePicUrl == 'lib/assets/default-user.jpg') {
                              imageProvider = AssetImage(profilePicUrl);
                            } else {
                              imageProvider = NetworkImage(profilePicUrl);
                            }
                              return ListTile(
                                leading: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyUserProfilePage(title: 'User Profile', profileUserName: friendRequests[index]),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 25.0,
                                  ),
                                ),
                                title: Text(friendRequests[index]),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Accept the friend request
                                        _friendService.acceptFriendRequest(UserData.userName, friendRequests[index]);
                                      },
                                      child: const Text('Accept'),
                                    ),
                                    const SizedBox(width: 10.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Decline the friend request
                                        _friendService.cancelFriendRequest(friendRequests[index], UserData.userName);
                                      },
                                      child: const Text('Decline'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Handle loading or error state for the user document
                              return ListTile(
                                title: Text(friendRequests[index]),
                                subtitle: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading friend requests'));
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
