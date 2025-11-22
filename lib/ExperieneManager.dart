import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hezzstar/tools/TaskManager/TaskManager.dart';
import 'package:hezzstar/widgets/userStatut/globalKeyUserStatusBar.dart' as TaskRewardKeys;
import 'Manager/HelperClass/FlyingRewardManager.dart';
import 'Manager/HelperClass/RewardDimScreen.dart';
import 'Manager/UserProfileManager.dart';
import 'Tasks.dart';

class ExperienceManager with ChangeNotifier {
  late UserProfile userProfile = UserProfile();
  late TaskManager taskManager;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? userId; // store the current Firebase user ID

  ExperienceManager() {
    taskManager = TaskManager(this);
    _init();
  }

  // ---------------------------
  // INTERNAL STATE
  // ---------------------------
  int _experience = 0;
  int _gold = 500;
  int _gems = 25;
  int _totalGoldEarned = 500;

  int _wins1v1 = 0;
  int _wins3Players = 0;
  int _wins4Players = 0;
  int _wins5Players = 0;

  List<String> _unlockedCards = ["assets/images/cards/backCard.png"];
  String? _selectedCard;

  List<String> _unlockedAvatars = ["assets/images/Skins/AvatarSkins/DefaultUser.png"];
  String? _selectedAvatar;

  List<String> _unlockedTableSkins = ["assets/images/Skins/TableSkins/table1.jpg"];
  String? _selectedTableSkin;

  // ---------------------------
  // INITIALIZATION
  // ---------------------------
  Future<void> _init() async {
    await _loadLocalData();
    await _signInAndLoadOnline();
  }

  Future<void> _signInAndLoadOnline() async {
    if (auth.currentUser == null) {
      UserCredential userCredential = await auth.signInAnonymously();
      userId = userCredential.user!.uid;
      print("Signed in anonymously with UID: $userId");
    } else {
      userId = auth.currentUser!.uid;
      print("Already signed in with UID: $userId");
    }

    await loadFromFirestore(userId!);
  }


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

  String get preferredLanguage => userProfile.preferredLanguage;

  bool isCardUnlocked(String cardPath) => _unlockedCards.contains(cardPath);
  bool isAvatarUnlocked(String avatarPath) => _unlockedAvatars.contains(avatarPath);
  bool isTableSkinUnlocked(String skinPath) => _unlockedTableSkins.contains(skinPath);


  String get fullName => userProfile.fullName;
  String get username => userProfile.username;
  int get age => userProfile.age;
  String get nationality => userProfile.nationality;
  String get gender => userProfile.gender;

  bool canClaim(Task task) => !task.claimed && task.condition(this);

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
  // LOCAL STORAGE
  // ---------------------------
  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

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

    userProfile = UserProfile.fromPrefs(prefs);

    notifyListeners();
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

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

    if (_selectedCard != null) await prefs.setString('selectedCard', _selectedCard!);
    if (_selectedAvatar != null) await prefs.setString('selectedAvatar', _selectedAvatar!);
    if (_selectedTableSkin != null) await prefs.setString('selectedTableSkin', _selectedTableSkin!);

