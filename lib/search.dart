import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'user.dart';
import 'profile_screen.dart';
// import 'main.dart';
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
    // var userProfile;
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
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      String username = _searchController.text;
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
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
              ),
            ),

            StreamBuilder<List<String>>(
              stream: _friendService.receivedFriendRequestsStream(UserData.userName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> friendRequests = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: friendRequests.length,
                    itemBuilder: (context, index) {
                      DocumentReference userDoc =
                          FirebaseFirestore.instance.collection('users').doc(friendRequests[index]);
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
                                      _friendService.acceptFriendRequest(
                                          UserData.userName, friendRequests[index]);
                                    },
                                    child: const Text('Accept'),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      _friendService.cancelFriendRequest(
                                          friendRequests[index], UserData.userName);
                                    },
                                    child: const Text('Decline'),
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
                  return const Center(child: Text('Error loading friend requests'));
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
                  color: Colors.white,
                ),
              ),
            ),

            for (int i = 0; i < 3; i++)
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 400, maxHeight: 200),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      'https://source.unsplash.com/100x100/?random=$i', 
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ),

                  title: Text(
                    UserData.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // ignore: avoid_print
                      print('hello');
                    },
                  ),
                ),
              ),
              
            ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: 1, 
              itemBuilder: (context, index) {
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.3,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    constraints: const BoxConstraints(minHeight: 50, maxWidth: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: const DecorationImage(
                        image: NetworkImage('https://source.unsplash.com/100x100/?random='),
                        fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }, 
            ), 
          ],
        ),
      ),
    );
  }
}
