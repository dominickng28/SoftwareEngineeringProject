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
  style: TextStyle(color: Colors.white), // Set the text color to white
  decoration: InputDecoration(
    labelText: "Search for a username",
    labelStyle: TextStyle(
      color: Colors.white,
      fontFamily: 'DNSans',
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Set the underline color to white
    ),
    suffixIcon: IconButton(
      onPressed: () async {
        String username = _searchController.text;
        DocumentSnapshot userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(username)
            .get();
        if (userDoc.exists) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No user found with the username $username'),
            ),
          );
        }
      },
      icon: Icon(Icons.search, color: Colors.white),
    ),
  ),
),

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
            for (int i = 0; i < 3; i++)
              Container(
                constraints: const BoxConstraints(
                    minWidth: 200, maxWidth: 400, maxHeight: 200),
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
                      horizontal: 16.0, vertical: 16.0),
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
                      constraints:
                          const BoxConstraints(minHeight: 50, maxWidth: 100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://source.unsplash.com/100x100/?random='),
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
