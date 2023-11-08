import 'package:flutter/material.dart';
import 'activities.dart'; // Import the activities file

class WordsScreen extends StatefulWidget {
  const WordsScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  bool isChecked = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary, // Use appropriate color
        title: Text(widget.title),
      ),

      body: SingleChildScrollView(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: List.generate(4, (index) {
            final randomWord = Activities[index % Activities.length]; // Fetch a random word

            return Container(
              margin: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 1, // Adjust width as needed
              height: MediaQuery.of(context).size.height / 10, // Adjust height as needed
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 45, 107, 0.992), // Example color for the box
                borderRadius: BorderRadius.circular(12.0), // Optional: rounded corners
              ),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 

                children: <Widget> [

                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false; 
                      });
                      print('Task Completed'); 
                    }, 
                    // child: Text('+'),

                  ),

                  Text(randomWord, 
                  style: TextStyle( 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                  ),
                  ), 

                  ElevatedButton(
                    onPressed: () {
                      print('Button Pressed'); 
                    }, 
                    child: Text('+'),

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
