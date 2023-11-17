import 'dart:async';
// import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:live4you/Activities.dart';

// import 'home_feed.dart';
import 'search.dart';
import 'profile_screen.dart';

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
  late Duration durationUntilNextRefresh = Duration(); 

  List<String> words = ['DIY', 'Biking', 'Smile', 'Run']; // STORES WORDS

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
  // Find the next Monday from the current date
  DateTime now = DateTime.now();
  DateTime nextMonday = DateTime(
    now.year,
    now.month,
    now.day + (DateTime.monday - now.weekday + 7) % 7,
    12, // Set the hour to noon (12 PM)
    0,
    0,
  );

  // Set the time to noon
  _nextRefreshTime = nextMonday;

  // If the next refresh time has already passed for this week, set it for the next week
  if (_nextRefreshTime.isBefore(now)) {
    _nextRefreshTime = _nextRefreshTime.add(const Duration(days: 7));
  }

  // Initialize durationUntilNextRefresh to the initial calculated duration
  durationUntilNextRefresh = _nextRefreshTime.difference(now);

  // Create a timer that refreshes once, counting down to the next Monday at noon
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      // Recalculate the duration until the next refresh time
      durationUntilNextRefresh = _nextRefreshTime.difference(DateTime.now());
    });

    // Check if the timer should be canceled
    if (durationUntilNextRefresh.isNegative) {
      timer.cancel();
    }
  });
}

  String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '${duration.inDays}d ${twoDigits(duration.inHours.remainder(24))}h ${twoDigitMinutes}m ${twoDigitSeconds}s';
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
        builder: (context) => const MySearch(
          title: 'Search',
        ),
      ),
    );
  }
  void _navigateToMyUserProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyUserProfilePage(
          title: 'User Profile',
          // Add any necessary parameters for the profile screen
        ),
      ),
    );
  }

  // MAGNIFYING GLASS

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(251, 0, 0, 0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _navigateToMySearch,
          ),
          IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: _navigateToMyUserProfilePage,
        ),
        ],
      ),

      // SCREEN BACKGROUND, BEHIND BOXES
      backgroundColor: const Color.fromARGB(248, 0, 0, 0),

      // WORD BOXES

      body: Column(
        children: <Widget>[
          
          // Existing Rows
          for (int i = 0; i < 4; i++)

            Container(
              constraints: const BoxConstraints(minWidth: 500, maxWidth: 500),
              margin: const EdgeInsets.all(5), // SPACE BETWEEN EACH ROW
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
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                title: Text(
                    words[i],
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white)),

                // CAMERA ICON       
                trailing: cameraInitialized
                    ? IconButton(
                        icon: const Icon(
                          Icons.camera_alt, 
                          color: Colors.white, 
                          size: 30,),
                        onPressed: () {
                          _openCamera(i);
                        },
                      )
                    : const CircularProgressIndicator.adaptive(),
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
            margin: const EdgeInsets.all(12.0),
            child: Text(
              'Time Left: ${_formatDuration(durationUntilNextRefresh)}',
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
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
