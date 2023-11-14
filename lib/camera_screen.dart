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

      setState(() {
        imagePath = photo.path;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _savePicture() async {
    try {
      final String fileName = imagePath!.split('/').last;
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('posts/$fileName');

      UploadTask uploadTask = firebaseStorageRef.putFile(File(imagePath!));
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
      appBar: AppBar(title: Text('Take a picture')),
      body: imagePath == null
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Column(
              children: [
                Image.file(File(imagePath!)),
                TextField(
                  controller: _captionController,
                  decoration: InputDecoration(labelText: 'Caption'),
                ),
                ElevatedButton(
                  onPressed: _savePicture,
                  child: Text('Post'),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: imagePath == null ? _takePicture : null,
      ),
    );
  }
}
