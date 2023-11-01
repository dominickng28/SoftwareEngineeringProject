import 'package:flutter/material.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/home_feed.dart'; // Import the home screen
import 'package:live4you/profile_screen.dart'; // Import the profile screen
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/search.dart';
import 'package:live4you/words_screen.dart';
import 'package:live4you/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}); // Fix constructor definition

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVE4YOU',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(144, 10, 231, 139)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key? key, required this.userID}) : super(key: key);
  final String userID;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> _children; // Define _children here

  @override
  void initState() {
    super.initState();

    _children = [
      MyFeed(
        title: 'Home Feed',
        userID: widget.userID,
      ),
      const WordsScreen(title: 'Words'),
      MySearch(
        title: 'Search',
        userID: widget.userID,
      ),
      MyUserProfilePage(
        title: 'User Profile',
        userID: widget.userID,
        profileUserID: widget.userID,
      ),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            activeIcon: Icon(Icons.beach_access, color: Colors.blue),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search, color: Colors.blue),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, color: Colors.blue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

