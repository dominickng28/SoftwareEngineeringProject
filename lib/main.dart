import 'package:flutter/material.dart';
import 'package:live4you/firebase_options.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/home_feed.dart'; // Import the home screen
import 'package:live4you/profile_screen.dart'; // Import the profile screen
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/search.dart';
import 'package:live4you/words_screen.dart';

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
        '/home': (context) => const MyFeed(
              title: 'Home Feed',
            ), // Add a route for the home screen
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const MyFeed(title: 'Home Feed'),
    const WordsScreen(title: 'Words'),
    const MySearch(
        title: 'Search', userID: 'userID'), // replace with actual userID
    const MyUserProfilePage(
        title: 'User Profile',
        userID: 'userID',
        profileUserID:
            'profileUserID'), // replace with actual userID and profileUserID
  ];

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
        backgroundColor:  const Color.fromRGBO(0, 45, 107, 0.992),
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.white,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
            icon: Icon(Icons.beach_access),
            activeIcon: Icon(Icons.beach_access, color: Colors.white),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.percent, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
