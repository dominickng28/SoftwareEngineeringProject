// ignore: file_names
import 'dart:math';

List<String> activities = [
  'DIY',
  'Biking',
  'Smile',
  'Run',
  'Cook',
  'Draw',
  'Read',
  'Write',
  'Hike',
  'Dance',
  'Paint',
  'Plant',
  'Yoga',
  'Travel',
  'Explore',
  'Bake',
  'Volunteer',
  'Play',
  'Study',
  'Meditate',
  'Shop',
  'Clean',
  'Listen',
  'Exercise',
  'Swim',
  'Film',
  'Listen',
  'Hug',
  'Fix',
  'Garden',
  'Skate',
  'Jump',
  'Decorate',
  'Shop',
  'Fish',
  'Sculpt',
  'Race',
  'Carve',
  'Navigate',
  'Sew',
  'Solve',
  'Repair',
  'Practice',
  'Trade',
];

List<String> activities2 = [
  'DIY',
  'Biking',
  'Smile',
  'Run',
];
// GRABS RANDOM ELEMENT FROM LIST

T getRandomElement<T>(List<T> list) {
    final random = Random();
    var i = random.nextInt(list.length);
    return list[i];
}

void main() {
    // var list = Activities;
    var list = activities2;
    var element = getRandomElement(list);
    // ignore: avoid_print
    print(element);  
}