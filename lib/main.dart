import 'package:flutter/material.dart';
import 'package:live4you/login_screen.dart';
import 'package:live4you/signup_screen.dart';
import 'package:live4you/home_feed.dart'; // Import the home screen
import 'package:live4you/profile_screen.dart'; // Import the profile screen
import 'package:firebase_core/firebase_core.dart';
import 'package:live4you/search_screen.dart';
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
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> _children; // Define _children here

  @override
  void initState() {
    super.initState();

    _children = [
      const MyFeed(
        title: 'Home Feed',
      ),
      const WordsScreen(),
      MySearch(
        title: 'Search',
      ),
      const MyUserProfilePage(
        title: 'User Profile',
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
        selectedItemColor: const Color.fromARGB(248, 255, 255, 255),
        unselectedItemColor: const Color.fromARGB(248, 255, 255, 255),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(
              Icons.home,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            backgroundColor: Color.fromARGB(251, 0, 0, 0),
            // activeIcon: Icon(Icons.home, color: Color.fromARGB(248, 136, 0, 255), ),
            // backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4),
            // icon: Icon(Icons.beach_access),
            activeIcon: Icon(
              Icons.looks_4,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            backgroundColor: Color.fromARGB(251, 0, 0, 0),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(
              Icons.search,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            backgroundColor: Color.fromARGB(251, 0, 0, 0),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(
              Icons.home,
              color: Color.fromARGB(248, 255, 255, 255),
            ),
            // activeIcon: Icon(Icons.person, color: const Color.fromARGB(249, 253, 208, 149)),
            backgroundColor: Color.fromARGB(251, 0, 0, 0),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
