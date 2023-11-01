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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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

