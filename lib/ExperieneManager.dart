import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Manager/HelperClass/FlyingRewardManager.dart';
import 'Manager/HelperClass/RewardDimScreen.dart';
import 'Manager/UserProfileManager.dart';

class ExperienceManager with ChangeNotifier {
  late UserProfile userProfile = UserProfile();

  int _experience = 0;
  int _gold = 500;
  int _gems = 25;

  // ---------------------------
  // CARD SYSTEM
  // ---------------------------
  List<String> _unlockedCards = ["assets/images/cards/backCard.png"];
  String? _selectedCard;

  // ---------------------------
  // AVATAR SYSTEM
  // ---------------------------
  List<String> _unlockedAvatars = ["assets/images/Skins/AvatarSkins/DefaultUser.png"];
  String? _selectedAvatar;

  // ---------------------------
  // GETTERS
  // ---------------------------
  int get experience => _experience;
  int get gold => _gold;
  int get gems => _gems;

  List<String> get unlockedCards => _unlockedCards;
  String? get selectedCard => _selectedCard;

  List<String> get unlockedAvatars => _unlockedAvatars;
  String? get selectedAvatar => _selectedAvatar;

  List<String> get unlockedTableSkins => _unlockedTableSkins;
  String? get selectedTableSkin => _selectedTableSkin;

  List<String> _unlockedTableSkins = ["assets/images/Skins/TableSkins/table1.jpg"];
  String? _selectedTableSkin;

  String get preferredLanguage => userProfile.preferredLanguage;

  // ---------------------------
  // USER PROFILE GETTERS
  // ---------------------------
  String get fullName => userProfile.fullName;
  String get username => userProfile.username;
  int get age => userProfile.age;
  String get nationality => userProfile.nationality;
  String get gender => userProfile.gender;

  ExperienceManager() {
    _loadData();
  }

  // ---------------------------
  // LOAD / SAVE DATA
  // ---------------------------
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load resources
    _experience = prefs.getInt('experience') ?? 0;
    _gold = prefs.getInt('gold') ?? 500;
    _gems = prefs.getInt('gems') ?? 25;

    _unlockedCards = prefs.getStringList('unlockedCards') ?? ["assets/images/cards/backCard.png"];
    _selectedCard = prefs.getString('selectedCard') ?? _unlockedCards.first;

    _unlockedAvatars = prefs.getStringList('unlockedAvatars') ?? ["assets/images/Skins/AvatarSkins/DefaultUser.png"];
    _selectedAvatar = prefs.getString('selectedAvatar') ?? _unlockedAvatars.first;

    _unlockedTableSkins = prefs.getStringList('unlockedTableSkins') ?? ["assets/images/Skins/TableSkins/table1.jpg"];
    _selectedTableSkin = prefs.getString('selectedTableSkin') ?? _unlockedTableSkins.first;

    // Load profile
    userProfile = UserProfile.fromPrefs(prefs);

