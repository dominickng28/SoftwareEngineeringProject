import 'package:flutter/material.dart';
import 'package:live4you/home_feed_for_testing.dart';
import 'words_screen.dart';
import 'home_feed.dart';
import 'search.dart';
import 'userprofile.dart';
import 'main.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String userID;

  const CustomBottomNavigation({super.key, required this.currentIndex, required this.userID});

  void handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(title: 'Words', userID: userID),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // builder: (context) => const MyFeed(title: 'Homefeed'),
          builder: (context) => MyFeedTest(userID: userID),
        )
        );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MySearch(title: 'Search', userID: userID),
      )
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyUserProfilePage(userID: userID, profileUserID: userID),
      )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.beach_access),
          label: 'Words',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) => handleNavigation(context, index), // Handle navigation
    );
  }
}

