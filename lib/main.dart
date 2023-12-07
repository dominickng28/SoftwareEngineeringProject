import 'package:flutter/material.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/home_feed.dart'; // Import the home screen
import 'package:live4you/profile_screen.dart'; // Import the profile screen
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/search_screen.dart';
import 'package:live4you/user_data.dart';
import 'package:live4you/words_screen.dart';
import 'package:live4you/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Fix constructor definition
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVE4YOU',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(auth: FirebaseAuth.instance),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  String profile;
  final int index;
  MainScreen({super.key, required this.profile, required this.index});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late List<Widget> _children;
  late PageController _pageController;
  late int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _children = [
      const MyFeed(title: 'Home Feed'), // Home Feed tab on the left
      const WordsScreen(), // Words tab in the middle
      MyUserProfilePage(
          title: 'User Profile',
          profileUserName: widget.profile), // Profile tab on the right
    ];
    _pageController = PageController(initialPage: widget.index);
    _currentIndex = widget.index;
  }

  void refreshScreen(int index) {
    setState(() {
      _currentIndex = index;
      widget.profile = UserData.userName;
      if (_currentIndex == 0) {
        _children[0] = MyFeed(title: 'Home Feed');
      } else if (_currentIndex == 1) {
        _children[1] = WordsScreen();
      } else {
        _children[2] = MyUserProfilePage(
            title: 'UserProfile', profileUserName: widget.profile);
      }
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    refreshScreen(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _children),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        backgroundColor: Colors.black, // Set the bottom nav bar color to black
        selectedItemColor: Colors.white, // Set the selected icon color to white
        unselectedItemColor: Colors.white
            .withOpacity(0.6), // Set unselected icon color with opacity
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
