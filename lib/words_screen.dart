import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView(
        children: <Widget>[
          for (int i = 0; i < 4; i++)
            Container(
              margin: EdgeInsets.all(8.0), // Add margin for spacing
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                title: Text('Random Word $i'),
                trailing: cameraInitialized
                    ? IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          _openCamera(i);
                        },
                      )
                    : CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

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
        title: Text('Camera'),
      ),
      body: Center(
        child: CameraPreview(_controller),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await _controller.takePicture();
          Navigator.pop(context, image);
        },
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
