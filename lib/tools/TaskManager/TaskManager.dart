import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ExperieneManager.dart';
import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Tasks.dart';
import '../../main.dart';
import '../../widgets/userStatut/globalKeyUserStatusBar.dart' as TaskRewardKeys;

class TaskManager {
  final ExperienceManager manager;
  List<Task> tasks = [];

  TaskManager(this.manager);

  // Use a separate init function to properly await
  Future<void> init(BuildContext context) async {
    tasks = [

//TODO: TASK EARN GOLD
      Task(
        id: "welcome",
        title: tr(context).welcome,
        rewardType: TaskRewardType.gold,
        rewardAmount: 200,
        condition: (manager) => manager.level >= 1,
      ),
      Task(
        id: "earn_1k_gold",
        title: tr(context).earnGold(1000),
        rewardType: TaskRewardType.xp,
        rewardAmount: 5,
        condition: (manager) => manager.totalGoldEarned >= 1000,
      ),
      Task(
        id: "earn_2k_gold",
        title: "Earn 2K Gold",
        rewardType: TaskRewardType.gem,
        rewardAmount: 1,
        condition: (manager) => manager.totalGoldEarned >= 2000,
      ),
      Task(
        id: "earn_30k_gold",
        title: "Earn 30,000 Gold",
        rewardType: TaskRewardType.gold,
        rewardAmount: 4500,
        condition: (manager) => manager.totalGoldEarned >= 30000,
      ),

      Task(
        id: "earn_100k_gold",
        title: "Earn 100,000 Gold",
        rewardType: TaskRewardType.gem,
        rewardAmount: 5,
        condition: (manager) => manager.totalGoldEarned >= 100000,
      ),
      Task(
        id: "earn_500k_gold",
        title: "Earn 500,000 Gold",
        rewardType: TaskRewardType.xp,
        rewardAmount: 100,
        condition: (manager) => manager.totalGoldEarned >= 500000,
      ),

      //TODO: TASK 1VS1 WINS
      Task(
        id: "win_15_games_1vs1",
        title: "Win 15 Games 1v1",
        rewardType: TaskRewardType.gem,
        rewardAmount: 1,
        condition: (manager) => manager.wins1v1 >= 15,
      ),
      Task(
        id: "win_25_games_1vs1",
        title: "Win 25 Games 1v1",
        rewardType: TaskRewardType.gem,
        rewardAmount: 2,
        condition: (manager) => manager.wins1v1 >= 25,
      ),
      Task(
        id: "win_50_games_1vs1",
        title: "Win 50 Games 1v1",
        rewardType: TaskRewardType.gold,
        rewardAmount: 10000,
        condition: (manager) => manager.wins1v1 >= 50,
      ),

      Task(
        id: "win_70_games_1vs1",
        title: "Win 70 Games 1v1",
        rewardType: TaskRewardType.xp,
        rewardAmount: 350,
        condition: (manager) => manager.wins1v1 >= 70,
      ),

      Task(
        id: "win_100_games_1vs1",
        title: "Win 100 Games 1v1",
        rewardType: TaskRewardType.gem,
        rewardAmount: 10,
        condition: (manager) => manager.wins1v1 >= 100,
      ),
      Task(
        id: "win_120_games_1vs1",
        title: "Win 120 Games 1v1",
        rewardType: TaskRewardType.gem,
        rewardAmount: 12,
        condition: (manager) => manager.wins1v1 >= 120,
      ),

      //TODO: TASK REACH LEVEL
      Task(
        id: "reach_level_10",
        title: "Reach Level 10",
        rewardType: TaskRewardType.gem,
        rewardAmount: 3,
        condition: (manager) => manager.level >= 10,
      ),
      Task(
        id: "reach_level_15",
        title: "Reach Level 15",
        rewardType: TaskRewardType.xp,
        rewardAmount: 25,
        condition: (manager) => manager.level >= 15,
      ),
      Task(
        id: "reach_level_35",
        title: "Reach Level 35",
        rewardType: TaskRewardType.xp,
        rewardAmount: 50,
        condition: (manager) => manager.level >= 35,
      ),
      Task(
        id: "reach_level_50",
        title: "Reach Level 50",
        rewardType: TaskRewardType.xp,
        rewardAmount: 80,
        condition: (manager) => manager.level >= 50,
      ),

      //TODO: TASK 3 PLAYERS WINS
      Task(
        id: "win_3_games_3players",
        title: "Win 3 Games 3 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 1000,
        condition: (manager) => manager.wins3Players >= 3,
      ),
      Task(
        id: "win_15_games_3players",
        title: "Win 15 Games 3 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 1500,
        condition: (manager) => manager.wins3Players >= 15,
      ),

      Task(
        id: "win_25_games_3players",
        title: "Win 25 Games 3 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 2500,
        condition: (manager) => manager.wins3Players >= 25,
      ),

      Task(
        id: "win_50_games_3players",
        title: "Win 50 Games 3 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 10000,
        condition: (manager) => manager.wins3Players >= 50,
      ),

      //TODO: TASK 4 PLAYERS WINS
      Task(
        id: "win_10_games_4players",
        title: "Win 10 Games 4 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 2000,
        condition: (manager) => manager.wins4Players >= 10,
      ),
      Task(
        id: "win_20_games_4players",
        title: "Win 20 Games 4 Players",
        rewardType: TaskRewardType.gold,
        rewardAmount: 4000,
        condition: (manager) => manager.wins4Players >= 20,
      ),
      Task(
        id: "win_40_games_4players",
        title: "Win 40 Games 4 Players",
        rewardType: TaskRewardType.xp,
        rewardAmount: 300,
        condition: (manager) => manager.wins4Players >= 40,
      ),
      Task(
        id: "win_65_games_4players",
        title: "Win 65 Games 4 Players",
        rewardType: TaskRewardType.xp,
        rewardAmount: 450,
        condition: (manager) => manager.wins4Players >= 65,
      ),
      Task(
        id: "win_80_games_4players",
        title: "Win 80 Games 4 Players",
        rewardType: TaskRewardType.gem,
        rewardAmount: 15,
        condition: (manager) => manager.wins4Players >= 80,
      ),
      Task(
        id: "win_100_games_4players",
        title: "Win 100 Games 4 Players",
        rewardType: TaskRewardType.gem,
        rewardAmount: 20,
        condition: (manager) => manager.wins4Players >= 100,
      ),
      Task(
        id: "win_150_games_4players",
        title: "Win 150 Games 4 Players",
        rewardType: TaskRewardType.xp,
        rewardAmount: 400,
        condition: (manager) => manager.wins4Players >= 150,
      ),

      //TODO: TASK 5 PLAYERS WINS
      Task(
        id: "win_20_games_5players",
        title: "Win 20 Games 5 Players",
        rewardType: TaskRewardType.gem,
        rewardAmount: 20,
        condition: (manager) => manager.wins5Players >= 20,
      ),

      Task(
        id: "win_30_games_5players",
        title: "Win 30 Games 5 Players",
        rewardType: TaskRewardType.xp,
        rewardAmount: 120,
        condition: (manager) => manager.wins5Players >= 30,
      ),

      Task(
        id: "win_50_games_5players",
        title: "Win 50 Games 5 Players",
        rewardType: TaskRewardType.gem,
        rewardAmount: 50,
        condition: (manager) => manager.wins5Players >= 50,
      ),
      Task(
        id: "win_800_games_5players",
        title: "Win 80 Games 5 Players",
        rewardType: TaskRewardType.xp,
        rewardAmount: 250,
        condition: (manager) => manager.wins5Players >= 80,
      ),
      Task(
        id: "win_120_games_5players",
        title: "Win 120 Games 5 Players",
        rewardType: TaskRewardType.gem,
        rewardAmount: 100,
        condition: (manager) => manager.wins5Players >= 120,
      ),
      //TODO: TASK AVATARS/ CARD / TABLE

      Task(
        id: "unlock_new_cardSkin",
        title: "Unlock Your First SKin Card",
        rewardType: TaskRewardType.gem,
        rewardAmount: 2,
        condition: (manager) => manager.unlockedCards.length >= 2,
      ),
      Task(
        id: "unlock_new_avatarSkin",
        title: "Unlock a New Avatar",
        rewardType: TaskRewardType.gem,
        rewardAmount: 2,
        condition: (manager) => manager.unlockedAvatars.length >= 2,
      ),
      Task(
        id: "unlock_new_tableSkin",
        title: "Unlock a New TableSkin",
        rewardType: TaskRewardType.gem,
        rewardAmount: 2,
        condition: (manager) => manager.unlockedTableSkins.length >= 2,
      ),

      //TODO: TASK TOTAL WINS

      Task(
        id: "reach_100_winsTotal",
        title: "Reach 100 Wins Total",
        rewardType: TaskRewardType.xp,
        rewardAmount: 220,
        condition: (manager) =>
        manager.wins1v1 + manager.wins3Players + manager.wins4Players + manager.wins5Players >= 100,
      ),

      Task(
        id: "reach_350_winsTotal",
        title: "Reach 350 Wins Total",
        rewardType: TaskRewardType.gem,
        rewardAmount: 150,
        condition: (manager) =>
        manager.wins1v1 + manager.wins3Players + manager.wins4Players + manager.wins5Players >= 350,
      ),
    ];


    await _loadClaimedTasks();
    manager.notifyListeners();
  }

