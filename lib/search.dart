import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'home_feed.dart';
import 'user.dart';
import 'userprofile.dart';

class MySearch extends StatefulWidget {
  const MySearch({super.key, required this.title, required this.userID});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String userID;
  final String title;

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Test'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(title: 'User Profile', userID: widget.userID, profileUserID: "tCBgXhuZ57gJUfOhyS7X6gdF3sE3"),
                  ),
                );
              },
              child: Text('John'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(title: 'User Profile', userID: widget.userID, profileUserID: "to7UDeMklvPrDDAZqrURwpW6ENf1"),
                  ),
                );
              },
              child: Text('Bob'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(title: 'User Profile', userID: widget.userID, profileUserID: "CSJTlYeExpS1qMQROeWCnqZEzIF2"),
                  ),
                );
              },
              child: Text('Claire'),
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
        onTap: (int index) {
          // Handle navigation based on the selected tab
          if (index == 0) {
            // Replace with your navigation logic to the word page
            Navigator.push(
              context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'Words', userID: widget.userID),
              ),
            );
          } 
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyFeed(title: 'Homefeed'),
              ),
            );
          } 
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MySearch(title: 'Search', userID: widget.userID),
              ),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyUserProfilePage(title: 'User Profile', userID: widget.userID, profileUserID: widget.userID),
              ),
            );
          }
        },
      ),
    );
  }
}