import 'package:flutter/material.dart';
import 'friend_service.dart';
import 'user_data.dart';
import 'search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'dart:async';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final FriendService _friendService = FriendService();
  final MySearch _mySearch = MySearch(title: "Search");
  int likesNotificationCount = 0;
  int friendRequestsNotificationCount = 0;
  
  @override
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
  Widget build(BuildContext context) {
    getCountOfFriendList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'DMSans',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            height: 4,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Friend Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'DMSans',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$friendRequestsNotificationCount',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 4,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          _mySearch.buildFriendRequestsSection(),
          const Divider(
            height: 4,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          buildNotificationSection(
            title: 'Likes',
            notificationCount: likesNotificationCount,
            titleTextStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getCountOfFriendList() async {
    List<String> friends =
        await _friendService.getFriendRequest(UserData.userName);
    setState(() {
      friendRequestsNotificationCount = friends.length;
    });
  }

  Widget buildNotificationSection({
    required String title,
    required int notificationCount,
    required TextStyle titleTextStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: titleTextStyle,
              ),
              GestureDetector(
                onTap: () {
                  showNotificationDropDown(title);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 4,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ],
    );
  }

  void showNotificationDropDown(String sectionTitle) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return buildDropDownContent();
      },
    );
  }

  Widget buildDropDownContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Remove placeholder text
        ],
      ),
    );
  }
}
