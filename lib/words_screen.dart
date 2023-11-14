import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:live4you/Activities.dart';

import 'home_feed.dart';
import 'search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WordsScreen(),
    );
  }
}

class WordsScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<WordsScreen> {
  late List<CameraDescription> cameras;
  bool cameraInitialized = false;
  late Timer _timer;
  late DateTime _nextRefreshTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupTimer();
  }

  _initializeCamera() async {
    try { 
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          cameraInitialized = true;
        });
    }
    } catch(e) { 
      print("Error getting camera: $e"); 
    }
    
  }

  // TIMER CODE

  void _setupTimer() {
    // Find the next Sunday from the current date
    DateTime now = DateTime.now();
    DateTime nextSunday = DateTime(
        now.year, now.month, now.day + (DateTime.sunday - now.weekday + 7) % 7);

    // Set the time to 8 PM
    _nextRefreshTime =
        DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 20, 0, 0);

    // If the next refresh time has already passed for this week, set it for the next week
    if (_nextRefreshTime.isBefore(now)) {
      _nextRefreshTime = _nextRefreshTime.add(Duration(days: 7));
    }

    // Calculate the duration until the next refresh time
    Duration durationUntilNextRefresh = _nextRefreshTime.difference(now);

    // Create a timer that refreshes once, counting down to the next Sunday at 8 PM
    _timer = Timer(durationUntilNextRefresh, () {
      print("Refreshed at: ${DateTime.now()}");
      // You can add any other logic that needs to be executed when the timer completes
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void _navigateToMySearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySearch(
          title: 'Search',
        ),
      ),
    );
  }

  // MAGNIFYING GLASS

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(251, 0, 0, 0),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _navigateToMySearch,
          ),
        ],
      ),

      // SCREEN BACKGROUND, BEHIND BOXES
      backgroundColor: Color.fromARGB(248, 0, 0, 0),

      // WORD BOXES

      body: Column(
        children: <Widget>[
          // Existing Rows
          for (int i = 0; i < 4; i++)
            Container(
              constraints: BoxConstraints(minWidth: 500, maxWidth: 5000),
              margin: EdgeInsets.all(5), // SPACE BETWEEN EACH ROW
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(100.0),
              ),

              // WORD PICTURE

              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.network(
                    'https://source.unsplash.com/100x100/?random=$i',
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),

                // ACTUAL WORD
                title: Text(getRandomElement(Activities),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white)),
                trailing: cameraInitialized
                    ? IconButton(
                        icon: Icon(
                          Icons.camera_alt, 
                          color: Colors.white, 
                          size: 30,),
                        onPressed: () {
                          _openCamera(i);
                        },
                      )
                    : CircularProgressIndicator.adaptive(),
              ),
            ),

          // Scrollable Row of Rectangular Photos
          SizedBox(
            height: 150.0, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0.0 : 8.0,
                  ),
                  width: 200.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      'https://source.unsplash.com/200x150/?random=${index + 4}',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          // Live Time Timer
          Container(
            margin: EdgeInsets.all(12.0),
            child: Text(
              'Next Refresh: $_nextRefreshTime',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // CAMERA CODE

  _openCamera(int rowNumber) async {
    final camera = cameras.first;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          camera: camera,
          rowNumber: rowNumber,
        ),
      ),
    );

    if (result != null) {
      print('Image captured for Row $rowNumber: $result');
    }
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final int rowNumber;

  const CameraScreen({required this.camera, required this.rowNumber});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camera',
          style: TextStyle(
            fontFamily: 'YourFont',
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: CameraPreview(_controller),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = _controller.takePicture(); //await
          Navigator.pop(context, image);
        },
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
