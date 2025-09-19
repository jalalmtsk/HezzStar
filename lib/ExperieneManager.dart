import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExperienceManager with ChangeNotifier {
  int _experience = 0;
  int _gold = 0;
  int _gems = 0;

  // ---------------------------
  // CARD SYSTEM
  // ---------------------------
  List<String> _unlockedCards = [];
  String? _selectedCard;

  // ---------------------------
  // AVATAR SYSTEM
  // ---------------------------
  List<String> _unlockedAvatars = [];
  String? _selectedAvatar;

  int get experience => _experience;
  int get gold => _gold;
  int get gems => _gems;

  List<String> get unlockedCards => _unlockedCards;
  String? get selectedCard => _selectedCard;

  List<String> get unlockedAvatars => _unlockedAvatars;
  String? get selectedAvatar => _selectedAvatar;

  ExperienceManager() {
    _loadData();
  }

  // ---------------------------
  // LOAD / SAVE DATA
  // ---------------------------
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _experience = prefs.getInt('experience') ?? 0;
    _gold = prefs.getInt('gold') ?? 0;
    _gems = prefs.getInt('gems') ?? 0;

    _unlockedCards = prefs.getStringList('unlockedCards') ?? [];
    _selectedCard = prefs.getString('selectedCard');

    _unlockedAvatars = prefs.getStringList('unlockedAvatars') ?? [];
    _selectedAvatar = prefs.getString('selectedAvatar');

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('experience', _experience);
    await prefs.setInt('gold', _gold);
    await prefs.setInt('gems', _gems);
    await prefs.setStringList('unlockedCards', _unlockedCards);
    await prefs.setStringList('unlockedAvatars', _unlockedAvatars);
    if (_selectedCard != null) {
      await prefs.setString('selectedCard', _selectedCard!);
    }
    if (_selectedAvatar != null) {
      await prefs.setString('selectedAvatar', _selectedAvatar!);
    }
  }

  // ---------------------------
  // RESOURCE MANAGEMENT
  // ---------------------------
  void addExperience(int amount) {
    _experience += amount;
    _saveData();
    notifyListeners();
  }

  void addGold(int amount) {
    _gold += amount;
    _saveData();
    notifyListeners();
  }

  void addGems(int amount) {
    _gems += amount;
    _saveData();
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool spendGems(int amount) {
    if (_gems >= amount) {
      _gems -= amount;
      _saveData();
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

  void resetAll() {
    _experience = 0;
    _gold = 0;
    _gems = 0;

    _unlockedCards = [];
    _selectedCard = null;

    _unlockedAvatars = [];
    _selectedAvatar = null;

    _saveData();
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
  void unlockCard(String cardPath) {
    if (!_unlockedCards.contains(cardPath)) {
      _unlockedCards.add(cardPath);
      _saveData();
      notifyListeners();
    }
  }

  void selectCard(String cardPath) {
    if (_unlockedCards.contains(cardPath)) {
      _selectedCard = cardPath;
      _saveData();
      notifyListeners();
    }
  }

  bool isCardUnlocked(String cardPath) => _unlockedCards.contains(cardPath);

  // ---------------------------
  // AVATAR SYSTEM
  // ---------------------------
  void unlockAvatar(String avatarPath) {
    if (!_unlockedAvatars.contains(avatarPath)) {
      _unlockedAvatars.add(avatarPath);
      _saveData();
      notifyListeners();
    }
  }

  void selectAvatar(String avatarPath) {
    if (_unlockedAvatars.contains(avatarPath)) {
      _selectedAvatar = avatarPath;
      _saveData();
      notifyListeners();
    }
  }

  bool isAvatarUnlocked(String avatarPath) => _unlockedAvatars.contains(avatarPath);
}
