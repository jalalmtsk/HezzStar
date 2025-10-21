import 'package:flutter/material.dart';
import '../../../ExperieneManager.dart';
import '../../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../../Tasks.dart';
import '../../../main.dart';

class TaskRewardListDialog {
  static Future<void> show(
      BuildContext context,
      ExperienceManager xpManager, {
        required GlobalKey goldKey,
        required GlobalKey gemsKey,
        required GlobalKey xpKey,
      }) async {
    String selectedFilter = 'All';



    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double dialogWidth = constraints.maxWidth * 0.9;
            final double dialogHeight = constraints.maxHeight * 0.8;

            return StatefulBuilder(
              builder: (context, setState) {
                final filteredTasks = xpManager.taskManager.tasks.where((task) {
                  if (selectedFilter == 'All') return true;
                  if (selectedFilter == 'Claimed') return task.claimed;
                  if (selectedFilter == 'Unclaimed') return !task.claimed && xpManager.canClaim(task);
                  if (selectedFilter == 'Unlocked') return !task.claimed && !xpManager.canClaim(task);
                  return true;
                }).toList();

                final filters = {
                  'All': tr(context).all,
                  'Claimed': tr(context).claimed,
                  'Unclaimed': tr(context).unclaimed,
                  'Unlocked': tr(context).unlocked,
                };

                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade100.withOpacity(0.9), Colors.amber.shade100.withOpacity(0.9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr(context).taskRewards,
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Colors.green.shade900, size: 28),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Filter buttons (scrollable row to avoid overflow)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: filters.entries.map((entry) {
                              final key = entry.key;
                              final label = entry.value;
                              bool isSelected = selectedFilter.toLowerCase() == key.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedFilter = key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400])
                                          : null,
                                      color: isSelected ? null : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected ? Colors.green.shade700 : Colors.green.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          key == 'Claimed'
                                              ? Icons.check_circle
                                              : key == 'Unclaimed'
                                              ? Icons.redeem
                                              : key == 'Unlocked'
                                              ? Icons.lock_open
                                              : Icons.list_alt,
                                          color: isSelected ? Colors.white : Colors.green.shade700,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.green.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),


                          ),
                        ),

                        const SizedBox(height: 10),

                        // Divider
                        Divider(
                          color: Colors.green.shade400,
                          thickness: 1.2,
                          indent: 12,
                          endIndent: 12,
                        ),

                        const SizedBox(height: 6),

