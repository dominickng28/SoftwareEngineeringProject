import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'friend_service.dart';
import 'user_data.dart';
import 'post.dart';
import 'home_feed.dart';
import 'dart:async';

class MySearch extends StatefulWidget {
  MySearch({super.key, required this.title});
  final FriendService _friendService = FriendService();

  final String title;

  Widget buildFriendRequestsSection() {
    return StreamBuilder<List<String>>(
      stream: _friendService.receivedFriendRequestsStream(UserData.userName),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> friendRequests = snapshot.data!;
          if (friendRequests.isEmpty) {
            // if no friends
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
                    // check if user exists
                    var userFriend =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    // get profile pic
                    var profilePicUrl =
                        (userFriend['profile_picture'] ?? '').isEmpty
                            ? 'lib/assets/default-user.jpg'
                            : userFriend['profile_picture'];
                    if (profilePicUrl == 'lib/assets/default-user.jpg') {
                      imageProvider = AssetImage(profilePicUrl);
                    } else {
                      imageProvider = NetworkImage(profilePicUrl);
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      // Make Profile Pic a button
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
                          )),
                      // user's username
                      title: Text(
                        friendRequests[index],
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
                          // Accept friend button
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _friendService.acceptFriendRequest(
                                  UserData.userName, friendRequests[index]);
                            },
                          ),
                          const SizedBox(width: 10.0),
                          // decline friend button
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _friendService.cancelFriendRequest(
                                  friendRequests[index], UserData.userName);
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
          return const Center(child: Text('Error loading friend requests'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  final MySearch mySearch = MySearch(title: 'Title');
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  final UserData userData = UserData(FirebaseFirestore.instance);
  final StreamController<List<String>> _usernameStream = 
    StreamController<List<String>>();
  // posts list for "the rest of the world" portion
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchMostLikedPostData();
  }

  Widget buildFriendRequestsSection() {
  return StreamBuilder<List<String>>(
    stream: _friendService.receivedFriendRequestsStream(UserData.userName),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<String> friendRequests = snapshot.data!;
      if (friendRequests.isEmpty) {
          // if no friends
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
                  // check if user exists
                  var userFriend = userSnapshot.data!.data() as Map<String, dynamic>;
                  // get profile pic
                  var profilePicUrl = (userFriend['profile_picture'] ?? '').isEmpty ? 'lib/assets/default-user.jpg' : userFriend['profile_picture'];
                  if (profilePicUrl == 'lib/assets/default-user.jpg') {
                    imageProvider = AssetImage(profilePicUrl);
                  } else {
                    imageProvider = NetworkImage(profilePicUrl);
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                    // Make Profile Pic a button
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
                    // user's username
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
                      // Accept friend button
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
                      // decline friend button
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
  );
  }

  StreamController<List<String>> usernameStreamController =
      StreamController<List<String>>();
  @override
  void dispose() {
    usernameStreamController.close();
    super.dispose();
  }

  void fetchMostLikedPostData() async {
    // Fetch friends list
    await userData.populateFriendsList();
    List<String>? userAndFriendList = UserData.friends;

    // Add the current user's username to the list
    userAndFriendList?.add(UserData.userName);
    // Access Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // Fetch most liked posts
    QuerySnapshot querySnapshot = await firestoreInstance
        .collection('posts')
        .where('username', whereNotIn: userAndFriendList)
        .limit(12)
        .get();

    // Convert each document to a Post object and add it to the posts list
    List<Post> mostLikedPostData = querySnapshot.docs
        .map((doc) => Post.fromFirestore(doc, doc.id))
        .toList();

    // Sort posts by timestamp
    mostLikedPostData.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) {
      setState(() {
        posts = mostLikedPostData;
      });
    }
  }

  Widget _buildpostGrid(List<Post> postList) {
    if (postList.isEmpty) {
      return const SizedBox.shrink(); // Returns nothing if postList is empty
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: postList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          // Make profile pic a button
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        1.5, // Set the width to 80% of screen width
                    child: PostCard(post: postList[index]),
                  ),
                );
              },
            );
          },
          //Container for the post list
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
                postList[index].imageUrl,
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Return a local asset image if there's an error
                  return Image.asset(
                    'lib/assets/chris.jpg',
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  

  Future<void> _searchByUsername(String username) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (userDoc.exists) {
      List<String> usernames = [username];
      _usernameStream.add(usernames);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No user found with the username $username'),
        ),
      );
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                  onSubmitted: (String value) async {
                    // Perform the search when Enter key is pressed
                    await _searchByUsername(value);
                  },
                  decoration: InputDecoration(
                    labelText: "Search for a username",
                    labelStyle: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        // add the searched username to a list to generate the profile list
                        await _searchByUsername(_searchController.text);
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                )),
            // Generate searched user profile list
            StreamBuilder<List<String>>(
              stream: _usernameStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> userSearch = snapshot.data!;
                  if (userSearch.isEmpty) {
                    return const SizedBox();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userSearch.length,
                    itemBuilder: (context, index) {
                      DocumentReference userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(userSearch[index]);
                      ImageProvider imageProvider;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: userDoc.snapshots(),
                        builder: (context, userSnapshot) {
                          // check if user exist
                          if (userSnapshot.hasData) {
                            var userFriend = userSnapshot.data!.data()
                                as Map<String, dynamic>;
                            // get profile pic
                            var profilePicUrl =
                                (userFriend['profile_picture'] ?? '').isEmpty
                                    ? 'lib/assets/default-user.jpg'
                                    : userFriend['profile_picture'];
                            if (profilePicUrl ==
                                'lib/assets/default-user.jpg') {
                              imageProvider = AssetImage(profilePicUrl);
                            } else {
                              imageProvider = NetworkImage(profilePicUrl);
                            }

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              // Make profile pic a button
                              leading: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyUserProfilePage(
                                          title: 'User Profile',
                                          profileUserName: userSearch[index],
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
                                  )),
                              // user's username
                              title: Text(
                                userSearch[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'DNSans',
                                  color: Colors.white,
                                ),
                              ),
                              // Add friend button
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _friendService.sendFriendRequest(
                                      UserData.userName, userSearch[index]);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Friend Request Sent')),
                                  );
                                },
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text(userSearch[index]),
                              subtitle: const CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading user'));
                } else {
                  return const SizedBox();
                }
              },
            ),

            //Generate Friend Request List
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
            mySearch.buildFriendRequestsSection(),
            //Recommended text
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
            //Recommendation List
            StreamBuilder<List<String>>(
              stream: _friendService.friendsOfFriendsStream(UserData.userName),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.connectionState == ConnectionState.done &&
                    (!snapshot.hasData || snapshot.data!.isEmpty)) {
                  // If no friends
                  return const Text(
                    'No Recommendations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(115, 255, 255, 255),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Display a loading indicator while waiting for data
                } else if (snapshot.connectionState == ConnectionState.done) {
                  List<String> friendsFriends = snapshot.data!;

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
                            var userFriend = userSnapshot.data!.data()
                                as Map<String, dynamic>;
                            // get Profile Pic
                            var profilePicUrl =
                                (userFriend['profile_picture'] ?? '').isEmpty
                                    ? 'lib/assets/default-user.jpg'
                                    : userFriend['profile_picture'];
                            if (profilePicUrl ==
                                'lib/assets/default-user.jpg') {
                              imageProviderRecommended =
                                  AssetImage(profilePicUrl);
                            } else {
                              imageProviderRecommended =
                                  NetworkImage(profilePicUrl);
                            }
                            // Generate the Recommended Profile List
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
                } else {
                  return const SizedBox();
                }
              },
            ),
            // The rest of the world text
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'The Rest of The World',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'DNSans',
                  color: Colors.white,
                ),
              ),
            ),
            //Global Post
            _buildpostGrid(posts),
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
        // Make Profile Pic a button
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
        // User's username text
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            fontFamily: 'DNSans',
            color: Colors.white,
          ),
        ),
        // Send Friend Request button
        trailing: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          onPressed: onPressed ??
              () {
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
