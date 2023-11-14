import 'dart:math';

List<String> Activities = [
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

// GRABS RANDOM ELEMENT FROM LIST 

T getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
}

void main() {
    var list = Activities;
    var element = getRandomElement(list);
    print(element);  
}