                        // Task list (scrollable to prevent overflow)
                        Expanded(
                          child: filteredTasks.isEmpty
                              ? Center(
                            child: Text(
                              tr(context).noTasksAvailable,
                              style: TextStyle(color: Colors.green.shade900, fontSize: 16),
                            ),
                          )
                              : Scrollbar(
                            radius: const Radius.circular(12),
                            thumbVisibility: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                final GlobalKey buttonKey = GlobalKey();

                                // Reward icon
                                String rewardImage;
                                switch (task.rewardType) {
                                  case TaskRewardType.gold:
                                    rewardImage = 'assets/UI/Icons/Gamification/Gold_Icon.png';
                                    break;
                                  case TaskRewardType.gem:
                                    rewardImage = 'assets/UI/Icons/Gamification/Gems_Icon.png';
                                    break;
                                  case TaskRewardType.xp:
                                    rewardImage = 'assets/UI/Icons/Gamification/Xp_Icon.png';
                                    break;
                                }

                                String getLocalizedTaskTitle(Task task, BuildContext context) {
                                  switch (task.id) {
                                  // TASK EARN GOLD
                                    case "welcome": return tr(context).welcome;
                                    case "earn_1k_gold": return tr(context).earnGold(1000);
                                    case "earn_2k_gold": return tr(context).earnGold(2000);
                                    case "earn_30k_gold": return tr(context).earnGold(30000);
                                    case "earn_100k_gold": return tr(context).earnGold(100000);
                                    case "earn_500k_gold": return tr(context).earnGold(500000);

                                  // TASK 1VS1 WINS
                                    case "win_15_games_1vs1": return tr(context).win1v1(15);
                                    case "win_25_games_1vs1": return tr(context).win1v1(25);
                                    case "win_50_games_1vs1": return tr(context).win1v1(50);
                                    case "win_70_games_1vs1": return tr(context).win1v1(70);
                                    case "win_100_games_1vs1": return tr(context).win1v1(100);
                                    case "win_120_games_1vs1": return tr(context).win1v1(120);

                                  // TASK REACH LEVEL
                                    case "reach_level_10": return tr(context).reachLevel(10);
                                    case "reach_level_15": return tr(context).reachLevel(15);
                                    case "reach_level_35": return tr(context).reachLevel(35);
                                    case "reach_level_50": return tr(context).reachLevel(50);

                                  // TASK 3 PLAYERS WINS
                                    case "win_3_games_3players": return tr(context).win3Players(3);
                                    case "win_15_games_3players": return tr(context).win3Players(15);
                                    case "win_25_games_3players": return tr(context).win3Players(25);
                                    case "win_50_games_3players": return tr(context).win3Players(50);

                                  // TASK 4 PLAYERS WINS
                                    case "win_10_games_4players": return tr(context).win4Players(10);
                                    case "win_20_games_4players": return tr(context).win4Players(20);
                                    case "win_40_games_4players": return tr(context).win4Players(40);
                                    case "win_65_games_4players": return tr(context).win4Players(65);
                                    case "win_80_games_4players": return tr(context).win4Players(80);
                                    case "win_100_games_4players": return tr(context).win4Players(100);
                                    case "win_150_games_4players": return tr(context).win4Players(150);

                                  // TASK 5 PLAYERS WINS
                                    case "win_20_games_5players": return tr(context).win5Players(20);
                                    case "win_30_games_5players": return tr(context).win5Players(30);
                                    case "win_50_games_5players": return tr(context).win5Players(50);
                                    case "win_800_games_5players": return tr(context).win5Players(80);
                                    case "win_120_games_5players": return tr(context).win5Players(120);

                                  // TASK AVATARS/CARD/TABLE
                                    case "unlock_new_cardSkin": return tr(context).unlockFirstCard;
                                    case "unlock_new_avatarSkin": return tr(context).unlockFirstAvatar;
                                    case "unlock_new_tableSkin": return tr(context).unlockFirstTable;

                                  // TASK TOTAL WINS
                                    case "reach_100_winsTotal": return tr(context).totalWins(100);
                                    case "reach_350_winsTotal": return tr(context).totalWins(350);

                                  // DEFAULT fallback
                                    default: return task.id;
                                  }
                                }



                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.green.shade100, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      radius: 26,
                                      child: Image.asset(
                                        rewardImage,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    title: Text(
                                      getLocalizedTaskTitle(task, context),
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${tr(context).rewards}: ${task.rewardAmount} ${task.rewardType.name}",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: xpManager.canClaim(task)
                                        ? ElevatedButton(
                                      key: buttonKey,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      onPressed: () async {
                                        Offset startOffset = Offset(100, 100);
                                        final renderObject = buttonKey.currentContext?.findRenderObject();
                                        if (renderObject is RenderBox) {
                                          startOffset = renderObject.localToGlobal(Offset.zero);
                                        }

                                        GlobalKey targetKey;
                                        RewardType type;
                                        switch (task.rewardType) {
                                          case TaskRewardType.gold:
                                            targetKey = goldKey;
                                            type = RewardType.gold;
                                            break;
                                          case TaskRewardType.gem:
                                            targetKey = gemsKey;
                                            type = RewardType.gem;
                                            break;
                                          case TaskRewardType.xp:
                                            targetKey = xpKey;
                                            type = RewardType.star;
                                            break;
                                        }

                                        int getIconCountForVisual(int amount) {
                                          if (amount <= 500) return 5;
                                          if (amount <= 1000) return 15;
                                          if (amount <= 2000) return 17;
                                          if (amount <= 5000) return 20;
                                          return 25;
                                        }

                                        await xpManager.taskManager.claimTask(task, context, targetKey);
                                        FlyingRewardManager().spawnVisualReward(
                                          context: context,
                                          start: startOffset,
                                          endKey: targetKey,
                                          type: type,
                                          iconAmount: getIconCountForVisual(task.rewardAmount),
                                        );
                                      },
                                      child:  Text(
                                        tr(context).claim,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                        : Icon(
                                      task.claimed ? Icons.check_circle : Icons.lock_outline,
                                      color: task.claimed ? Colors.green : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
