import 'package:flutter/material.dart';
import 'activities.dart'; // Import the activities file

class WordsScreen extends StatefulWidget {
  const WordsScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary, // Use appropriate color
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final randomWord = Activities[index % Activities.length]; // Fetch a random word
            return Container(
              margin: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width / 1, // Adjust width as needed
              height: MediaQuery.of(context).size.height / 7, // Adjust height as needed
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 45, 107, 0.992), // Example color for the box
                borderRadius: BorderRadius.circular(12.0), // Optional: rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      randomWord,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 84, // Triple the font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        // Dialog functionality
                      },
                      child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
