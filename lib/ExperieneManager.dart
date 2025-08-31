import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExperienceManager with ChangeNotifier {
  int _experience = 0;
  int _gold = 0;
  int _gems = 0;

  int get experience => _experience;
  int get gold => _gold;
  int get gems => _gems;

  ExperienceManager() {
    _loadData();
  }

  // Load from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _experience = prefs.getInt('experience') ?? 0;
    _gold = prefs.getInt('gold') ?? 0;
    _gems = prefs.getInt('gems') ?? 0;
    notifyListeners();
  }

  // Save to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('experience', _experience);
    await prefs.setInt('gold', _gold);
    await prefs.setInt('gems', _gems);
  }

  // Add resources
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

  // Spend resources
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


  // Reset all
  void resetAll() {
    _experience = 0;
    _gold = 0;
    _gems = 0;
    _saveData();
    notifyListeners();
  }

  // ---------------------------
  // LEVEL SYSTEM
  // ---------------------------
  int get level {
    // Example: 100 XP per level
    return (_experience ~/ 100) + 1;
  }

  int get currentLevelXP {
    return _experience % 100;
  }

  int get requiredXPForNextLevel {
    return 100;
  }

  double get levelProgress {
    return currentLevelXP / requiredXPForNextLevel;
  }
}
