import 'package:flutter/material.dart';
import 'friend_service.dart';
import 'user_data.dart';
import 'search_screen.dart';

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
  Widget build(BuildContext context) {
    getCountOfFriendList();    
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
          const Divider(height: 4, color: Color.fromARGB(255, 255, 255, 255),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Friend Requests',
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
          const Divider(height: 4, color: Color.fromARGB(255, 255, 255, 255),),
          _mySearch.buildFriendRequestsSection(),
          const Divider(height: 4, color: Color.fromARGB(255, 255, 255, 255),),
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

Future<void> getCountOfFriendList() async {
  List<String> friends = await _friendService.getFriendRequest(UserData.userName);
  setState(() {
    friendRequestsNotificationCount = friends.length;
  });
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
