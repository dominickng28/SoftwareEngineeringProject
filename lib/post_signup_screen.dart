import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live4you/main.dart';
import 'firestore_service.dart';
import 'package:live4you/home_feed.dart';





final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirestoreService _service = FirestoreService();
final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');


class PostSignUpScreen extends StatefulWidget {
  const PostSignUpScreen({super.key});

  @override
  _PostSignUpScreenState createState() => _PostSignUpScreenState();
}

class _PostSignUpScreenState extends State<PostSignUpScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  late bool _sucess;
  late String _userEmail;
  

  Future<void> _addUser(String firstName, String lastName, String userName, String bio, ){
    ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully')),
        );
    Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
    return usersCollection.add({
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'userBio': bio
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Account Info',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Set text to bold
            fontSize: 24, // Set font size to a larger value
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
      ),
      backgroundColor: const Color.fromRGBO(153, 206, 255, 0.996),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Image
              Image.asset(
                'lib/assets/Live4youLine.png',
                width: 200, // Adjust the width as needed
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 14, 105, 171)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 14, 105, 171)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.badge_outlined), // Add an icon as the prefix
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  _addUser(_firstnameController.text, _lastnameController.text, _usernameController.text, _bioController.text);
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // Change button color
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
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
