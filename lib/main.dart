import 'package:flutter/material.dart';
import 'package:live4you/words_screen.dart';
import 'package:live4you/home_feed.dart';
import 'package:live4you/search.dart';
import 'package:live4you/userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key}); //super key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVE4YOU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 10, 231, 139)),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _login() async {
    try {
      // Get a reference to the auth service
      final FirebaseAuth _auth = FirebaseAuth.instance;

      // Sign in
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If the sign in was successful, navigate to the home screen
      if (userCredential.user != null) {
        String userID = userCredential.user!.uid;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home', userID: userID)),
        );
      } else {
        // If the user is not signed in, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to sign in. Please try again.')),
        );
      }
    } catch (e) {
      // If an error occurs, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Image
              Image.asset(
                'lib/assets/Live4youLogo.png',
                width: 300, // Adjust the width as needed
                height: 360, // Adjust the height as needed
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 14, 105, 171)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Change button color
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.userID});

  final String userID;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Tasks',
          ),
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
          if (index == 0) {
            // Handle navigation to the 'Words' screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WordsScreen(title: 'Words'),
              ),
            );
          } else if (index == 1) {
            // Handle navigation to the 'Homefeed' screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyFeed(title: 'Homefeed'),
              ),
            );
          } else if (index == 2) {
            // Handle navigation to the 'Search' screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MySearch(title: 'Search', userID: widget.userID),
              ),
            );
          } else if (index == 3) {
            // Handle navigation to the 'Profile' screen
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