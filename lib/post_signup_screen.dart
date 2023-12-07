import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:live4you/main.dart';
import 'package:live4you/user_data.dart';
//import 'firestore_service.dart';
//import 'package:live4you/home_feed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'friend_service.dart'; // Import the FriendService

//final FirebaseAuth _auth = FirebaseAuth.instance;
//final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//final FirestoreService _service = FirestoreService();
final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

class PostSignUpScreen extends StatefulWidget {
  const PostSignUpScreen({super.key});

  @override
  PostSignUpScreenState createState() => PostSignUpScreenState();
}

class PostSignUpScreenState extends State<PostSignUpScreen> {
  final TextEditingController _bioController = TextEditingController();
  //final TextEditingController _usernameController = TextEditingController();
  File? _imageFile; // Change to File? to allow null
  final picker = ImagePicker();
  //final _firestoreService = FirestoreService();
  String profilePictureUrl = '';
  final FriendService friendService = FriendService(); // Add the FriendService
  BuildContext? _scaffoldContext;

  Future<void> _addUser(String bio) async {
    List<String> lines = bio.split('\n');
    _scaffoldContext = context;
    if (lines.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio should not exceed 4 lines')),
      );
      return;
    }
    // Fetch the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the user document in Firestore
      await usersCollection
          .doc(UserData.userName)
          .update({'userbio': bio, 'friends': []});

      // Save the image to Firestore or a storage service
      if (_imageFile != null) {
        // Example: Save the image to Firestore
        await usersCollection.doc(UserData.userName).update({
          'profile_picture': _imageFile!.path,
        });
      }

      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Account Updated Successfully')),
      );
      Navigator.of(_scaffoldContext!).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                MainScreen(profile: UserData.userName, index: 0)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently signed in.')),
      );
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await uploadImage(UserData.userName);
    }
  }

  Future uploadImage(String username) async {
    try {
      if (_imageFile == null) {
        //print('No image file selected.');
        return;
      }

      setState(() {
        profilePictureUrl = "";
      });

      final fileName = 'user_profilePictures/$username.png';
      final reference = FirebaseStorage.instance.ref(fileName);

      await reference.putFile(_imageFile!);

      final imageUrl = await reference.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .set({'profile_picture': imageUrl}, SetOptions(merge: true));

      setState(() {
        _imageFile = null;
        profilePictureUrl = imageUrl;
      });
    } catch (error) {
      //print('An error occurred while uploading the image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Account Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'DMSans',
          ),
        ),
        backgroundColor: const Color.fromARGB(251, 0, 0, 0),
      ),
      backgroundColor: const Color.fromARGB(251, 0, 0, 0),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Profile Picture
                const SizedBox(
                  height: 60.0,
                ),
                GestureDetector(
                  onTap: () {
                    _getImage();
                  },
                  child: StreamBuilder<String?>(
                    stream: FriendService()
                        .userProfilePictureStream(UserData.userName),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      ImageProvider imageProvider;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Use a placeholder image when the profile picture is loading
                        imageProvider =
                            const AssetImage('lib/assets/default-user.jpg');
                      } else if (snapshot.hasError) {
                        imageProvider =
                            const AssetImage('lib/assets/default-user.jpg');
                      } else {
                        String? profilePictureUrl = snapshot.data;
                        if (profilePictureUrl == null ||
                            profilePictureUrl.isEmpty) {
                          // Use a default profile picture when there's no profile picture
                          imageProvider =
                              const AssetImage('lib/assets/default-user.jpg');
                        } else {
                          // Use NetworkImage when loading an image from a URL
                          imageProvider = NetworkImage(profilePictureUrl);
                        }
                      }
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 130,
                            backgroundColor: Colors.white,
                            backgroundImage: imageProvider,
                          ),
                          const SizedBox(height: 20.0),
                          // Display the username
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              UserData.userName,
                              style: const TextStyle(
                                  overflow: TextOverflow.clip,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60,
                                  fontFamily: 'DMSans'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

                // Bio Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _bioController,
                    maxLength: 1000,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: 'Bio',
                      hintStyle:
                          TextStyle(color: Colors.white, fontFamily: 'DNSans'),
                      border: InputBorder.none,
                      prefixIcon:
                          Icon(Icons.badge_outlined, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                ElevatedButton(
                  onPressed: () async {
                    await _addUser(_bioController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
