import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:live4you/user_data.dart';
//import 'package:path/path.dart' show join;
//import 'package:path_provider/path_provider.dart';
//import 'package:flutter_image_compress/flutter_image_compress.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    super.key,
    required this.camera,
  });

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  //final TextEditingController _captionController = TextEditingController();
  String? imagePath;

  // List of options for the carousel
  final List<String> options = ["Cook", "Biking", "Draw", "Run"];
  String selectedOption = "Cook";

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

  BuildContext? _scaffoldContext;

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      _scaffoldContext = context;

      final XFile photo = await _controller.takePicture();

      //Compress image and saving it
      List<int> compressedPic = await FlutterImageCompress.compressWithList(
        File(photo.path).readAsBytesSync(),
        quality: 60,
      );
      File compressedFile = File(photo.path);
      await compressedFile.writeAsBytes(compressedPic);

      Navigator.push(
        _scaffoldContext!,
        MaterialPageRoute(
          builder: (scaffoldContext) => PreviewPostCard(
            imagePath: compressedFile.path,
            selectedOption: selectedOption,
          ),
        ),
      );
    } catch (e) {
      //print(e);
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
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Transform.translate(
                offset: const Offset(0, -250), // Move the carousel up
                child: DefaultTextStyle(
                  style: const TextStyle(
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
                onPressed: _takePicture,
                child: const Icon(Icons.camera_alt),
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

  const PreviewPostCard(
      {super.key, required this.imagePath, required this.selectedOption});

  @override
  PreviewPostCardState createState() => PreviewPostCardState();
}

class PreviewPostCardState extends State<PreviewPostCard> {
  final TextEditingController _captionController = TextEditingController();
  BuildContext? _scaffoldContext;

  Future<void> _savePicture() async {
    try {
      final String fileName = widget.imagePath.split('/').last;
      _scaffoldContext = context;
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

      Navigator.pop(_scaffoldContext!, true);
    } catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Add a caption',
            style: TextStyle(
              color: Colors.white,
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          height: 680,
          color: const Color.fromARGB(248, 0, 0, 0),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage(
                      'lib/assets/default-user.jpg'), // Replace with your placeholder image
                ),
                title: Text(
                  UserData.userName, // Replace with the username
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.selectedOption, // Display the selected option
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
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
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(color: Colors.white),
                controller: _captionController,
                maxLength: 250,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                    labelText: 'Caption',
                    alignLabelWithHint: true,
                    fillColor: Colors.white),
              ),
              ElevatedButton(
                onPressed: _savePicture,
                child: const Text('Post'),
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

  const CaptionScreen({
    super.key,
    required this.imagePath,
    required this.selectedOption,
  });

  @override
  CaptionScreenState createState() => CaptionScreenState();
}

class CaptionScreenState extends State<CaptionScreen> {
  final TextEditingController _captionController = TextEditingController();
  BuildContext? _scaffoldContext;

  Future<void> _savePicture() async {
    try {
      final String fileName = widget.imagePath.split('/').last;
      _scaffoldContext = context;
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

      Navigator.pop(_scaffoldContext!, true);
    } catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a caption')),
      body: ListView(children: [
        Column(
          children: [
            Image.file(File(widget.imagePath)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(color: Colors.white),
                controller: _captionController,
                maxLength: 250,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _savePicture,
              child: const Text('Post'),
            ),
          ],
        ),
        Container(height: 300, color: Colors.black),
      ]),
    );
  }
}