    notifyListeners();
  }


  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save resources
    await prefs.setInt('experience', _experience);
    await prefs.setInt('gold', _gold);
    await prefs.setInt('gems', _gems);
    await prefs.setStringList('unlockedCards', _unlockedCards);
    await prefs.setStringList('unlockedAvatars', _unlockedAvatars);
    await prefs.setStringList('unlockedTableSkins', _unlockedTableSkins);
    if (_selectedTableSkin != null) await prefs.setString('selectedTableSkin', _selectedTableSkin!);
    if (_selectedCard != null) await prefs.setString('selectedCard', _selectedCard!);
    if (_selectedAvatar != null) await prefs.setString('selectedAvatar', _selectedAvatar!);

    // Save profile
    await userProfile.saveToPrefs(prefs);
  }

  // ---------------------------
  // RESOURCE MANAGEMENT
  // ---------------------------

  Future<void> addExperience(int amount, {BuildContext? context, GlobalKey? gemsKey}) async {
    int oldLevel = level; // before adding XP
    _experience += amount;
    int newLevel = level; // after adding XP

    if (newLevel > oldLevel) {
      int levelsGained = newLevel - oldLevel;
      int gemsReward = 5 * levelsGained; // 5 gems per level

      _gems += gemsReward;

      // Show reward animation if context & key are provided
      if (context != null && gemsKey != null) {
        RewardDimScreen.show(
          context,
          start: const Offset(200, 400), // optionally adjust start position
          endKey: gemsKey,
          amount: gemsReward,
          type: RewardType.gem,
        );
      }
    }

    await _saveData();
    notifyListeners();
  }


  Future<void> addGold(int amount) async {
    _gold += amount;
    await _saveData();
    notifyListeners();
  }

  Future<void> addGems(int amount) async {
    _gems += amount;
    await _saveData();
    notifyListeners();
  }

  Future<bool> spendGold(int amount) async {
    if (_gold >= amount) {
      _gold -= amount;
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (_gems >= amount) {
      _gems -= amount;
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      double result = number / 1000000;
      return result % 1 == 0 ? "${result.toInt()}M" : "${result.toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      double result = number / 1000;
      return result % 1 == 0 ? "${result.toInt()}K" : "${result.toStringAsFixed(1)}K";
    } else {
      return number.toString();
    }
  }

  Future<void> resetAll() async {
    _experience = 0;
    _gold = 500;
    _gems = 25;
    _unlockedCards = ["assets/images/cards/backCard.png"];
    _selectedCard = null;
    _unlockedAvatars = ["assets/images/Skins/AvatarSkins/DefaultUser.png"];
    _selectedAvatar = null;
    _unlockedTableSkins = ["assets/images/Skins/TableSkins/table1.jpg"];
    _selectedTableSkin = null;


    final prefs = await SharedPreferences.getInstance();
    await userProfile.clearPrefs(prefs);

    await _saveData();
    notifyListeners();
  }

  // ---------------------------
  // LEVEL SYSTEM
  // ---------------------------
  int get level => (_experience ~/ 100) + 1;
  int get currentLevelXP => _experience % 100;
  int get requiredXPForNextLevel => 100;
  double get levelProgress => currentLevelXP / requiredXPForNextLevel;

  // ---------------------------
  // CARD SYSTEM
  // ---------------------------
  Future<void> unlockCard(String cardPath) async {
    if (!_unlockedCards.contains(cardPath)) {
      _unlockedCards.add(cardPath);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> selectCard(String cardPath) async {
    if (_unlockedCards.contains(cardPath)) {
      _selectedCard = cardPath;
      await _saveData();
      notifyListeners();
    }
  }

  bool isCardUnlocked(String cardPath) => _unlockedCards.contains(cardPath);

// ---------------------------
// TABLE SKIN MANAGEMENT
// ---------------------------
  Future<void> unlockTableSkin(String skinPath) async {
    if (!_unlockedTableSkins.contains(skinPath)) {
      _unlockedTableSkins.add(skinPath);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> selectTableSkin(String skinPath) async {
    if (_unlockedTableSkins.contains(skinPath)) {
      _selectedTableSkin = skinPath;
      await _saveData();
      notifyListeners();
    }
  }

  bool isTableSkinUnlocked(String skinPath) => _unlockedTableSkins.contains(skinPath);


  // ---------------------------
  // AVATAR SYSTEM
  // ---------------------------
  Future<void> unlockAvatar(String avatarPath) async {
    if (!_unlockedAvatars.contains(avatarPath)) {
      _unlockedAvatars.add(avatarPath);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> selectAvatar(String avatarPath) async {
    if (_unlockedAvatars.contains(avatarPath)) {
      _selectedAvatar = avatarPath;
      await _saveData();
      notifyListeners();
    }
  }

  bool isAvatarUnlocked(String avatarPath) => _unlockedAvatars.contains(avatarPath);

  // ---------------------------
  // PROFILE SETTERS
  // ---------------------------
  Future<void> setFullName(String name) async {
    userProfile.fullName = name;
    await _saveData();
    notifyListeners();
  }

  Future<void> setUsername(String name) async {
    userProfile.username = name;
    await _saveData();
    notifyListeners();
  }

  Future<void> setAge(int age) async {
    userProfile.age = age;
    await _saveData();
    notifyListeners();
  }

  Future<void> setNationality(String nationality) async {
    userProfile.nationality = nationality;
    await _saveData();
    notifyListeners();
  }

  Future<void> setGender(String gender) async {
    userProfile.gender = gender;
    await _saveData();
    notifyListeners();
  }

  Future<void> setPreferredLanguage(String languageCode) async {
    userProfile.preferredLanguage = languageCode;
    await _saveData();
    notifyListeners();
  }
}
