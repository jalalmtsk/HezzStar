import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String _fullName = '';
  String _username = '';
  int _age = 0;
  String _nationality = '';
  String _gender = '';
  String _preferredLanguage = 'en'; // default

  UserProfile({
    String fullName = '',
    String username = '',
    int age = 0,
    String nationality = '',
    String gender = '',
    String preferredLanguage = 'en',
  }) {
    _fullName = fullName;
    _username = username;
    _age = age;
    _nationality = nationality;
    _gender = gender;
    _preferredLanguage = preferredLanguage;
  }

  // Getters
  String get fullName => _fullName;
  String get username => _username;
  int get age => _age;
  String get nationality => _nationality;
  String get gender => _gender;
  String get preferredLanguage => _preferredLanguage;

  // Setters
  set fullName(String value) => _fullName = value;
  set username(String value) => _username = value;
  set age(int value) => _age = value;
  set nationality(String value) => _nationality = value;
  set gender(String value) => _gender = value;
  set preferredLanguage(String value) => _preferredLanguage = value;




  factory UserProfile.fromPrefs(SharedPreferences prefs) {
    return UserProfile(
      fullName: prefs.getString('fullName') ?? '',
      username: prefs.getString('username') ?? '',
      age: prefs.getInt('age') ?? 0,
      nationality: prefs.getString('nationality') ?? '',
      gender: prefs.getString('gender') ?? '',
      preferredLanguage: prefs.getString('preferredLanguage') ?? 'en',
    );
  }

  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setString('fullName', _fullName);
    await prefs.setString('username', _username);
    await prefs.setInt('age', _age);
    await prefs.setString('nationality', _nationality);
    await prefs.setString('gender', _gender);
    await prefs.setString('preferredLanguage', _preferredLanguage);
  }

  Future<void> clearPrefs(SharedPreferences prefs) async {
    await prefs.remove('fullName');
    await prefs.remove('username');
    await prefs.remove('age');
    await prefs.remove('nationality');
    await prefs.remove('gender');
    await prefs.remove('preferredLanguage');
  }
}
