import 'dart:math';

class PlayerNameGenerator {
  static final List<String> _names = [
    "ShadowWolf",
    "LuckyAce",
    "IronFist",
    "GoldenFox",
    "BlazeKing",
    "SilverMoon",
    "NightHunter",
    "DragonHeart",
    "MysticElf",
    "StormRider",
    "CrimsonBlade",
    "PhantomSoul",
  ];

  static String randomName() {
    final rand = Random();
    // 30% chance → make it "User_xxxx"
    if (rand.nextInt(10) < 3) {
      return "User_${1000 + rand.nextInt(9000)}";
    }
    return _names[rand.nextInt(_names.length)];
  }
}
