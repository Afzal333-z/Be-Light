import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final achievements = appProvider.achievements;
          final user = appProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final unlockedCount =
              achievements.where((a) => a.isUnlocked).length;

          return Column(
            children: [
              // Stats Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total Points',
                      user.totalPoints.toString(),
                      Icons.stars,
                    ),
                    _buildStatItem(
                      'Unlocked',
                      '$unlockedCount/${achievements.length}',
                      Icons.emoji_events,
                    ),
                    _buildStatItem(
                      'Streak',
                      '${user.currentStreak} days',
                      Icons.local_fire_department,
                    ),
                  ],
                ),
              ),

              // Achievements List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(achievement);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercentage;

    Color rarityColor;
    switch (achievement.rarity) {
      case 'legendary':
        rarityColor = const Color(0xFFFFD700);
        break;
      case 'epic':
        rarityColor = const Color(0xFFFF6584);
        break;
      case 'rare':
        rarityColor = const Color(0xFF6C63FF);
        break;
      default:
        rarityColor = const Color(0xFF4CAF50);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? Border.all(color: rarityColor, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? rarityColor.withOpacity(0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? '🏆' : '🔒',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${achievement.points} pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: rarityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: rarityColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentProgress}/${achievement.requiredProgress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50))
        .fadeIn()
        .slideX(begin: -0.2, end: 0);
  }
}
