import 'ExperieneManager.dart';

enum TaskRewardType { xp, gold, gem }

class Task {
  final String id;          // Unique ID, language-independent
  final String? title;
  final TaskRewardType rewardType;
  final int rewardAmount;
  final bool Function(ExperienceManager) condition;
  bool claimed = false;

  Task({
    required this.id,
     this.title,
    required this.rewardType,
    required this.rewardAmount,
    required this.condition,
    this.claimed = false,
  });

  bool get isUnlocked => condition.call(ExperienceManager()); // or pass manager
}
