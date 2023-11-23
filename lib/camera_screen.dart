import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:live4you/user_data.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TextEditingController _captionController = TextEditingController();
  String? imagePath;

  // List of options for the carousel
  final List<String> options = ["DIY", "Biking", "Smile", "Run"];
  String selectedOption = "DIY";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final XFile photo = await _controller.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPostCard(
            imagePath: photo.path,
            selectedOption: selectedOption,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
        'Take a picture', 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
        ),), 
        centerTitle: true,),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Transform.translate(
                offset: Offset(0, -250), // Move the carousel up
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 30, 
                    color: Colors.black, 
                    fontWeight: FontWeight.bold), // Increase the font size
                  child: PageView.builder(
                    itemCount: options.length,
                    onPageChanged: (int index) {
                      setState(() {
                        selectedOption = options[index];
                      });
                    },
                    itemBuilder: (_, i) {
                      return Center(child: Text(options[i]));
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                child: Icon(Icons.camera_alt),
                onPressed: _takePicture,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewPostCard extends StatefulWidget {
  final String imagePath;
  final String selectedOption;

  PreviewPostCard({required this.imagePath, required this.selectedOption});

  @override
  _PreviewPostCardState createState() => _PreviewPostCardState();
}

class _PreviewPostCardState extends State<PreviewPostCard> {
  final TextEditingController _captionController = TextEditingController();

  Future<void> _savePicture() async {
    try {
      final String fileName = widget.imagePath.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('posts/$fileName');

      UploadTask uploadTask =
          firebaseStorageRef.putFile(File(widget.imagePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');

      DocumentReference docRef = await posts.add({
        'imageUrl': imageUrl,
        'caption': _captionController.text,
        'likecount': 0,
        'username': UserData.userName,
        'timestamp': FieldValue.serverTimestamp(),
        'pfp': null,
        'userID': "",
        'embed': '',
        'likes': [],
        'word': widget.selectedOption, // Save the selected option with the post
      });

      // Update the post with the post ID
      await docRef.update({
        'postid': docRef.id,
      });

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(UserData.userName);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        if (!data.containsKey('post_list')) {
          userDoc.set({
            'post_list': [docRef.id],
          }, SetOptions(merge: true));
        } else {
          List<String> currentList = List.from(data['post_list']);
          currentList.add(docRef.id);
          userDoc.update({'post_list': currentList});
        }
      }

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a caption')),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(248, 0, 0, 0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                      'lib/assets/default-user.jpg'), // Replace with your placeholder image
                ),
                title: Text(
                  UserData.userName, // Replace with the username
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal,
                  ),
                  child: Text(
                    widget.selectedOption, // Display the selected option
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.fill,
                ),
              ),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: _captionController,
                decoration: InputDecoration(
                    labelText: 'Caption', fillColor: Colors.white),
              ),
              ElevatedButton(
                onPressed: _savePicture,
                child: Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CaptionScreen extends StatefulWidget {
  final String imagePath;
  final String selectedOption;

  CaptionScreen({
    Key? key,
    required this.imagePath,
    required this.selectedOption,
  }) : super(key: key);

  @override
  _CaptionScreenState createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  final TextEditingController _captionController = TextEditingController();

  Future<void> _savePicture() async {
    try {
      final String fileName = widget.imagePath.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('posts/$fileName');

      UploadTask uploadTask =
          firebaseStorageRef.putFile(File(widget.imagePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');

      DocumentReference docRef = await posts.add({
        'imageUrl': imageUrl,
        'caption': _captionController.text,
        'likecount': 0,
        'username': UserData.userName,
        'timestamp': FieldValue.serverTimestamp(),
        'pfp': null,
        'userID': "",
        'embed': '',
        'likes': [],
        'word': widget.selectedOption, // Save the selected option with the post
      });

      // Update the post with the post ID
      await docRef.update({
        'postid': docRef.id,
      });

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(UserData.userName);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        if (!data.containsKey('post_list')) {
          userDoc.set({
            'post_list': [docRef.id],
          }, SetOptions(merge: true));
        } else {
          List<String> currentList = List.from(data['post_list']);
          currentList.add(docRef.id);
          userDoc.update({'post_list': currentList});
        }
      }

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a caption')),
      body: SingleChildScrollView(
        // Add this
        child: Column(
          children: [
            Image.file(File(widget.imagePath)),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _captionController,
              decoration: InputDecoration(labelText: 'Caption'),
            ),
            ElevatedButton(
              onPressed: _savePicture,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
