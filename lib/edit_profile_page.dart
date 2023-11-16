import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live4you/user_data.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'friend_service.dart'; // Import the FriendService

class EditProfilePage extends StatefulWidget {
  final String? profilePictureUrl;
  final Function(String)? onUsernameChanged;
  final ValueNotifier<String> usernameNotifier;
  final VoidCallback onProfileUpdated;

  EditProfilePage(
      {this.profilePictureUrl,
      this.onUsernameChanged,
      required this.usernameNotifier,
      required this.onProfileUpdated});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String username = UserData.userName;
  File? _imageFile;
  String? profilePictureUrl;
  final ValueNotifier<String?> profilePictureUrlNotifier = ValueNotifier(null);

  DateTime? joinedDate;

  final picker = ImagePicker();
  final _firestoreService = FirestoreService();
  final FriendService friendService = FriendService(); // Add the FriendService

  final _usernameController = TextEditingController(text: UserData.userName);
  final _bioController = TextEditingController();
  bool _isUsernameAvailable = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    profilePictureUrl = widget.profilePictureUrl;
    profilePictureUrlNotifier.value = widget.profilePictureUrl;
  }

  Future pickImage() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _imageFile = File(croppedFile.path);
          });

          await uploadImage(UserData.userName);
          widget.onProfileUpdated();
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future uploadImage(String username) async {
    try {
      if (_imageFile == null) {
        print('No image file selected.');
        return;
      }

      setState(() {
        profilePictureUrl = null;
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
        profilePictureUrlNotifier.value = imageUrl; // Update the ValueNotifier
      });
    } catch (error) {
      print('An error occurred while uploading the image: $error');
    }
  }

  ImageProvider? _displayProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty) {
      return NetworkImage(profilePictureUrl!);
    } else {
      return const AssetImage('lib/assets/default-user.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      ),
      backgroundColor: const Color.fromARGB(251, 17, 18, 18),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Profile Picture
                SizedBox(
                  height: 60.0,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: ValueListenableBuilder<String?>(
                    valueListenable: profilePictureUrlNotifier,
                    builder:
                        (BuildContext context, String? profilePictureUrl, _) {
                      ImageProvider imageProvider;
                      if (profilePictureUrl == null ||
                          profilePictureUrl == "") {
                        // Use a placeholder image when the profile picture is loading
                        imageProvider =
                            const AssetImage('lib/assets/default-user.jpg');
                      } else {
                        // Use NetworkImage when loading an image from a URL
                        imageProvider = NetworkImage(profilePictureUrl);
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
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 60,
                                fontFamily: 'DMSans'),
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontFamily: 'DNSans'),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) async {
                              if (value == UserData.userName) {
                                setState(() {
                                  _isUsernameAvailable = true;
                                });
                              } else {
                                bool isAvailable = await FirestoreService()
                                    .checkUsernameExists(value);
                                setState(() {
                                  _isUsernameAvailable = !isAvailable;
                                  if (value == "") {
                                    _isUsernameAvailable = false;
                                  }
                                });
                              }
                            },
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
                    controller: _bioController,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'DNSans'),
                    maxLines: null,
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
                  onPressed: _isUsernameAvailable && !_isSaving
                      ? () async {
                          setState(() {
                            _isSaving =
                                true; // Set _isSaving to true when save starts
                          });
                          // Save the changes
                          String newUsername = _usernameController.text.trim();
                          String newBio = _bioController.text.trim();

                          // Store the bio under userdata.username.bio
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(UserData.userName)
                              .set(
                                  {'userbio': newBio}, SetOptions(merge: true));

                          // Check if the username is different from what is in UserData.username
                          if (newUsername != UserData.userName) {
                            String oldUsername = UserData.userName;
                            UserData.userName = newUsername;
                            widget.usernameNotifier.value = newUsername;
                            // Change the username in the firestore for users>userdata>username to the new username
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(oldUsername)
                                .update({'username': newUsername});

                            // Create a new document with the new username and copy the data to the new document
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(newUsername)
                                .set((await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(oldUsername)
                                        .get())
                                    .data()!);

                            // Delete the old document
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(oldUsername)
                                .delete();

                            // Go through posts>which then has unique post ids then under those ids is a username field,
                            // change all of those that match the userdata.username to the new username
                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('username', isEqualTo: oldUsername)
                                    .get();

                            for (var doc in querySnapshot.docs) {
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(doc.id)
                                  .update({'username': newUsername});
                            }

                            // Update received_requests and friends
                            QuerySnapshot usersSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .get();
                            for (var userDoc in usersSnapshot.docs) {
                              Map<String, dynamic> data =
                                  userDoc.data() as Map<String, dynamic>;

                              List<String> receivedRequests = List<String>.from(
                                  data['received_requests'] ?? []);

                              List<String> friends =
                                  List<String>.from(data['friends'] ?? []);

                              if (receivedRequests.contains(oldUsername)) {
                                receivedRequests.remove(oldUsername);
                                receivedRequests.add(newUsername);
                                await userDoc.reference.update(
                                    {'received_requests': receivedRequests});
                              }
                              if (friends.contains(oldUsername)) {
                                friends.remove(oldUsername);
                                friends.add(newUsername);
                                await userDoc.reference
                                    .update({'friends': friends});
                              }
                            }
                            widget.onProfileUpdated();
                            Navigator.pop(context, newUsername);
                          } else {
                            // Return to the profile page
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: Text(
                    _isUsernameAvailable && !_isSaving
                        ? "Save"
                        : "Username Unavailable",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                if (!_isUsernameAvailable)
                  Text(
                    "Username Unavailable",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'DNSans',
                      color: Color.fromARGB(255, 255, 0, 0),
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
