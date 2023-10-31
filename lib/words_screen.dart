import 'package:flutter/material.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<WordsScreen> createState() => _WordsScreen();
}

class _WordsScreen extends State<WordsScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(
  backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
  title: Text(
    'Words',
    style: TextStyle(
      color: Colors.white, // Set the text color to white
      fontWeight: FontWeight.bold, // Set the text to bold
    ),
  ),
),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your content goes here
          ],
        ),
      ),
      // Add a back button to return to the homepage
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back to the previous screen (the homepage)
        },
        tooltip: 'Back',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

