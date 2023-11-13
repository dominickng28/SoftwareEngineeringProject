import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'search.dart'; 
import 'dart:async'; 

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
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraInitialized = true;
    }
  }

  // TIMER CODE 

  void _setupTimer() {
  // Find the next Sunday from the current date
  DateTime now = DateTime.now();
  DateTime nextSunday = DateTime(now.year, now.month, now.day + (DateTime.sunday - now.weekday + 7) % 7);

  // Set the time to 8 PM
  _nextRefreshTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 20, 0, 0);

  // If the next refresh time has already passed for this week, set it for the next week
  if (_nextRefreshTime.isBefore(now)) {
    _nextRefreshTime = _nextRefreshTime.add(Duration(days: 7));
  }

  // Calculate the duration until the next refresh time
  Duration durationUntilNextRefresh = _nextRefreshTime.difference(now);

  // Create a timer that refreshes every Sunday at 8 PM
  _timer = Timer.periodic(durationUntilNextRefresh, (timer) {
    print("Refreshed at: ${DateTime.now()}");
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
        builder: (context) => MySearch(title: 'Search',),
      ),
    );
  }

  // MAGNIFYIGN GLASS 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(
            fontFamily: 'YourFont',
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: _navigateToMySearch,
          ),
        ],
      ),

      // WORD BOXES 

      body: Column(
        children: <Widget>[
          // Existing Rows
          for (int i = 0; i < 4; i++)
            Container(
              margin: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.network(
                    'https://source.unsplash.com/100x100/?random=$i',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text('Random Word $i'),
                trailing: cameraInitialized
                    ? IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          _openCamera(i);
                        },
                      )
                    : SizedBox(),
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
                    borderRadius: BorderRadius.circular(20.0),
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
              style: TextStyle(fontSize: 16.0),
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

  CameraScreen({required this.camera, required this.rowNumber});

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