    await userProfile.saveToPrefs(prefs);
  }

  // ---------------------------
  // FIRESTORE SYNC
  // ---------------------------
  Future<void> saveToFirestore([String? userId]) async {
    final uid = userId ?? userId;
    if (uid == null) {
      print("Cannot save: UID is null");
      return;
    }

    try {
      await firestore.collection('users').doc(uid).set({
        'experience': _experience,
        'gold': _gold,
        'gems': _gems,
        'totalGoldEarned': _totalGoldEarned,
        'wins1v1': _wins1v1,
        'wins3Players': _wins3Players,
        'wins4Players': _wins4Players,
        'wins5Players': _wins5Players,
        'selectedCard': _selectedCard,
        'selectedAvatar': _selectedAvatar,
        'selectedTableSkin': _selectedTableSkin,
        'unlockedCards': _unlockedCards,
        'unlockedAvatars': _unlockedAvatars,
        'unlockedTableSkins': _unlockedTableSkins,
        'userProfile': {
          'fullName': userProfile.fullName,
          'username': userProfile.username,
          'age': userProfile.age,
          'nationality': userProfile.nationality,
          'gender': userProfile.gender,
          'preferredLanguage': userProfile.preferredLanguage,
        },
      }, SetOptions(merge: true));
      print("Firestore saved successfully!");
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }


  Future<void> loadFromFirestore(String userId) async {
    DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      _experience = data['experience'] ?? _experience;
      _gold = data['gold'] ?? _gold;
      _gems = data['gems'] ?? _gems;
      _totalGoldEarned = data['totalGoldEarned'] ?? _totalGoldEarned;

      _wins1v1 = data['wins1v1'] ?? _wins1v1;
      _wins3Players = data['wins3Players'] ?? _wins3Players;
      _wins4Players = data['wins4Players'] ?? _wins4Players;
      _wins5Players = data['wins5Players'] ?? _wins5Players;

      _selectedCard = data['selectedCard'] ?? _selectedCard;
      _selectedAvatar = data['selectedAvatar'] ?? _selectedAvatar;
      _selectedTableSkin = data['selectedTableSkin'] ?? _selectedTableSkin;

      _unlockedCards = List<String>.from(data['unlockedCards'] ?? _unlockedCards);
      _unlockedAvatars = List<String>.from(data['unlockedAvatars'] ?? _unlockedAvatars);
      _unlockedTableSkins = List<String>.from(data['unlockedTableSkins'] ?? _unlockedTableSkins);

      if (data['userProfile'] != null) {
        Map<String, dynamic> profile = data['userProfile'];
        userProfile.fullName = profile['fullName'] ?? userProfile.fullName;
        userProfile.username = profile['username'] ?? userProfile.username;
        userProfile.age = profile['age'] ?? userProfile.age;
        userProfile.nationality = profile['nationality'] ?? userProfile.nationality;
        userProfile.gender = profile['gender'] ?? userProfile.gender;
        userProfile.preferredLanguage = profile['preferredLanguage'] ?? userProfile.preferredLanguage;
      }

      await _saveLocalData(); // sync local cache
      notifyListeners();
    }
  }

  // ---------------------------
  // RESOURCE MANAGEMENT
  // ---------------------------
  Future<void> addExperience(int amount, {BuildContext? context, GlobalKey? gemsKey}) async {
    int oldLevel = level;
    _experience += amount;
    int newLevel = level;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();

    if (newLevel > oldLevel && context != null && gemsKey != null) {
      for (int lvl = oldLevel + 1; lvl <= newLevel; lvl++) {
        await RewardDimScreen.show(
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
    _totalGoldEarned += amount;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> addGems(int amount) async {
    _gems += amount;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<bool> spendGold(int amount) async {
    if (_gold >= amount) {
      _gold -= amount;
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (_gems >= amount) {
      _gems -= amount;
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> addWin(int playerCount) async {
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
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> unlockCard(String cardPath) async {
    if (!_unlockedCards.contains(cardPath)) {
      _unlockedCards.add(cardPath);
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  Future<void> selectCard(String cardPath) async {
    if (_unlockedCards.contains(cardPath)) {
      _selectedCard = cardPath;
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  Future<void> unlockAvatar(String avatarPath) async {
    if (!_unlockedAvatars.contains(avatarPath)) {
      _unlockedAvatars.add(avatarPath);
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  Future<void> selectAvatar(String avatarPath) async {
    if (_unlockedAvatars.contains(avatarPath)) {
      _selectedAvatar = avatarPath;
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  Future<void> unlockTableSkin(String skinPath) async {
    if (!_unlockedTableSkins.contains(skinPath)) {
      _unlockedTableSkins.add(skinPath);
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  Future<void> selectTableSkin(String skinPath) async {
    if (_unlockedTableSkins.contains(skinPath)) {
      _selectedTableSkin = skinPath;
      await _saveLocalData();
      await saveToFirestore();
      notifyListeners();
    }
  }

  // ---------------------------
  // LEVEL SYSTEM
  // ---------------------------
  int xpForLevel(int level) => 100 + (level - 1) * 50;

  // ---------------------------
  // PROFILE SETTERS
  // ---------------------------
  Future<void> setFullName(String name) async {
    userProfile.fullName = name;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> setUsername(String name) async {
    userProfile.username = name;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> setAge(int age) async {
    userProfile.age = age;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> setNationality(String nationality) async {
    userProfile.nationality = nationality;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> setGender(String gender) async {
    userProfile.gender = gender;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }

  Future<void> setPreferredLanguage(String languageCode) async {
    userProfile.preferredLanguage = languageCode;
    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }





  // ---------------------------
  // RESET
  // ---------------------------
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

    await _saveLocalData();
    await saveToFirestore();
    notifyListeners();
  }
}
