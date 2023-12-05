// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
// import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// import 'home_feed.dart';
import 'search.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WordsScreen(),
    );
  }
}

class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<WordsScreen> {
  late List<CameraDescription> cameras;
  bool cameraInitialized = false;

  late Timer _timer;
  late DateTime _nextRefreshTime;
  late Duration durationUntilNextRefresh = Duration();

  List<String> words = ['Cook', 'Biking', 'Draw', 'Run']; // STORES WORDS
  List<String> wordImages = [
    'Cooking.jpeg',
    'Biking.webp',
    'Draw.jpeg',
    'Explore.jpeg',
  ];
  List<bool> checkBoxState = [false, false, false, false];

  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupTimer();
  }

  _initializeCamera() async {
    try {
      cameras = await availableCameras();
      print("Cameras: $cameras"); // Add this line to check the cameras
      if (cameras.isNotEmpty) {
        _cameraController =
            CameraController(cameras.first, ResolutionPreset.high);
        await _cameraController.initialize();
        setState(() {
          cameraInitialized = true;
        });
      }
    } catch (e) {
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
        builder: (context) => const MyUserProfilePage(
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
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: _navigateToMyUserProfilePage,
          ),
        ],
      ),

      // SCREEN BACKGROUND, BEHIND BOXES
      backgroundColor: const Color.fromARGB(248, 0, 0, 0),

      // WORD BOXES

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Existing Rows
            for (int i = 0; i < 4; i++) ...[
              Container(
                constraints: const BoxConstraints(minWidth: 500, maxWidth: 500),
                margin: const EdgeInsets.all(5), // SPACE BETWEEN EACH ROW
                color: checkBoxState[i] ? Colors.green : null,
                child: Column(
                  children: [
                    // WORD PICTURE
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: Image.asset(
                          'lib/assets/${wordImages[i]}',
                          width: 93.0,
                          height: 93.0,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // ACTUAL WORD
                      title: Row(
                        children: [
                          Text(
                            words[i],
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 26.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Checkbox(
                            value: checkBoxState[i],
                            onChanged: (bool? value) {
                              setState(() {
                                checkBoxState[i] = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                        ],
                      ),

                      // CAMERA ICON
                      trailing: cameraInitialized
                          ? IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                _openCamera(i);
                              },
                            )
                          : const CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                    ),

                    // Divider
                    Divider(
                      color: Colors.transparent, // Transparent divider
                      thickness: 0.5,
                      indent: 16.0,
                      endIndent: 16.0,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4.0),

            // Scrollable Row of Rectangular Photos
            Scrollbar(
              thumbVisibility: true,
              controller: ScrollController(),
              child: SizedBox(
                height: 160.0, // Adjust the height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0.0 : 8.0,
                      ),
                      width: 230.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'lib/assets/${wordImages[index]}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Live Time Timer
            Container(
              margin: const EdgeInsets.all(12.0),
              child: Text(
                'Time Left: ${_formatDuration(durationUntilNextRefresh)}',
                style: const TextStyle(
                    fontSize: 20.0, color: Colors.white, fontFamily: "DNSans"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CAMERA CODE
  _openCamera(int rowNumber) async {
    try {
      if (cameraInitialized) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              camera: cameras.first,
            ),
          ),
        );

        if (result != null) {
          // ignore: avoid_print
          print('Image captured for Row $rowNumber: $result');
        }
      } else {
        // ignore: avoid_print
        print('Camera not initialized.');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error opening camera: $e');
    }
  }
}
