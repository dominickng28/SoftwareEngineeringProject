import 'package:flutter/material.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/home_feed.dart'; // Import the home screen
import 'package:live4you/profile_screen.dart'; // Import the profile screen
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/search_screen.dart';
import 'package:live4you/words_screen.dart';
import 'package:live4you/firebase_options.dart';

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
            ColorScheme.fromSeed(seedColor:const Color.fromARGB(144, 10, 231, 139)),
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
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Set initial index to 1 (Home)

  late List<Widget> _children;

  @override
  void initState() {
    super.initState();

    _children = [
      const WordsScreen(), // Words tab on the left
      const MyFeed(title: 'Home Feed'), // Home tab in the middle
      const MyUserProfilePage(title: 'User Profile'), // Profile tab on the right
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
        selectedItemColor: const Color.fromARGB(248, 255, 255, 255),
        unselectedItemColor: const Color.fromARGB(248, 255, 255, 255),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(251, 0, 0, 0), // Set background color here
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4),
            activeIcon: Icon(
              Icons.looks_4,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            label: _currentIndex == 0 ? 'Words' : '', // Show label only when selected
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(
              Icons.home,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            label: _currentIndex == 1 ? 'Home' : '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(
              Icons.person,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            label: _currentIndex == 2 ? 'Profile' : '',
          ),
        ],
      ),
    );
  }
}