  bool canClaim(Task task) => !task.claimed && task.condition(manager);

  Future<void> _loadClaimedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> claimedTaskIds = prefs.getStringList('claimedTasks') ?? [];
    for (var task in tasks) {
      task.claimed = claimedTaskIds.contains(task.id);
    }
  }

  Future<void> saveClaimedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> claimedTaskIds =
    tasks.where((t) => t.claimed).map((t) => t.id).toList();
    await prefs.setStringList('claimedTasks', claimedTaskIds);
  }



  Future<void> claimTask(Task task, BuildContext context, GlobalKey? _) async {
    if (!task.claimed && task.condition(manager)) {
      task.claimed = true;
      await saveClaimedTasks();

      // Add rewards properly
      switch (task.rewardType) {
        case TaskRewardType.gold:
          await manager.addGold(task.rewardAmount);
          break;
        case TaskRewardType.gem:
          await manager.addGems(task.rewardAmount);
          break;
        case TaskRewardType.xp:
          await manager.addExperience(task.rewardAmount);
          break;
      }

      // Reward animation
      final startOffset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );

      GlobalKey? targetKey;
      RewardType rewardType;

      switch (task.rewardType) {
        case TaskRewardType.xp:
          targetKey = TaskRewardKeys.xpKey;
          rewardType = RewardType.star;
          break;
        case TaskRewardType.gold:
          targetKey = TaskRewardKeys.goldKey;
          rewardType = RewardType.gold;
          break;
        case TaskRewardType.gem:
          targetKey = TaskRewardKeys.gemsKey;
          rewardType = RewardType.gem;
          break;
      }

      manager.notifyListeners();
    }
  }

}
