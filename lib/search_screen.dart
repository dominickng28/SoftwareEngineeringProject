import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_screen.dart';
import 'friend_service.dart';
import 'user_data.dart';
import 'friend.dart';

class MySearch extends StatefulWidget {
  const MySearch({super.key, required this.title});

  final String title;

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();


Widget _buildRandomUserGrid() {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
    ),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 12,  // YOU CAN ADJUST THE NUMBER OF ITEMS IN THE GRID
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          // HANDLE THE CLICK EVENT, E.G., NAVIGATE TO A USER PROFILE PAGE
          print('Clicked on random user profile $index');
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/live-4-you.appspot.com/o/pfp2.jpeg?alt=media&token=fb4ea6b5-29d1-441d-a026-d201fd798dd7',
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            color: Color.fromARGB(248, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromARGB(251, 0, 0, 0),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(248, 0, 0, 0),
      
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search for a username",
                  labelStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'DNSans'),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      String username = _searchController.text;
                      DocumentSnapshot userDoc = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(username)
                          .get();
                      if (userDoc.exists) {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyUserProfilePage(
                              title: 'User Profile',
                              profileUserName: username,
                            ),
                          ),
                        ); 
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'No user found with the username $username'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // WIP
            // TO ADD THE PROFILE LIST THING
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Friend Requests',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'DNSans',
                  color: Colors.white,
                ),
              ),
            ),
            StreamBuilder<List<String>>(
              stream: _friendService.receivedFriendRequestsStream(UserData.userName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> friendRequests = snapshot.data!;
                if (friendRequests.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Friend Requests',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'DNSans',
                          color: Color.fromARGB(115, 255, 255, 255),
                        ),
                      ),
                    );
                  }  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friendRequests.length,
                    itemBuilder: (context, index) {
                      DocumentReference userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendRequests[index]);
                      ImageProvider imageProvider;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: userDoc.snapshots(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            var userFriend = userSnapshot.data!.data() as Map<String, dynamic>;
                            var profilePicUrl = (userFriend['profile_picture'] ?? '').isEmpty ? 
                            'lib/assets/default-user.jpg' : userFriend['profile_picture'];
                            if (profilePicUrl == 'lib/assets/default-user.jpg') {
                              imageProvider = AssetImage(profilePicUrl);
                            } else {
                              imageProvider = NetworkImage(profilePicUrl);
                            }
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyUserProfilePage(
                                        title: 'User Profile',
                                        profileUserName: friendRequests[index],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: SizedBox(
                                    width: 60.0,
                                    height: 60.0,
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                                ),
                              title: Text(friendRequests[index], 
                                style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'DNSans',
                                color: Colors.white,
                              ),
                              ), 
                              trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _friendService.acceptFriendRequest(
                                      UserData.userName,
                                      friendRequests[index]);
                                  },
                                ),
                                const SizedBox(width: 10.0),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _friendService.cancelFriendRequest(
                                      UserData.userName,
                                      friendRequests[index]);
                                  },
                                ),
                              ],
                            ),
                          );

                          } else {
                            return ListTile(
                              title: Text(friendRequests[index]),
                              subtitle: const CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading friend requests'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Recommended',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'DNSans',
                  color: Colors.white,
                ),
              ),
            ),
            //Recommended List WIP
            StreamBuilder<List<String>>(
              stream: _friendService.friendsOfFriendsStream(UserData.userName),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No Recommendations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(115, 255, 255, 255),
                    ),
                  );
                } else {
                  List<String> friendsFriends = snapshot.data!;
                  if (friendsFriends.isEmpty) {
                    return const Text(
                      'No Recommendations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'DNSans',
                        color: Color.fromARGB(115, 255, 255, 255),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friendsFriends.length,
                    itemBuilder: (context, index) {
                      DocumentReference userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendsFriends[index]);
                      ImageProvider imageProviderRecommended;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: userDoc.snapshots(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            var userFriend = userSnapshot.data!.data() as Map<String, dynamic>;
                            var profilePicUrl = (userFriend['profile_picture'] ?? '').isEmpty
                                ? 'lib/assets/default-user.jpg'
                                : userFriend['profile_picture'];
                            if (profilePicUrl == 'lib/assets/default-user.jpg') {
                              imageProviderRecommended = AssetImage(profilePicUrl);
                            } else {
                              imageProviderRecommended = NetworkImage(profilePicUrl);
                            }

                            return ProfileList(
                              imageProvider: imageProviderRecommended,
                              userName: friendsFriends[index],
                            );
                          }
                          return const SizedBox(); // Handle case when there's no data yet
                        },
                      );
                    },
                  );
                }
              },
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), 
              child: Text('The Rest of The World', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'DNSans',
                color: Colors.white,
                ),
              ),
            ), 
            _buildRandomUserGrid(), 
        ],
      ),
    ),

  );
  }
}

class ProfileList extends StatelessWidget {
  final ImageProvider imageProvider;
  final String userName;
  final Function()? onPressed;
  final FriendService _friendService = FriendService();

  ProfileList({
    super.key,
    required this.imageProvider,
    required this.userName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 400,
        maxHeight: 200,
      ),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 4.0,
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyUserProfilePage(
                  title: 'User Profile',
                  profileUserName: userName,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: SizedBox(
              width: 60.0,
              height: 60.0,
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            fontFamily: 'DNSans',
            color: Colors.white,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          onPressed: onPressed ?? () {
            _friendService.sendFriendRequest(UserData.userName, userName);
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend Request Sent')),
          );
          },
        ),
      ),
    );
  }
}
