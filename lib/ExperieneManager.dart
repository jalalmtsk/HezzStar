import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hezzstar/tools/TaskManager/TaskManager.dart';
import 'package:hezzstar/widgets/userStatut/globalKeyUserStatusBar.dart' as TaskRewardKeys;
import 'package:shared_preferences/shared_preferences.dart';
import 'Manager/HelperClass/FlyingRewardManager.dart';
import 'Manager/HelperClass/RewardDimScreen.dart';
import 'Manager/UserProfileManager.dart';
import 'Tasks.dart';

class ExperienceManager with ChangeNotifier {
  late UserProfile userProfile = UserProfile();
  late TaskManager taskManager;

  ExperienceManager() {
    taskManager = TaskManager(this);
    _loadData().then((_) async {
    });
  }

  int _experience = 0;
  int _gold = 500;
  int _gems = 25;
  int _totalGoldEarned = 500;

  int _wins1v1 = 0;
  int _wins3Players = 0;
  int _wins4Players = 0;
  int _wins5Players = 0;

  bool canClaim(Task task) {
    return !task.claimed && task.condition(this);
  }

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
  int get totalGoldEarned => _totalGoldEarned;

  int get wins1v1 => _wins1v1;
  int get wins3Players => _wins3Players;
  int get wins4Players => _wins4Players;
  int get wins5Players => _wins5Players;


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


  // ---------------------------
  // LOAD / SAVE DATA
  // ---------------------------
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load resources
    _experience = prefs.getInt('experience') ?? 0;
    _gold = prefs.getInt('gold') ?? 500;
    _gems = prefs.getInt('gems') ?? 25;
    _totalGoldEarned = prefs.getInt('totalGoldEarned') ?? 500;

    _wins1v1 = prefs.getInt('wins1v1') ?? 0;
    _wins3Players = prefs.getInt('wins3Players') ?? 0;
    _wins4Players = prefs.getInt('wins4Players') ?? 0;
    _wins5Players = prefs.getInt('wins5Players') ?? 0;


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
    await prefs.setInt('totalGoldEarned', _totalGoldEarned);
    await prefs.setInt('wins1v1', _wins1v1);
    await prefs.setInt('wins3Players', _wins3Players);
    await prefs.setInt('wins4Players', _wins4Players);
    await prefs.setInt('wins5Players', _wins5Players);

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

  Future<void> addExperience(
      int amount, {
        BuildContext? context,
        GlobalKey? gemsKey,
      }) async {
    int oldLevel = level;
    _experience += amount;
    int newLevel = level;

    await _saveData();
    notifyListeners();

    if (newLevel > oldLevel && context != null && gemsKey != null) {
      // Only show rewards one by one
      for (int lvl = oldLevel + 1; lvl <= newLevel; lvl++) {
        // Wait for the user to collect before continuing
        await  RewardDimScreen.show(
          context,
          start: const Offset(200, 400),
          endKey: gemsKey,
          amount: 5,
          type: RewardType.gem,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

  }




  Future<void> addGold(int amount, {BuildContext? context}) async {
    _gold += amount;
    _totalGoldEarned += amount; // track total earnings
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

  Future<void> addWin(int playerCount, {BuildContext? context}) async {
    switch (playerCount) {
      case 2:
        _wins1v1++;
        break;
      case 3:
        _wins3Players++;
        break;
      case 4:
        _wins4Players++;
        break;
      case 5:
        _wins5Players++;
        break;
    }
    await _saveData();
    notifyListeners();

  }


  Future<void> resetAll() async {
    _experience = 0;
    _gold = 500;
    _gems = 25;
    _totalGoldEarned = 500;

    _wins1v1 = 0;
    _wins3Players = 0;
    _wins4Players = 0;
    _wins5Players = 0;

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
  // LEVEL SYSTEM (Dynamic XP per level)
  // ---------------------------

  /// Returns how much XP is required for a specific level.
  int xpForLevel(int level) {
    return 100 + (level - 1) * 50; // 🔥 Linear growth
    // Or use exponential: return (100 * pow(1.2, level - 1)).round();
  }

  int get level {
    int lvl = 1;
    int xp = _experience;

    while (xp >= xpForLevel(lvl)) {
      xp -= xpForLevel(lvl);
      lvl++;
    }
    return lvl;
  }

  int get currentLevelXP {
    int xp = _experience;
    int lvl = 1;

    while (xp >= xpForLevel(lvl)) {
      xp -= xpForLevel(lvl);
      lvl++;
    }
    return xp;
  }

  int get requiredXPForNextLevel => xpForLevel(level);

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
