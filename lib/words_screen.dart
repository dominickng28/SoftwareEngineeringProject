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
      backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
      title: Text(
          'WORDS',
      style: TextStyle(
      color: Colors.white, // Set the text color to white
      fontWeight: FontWeight.bold, // Set the text to bold
    ),
  ),
),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final randomWord = Activities[index % Activities.length]; // Ensure Activities are properly initialized
            return Container(
              margin: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 7,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 45, 107, 0.992),
                borderRadius: BorderRadius.circular(12.0),
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
                        fontSize: 84,
                        fontWeight: FontWeight.bold,
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
      backgroundColor: const Color.fromRGBO(153, 206, 255, 0.996), // Placed within the Scaffold widget
    );
  }
}
