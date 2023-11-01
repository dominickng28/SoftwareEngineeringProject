import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'profile_screen.dart';
import 'main.dart';

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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(
                      title: 'User Profile',
                      userID: widget.userID,
                      profileUserID: "tCBgXhuZ57gJUfOhyS7X6gdF3sE3",
                    ),
                  ),
                );
              },
              child: Text('John'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(
                      title: 'User Profile',
                      userID: widget.userID,
                      profileUserID: "to7UDeMklvPrDDAZqrURwpW6ENf1",
                    ),
                  ),
                );
              },
              child: Text('Bob'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyUserProfilePage(
                      title: 'User Profile',
                      userID: widget.userID,
                      profileUserID: "CSJTlYeExpS1qMQROeWCnqZEzIF2",
                    ),
                  ),
                );
              },
              child: Text('Claire'),
            ),
          ],
        ),
      ),
    );
  }
}
