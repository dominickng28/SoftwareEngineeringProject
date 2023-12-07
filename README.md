[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/LvSokF5s)
# live4you

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building and Running

First choose a simulated device to run on. The below is for windows and android but you should choose iPhone for your mac.
![image](https://github.com/UNCW-CSC-450/csc450-fa23-project-team-4/assets/96816207/d8de44d1-69c6-4c68-90f5-f4ec9f44f0a2)

Once the sim device is running, either use the in IDE terminal and type the command "flutter run" or click this button in VSCODE while main.dart is selected.

![image](https://github.com/UNCW-CSC-450/csc450-fa23-project-team-4/assets/96816207/6fc8a2d3-12bb-4410-9574-0b1a71c9d5c2)


BLACK BOX TESTING
Testing if the navigation from the original login screen takes you to the sign up screen. When you press the sign up button you should be navigated to the next screen. <-- Testing that

Run flutter test in the terminal of the navigation_test.dart file

If it passes then you know the navigation from the login screen is correct. 

## Created by...
* Yusuf Qureshi
* Nick Palmieri
* Dominick Ng
* Daniel Ruiz Valencia 
* Kenneth Dearstine
* Nate Smith

## Test instructions:

Using the flutter_test and mockito package. 
Create a new dart file for your test case. 
Mock the functionality of firebase via mockito that plugs into the componenet you are testing.
Finally run your test using flutter test lib/yourtestscript

## Build instructions:

Before you begin, ensure you have met the following requirements:
- You have installed the latest version of Flutter
- You have a Windows/Linux/Mac machine.

To install the live4you repo, follow these steps:

1. Clone the repository
```bash
git clone https://github.com/yusuflkq/live4you.git

2. Navigate to the project directory
cd live4you

3. Get Flutter packages
flutter pub get

4. Run the app
flutter run

Testing Friends List:

The user can tap the 'friends' button to view everyone currently following them:
Step 1: Create a new account through the sign up page
Step 2: Sign out of this account
Step 3: Create a second new account through the sign up page
Step 4: Search for the first account you created and send them a friend request
Step 5: Sign out of this account
Step 6: Sign in to the first account
Step 7: Accept the friend request from the second account
Step 8: Go your profile page
Step 9: Press the friends button underneath

Testing google sign in:

Step 1: open the test google login in script
Step 2: in the terminal run flutter test lib/google_login_test.dart
