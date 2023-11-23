import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'friend_service.dart';
import 'user_data.dart';

// import 'user.dart';

// import 'main.dart';




class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int likesNotificationCount = 0;
  int friendRequestsNotificationCount = 0;
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'DMSans',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFriendRequestsSection(),
          Divider(
            height: 4,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          buildNotificationSection(
            title: 'Likes',
            notificationCount: likesNotificationCount,
            titleTextStyle: TextStyle(
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

  Widget buildFriendRequestsSection() {
    return StreamBuilder<List<String>>(
      stream: _friendService.receivedFriendRequestsStream(UserData.userName),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> friendRequests = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildNotificationSection(
                title: 'Friend Requests',
                notificationCount: friendRequests.length,
                titleTextStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'DMSans',
                ),
              ),
              // Inside the buildFriendRequestsSection method
for (int index = 0; index < friendRequests.length; index++)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendRequests[index])
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  var userFriend = userSnapshot.data!.data()
                      as Map<String, dynamic>;
                  var profilePicUrl =
                      userFriend['profile_picture'] ?? 'lib/assets/default-user.jpg';
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
                        backgroundImage: _buildImageProvider(profilePicUrl),
                        radius: 25.0,
                      ),
                    ),
                    title: Text(
                      friendRequests[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  );
                } else {
                  return ListTile(
                    title: Text(friendRequests[index]),
                    subtitle: const CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white), // Add border
      borderRadius: BorderRadius.circular(8), // Add border radius
    ),
    child: ElevatedButton(
      onPressed: () {
        _friendService.acceptFriendRequest(
            UserData.userName, friendRequests[index]);
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent, // Make the button transparent
        onPrimary: Colors.white,
      ),
      child: Text(
        'Accept',
        style: TextStyle(fontSize: 13, fontFamily: 'DNSans'),
      ),
    ),
  ),
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white), // Add border
      borderRadius: BorderRadius.circular(5), // Add border radius
    ),
    child: ElevatedButton(
      onPressed: () {
        _friendService.cancelFriendRequest(
            friendRequests[index], UserData.userName);
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(0, 255, 255, 255), // Make the button transparent
        onPrimary: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Text(
        'Ew, No',
        style: TextStyle(fontSize: 13, fontFamily: 'DNSans'),
      ),
    ),
  ),
  SizedBox(height: 5),
],

      ),
      SizedBox(height: 5),
    ],
  ),

            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading friend requests'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

ImageProvider _buildImageProvider(String profilePicUrl) {
  ImageProvider imageProvider;
  if (profilePicUrl == 'lib/assets/default-user.jpg') {
    imageProvider = AssetImage(profilePicUrl);
  } else {
    imageProvider = NetworkImage(profilePicUrl);
  }
  return imageProvider;
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
                '$title',
                style: titleTextStyle,
              ),
              GestureDetector(
                onTap: () {
                  showNotificationDropDown(title);
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$notificationCount',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 4,
          color: const Color.fromARGB(255, 255, 255, 255),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Remove placeholder text
        ],
      ),
    );
  }
}
