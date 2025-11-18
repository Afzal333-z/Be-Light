import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 5)
class AchievementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category; // streak, weight_loss, meals_logged, consistency, etc.

  @HiveField(4)
  int points;

  @HiveField(5)
  String iconName;

  @HiveField(6)
  String rarity; // common, rare, epic, legendary

  @HiveField(7)
  bool isUnlocked;

  @HiveField(8)
  DateTime? unlockedAt;

  @HiveField(9)
  int currentProgress;

  @HiveField(10)
  int requiredProgress;

  @HiveField(11)
  String? rewardType; // coins, premium_day, unlock_feature, badge

  @HiveField(12)
  dynamic rewardValue;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.points = 10,
    required this.iconName,
    this.rarity = 'common',
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
    required this.requiredProgress,
    this.rewardType,
    this.rewardValue,
  });

  double get progressPercentage {
    if (requiredProgress == 0) return 100.0;
    return (currentProgress / requiredProgress * 100).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'iconName': iconName,
      'rarity': rarity,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
      'requiredProgress': requiredProgress,
      'rewardType': rewardType,
      'rewardValue': rewardValue,
    };
  }
}

// Pre-defined achievements
class Achievements {
  static List<AchievementModel> getDefaultAchievements() {
    return [
      // Streak Achievements
      AchievementModel(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Log meals for 3 days in a row',
        category: 'streak',
        points: 10,
        iconName: 'fire',
        rarity: 'common',
        requiredProgress: 3,
      ),
      AchievementModel(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        category: 'streak',
        points: 25,
        iconName: 'fire',
        rarity: 'rare',
        requiredProgress: 7,
      ),
      AchievementModel(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        category: 'streak',
        points: 100,
        iconName: 'fire',
        rarity: 'epic',
        requiredProgress: 30,
        rewardType: 'premium_day',
        rewardValue: 1,
      ),
      AchievementModel(
        id: 'streak_100',
        title: 'Century Champion',
        description: 'Maintain a 100-day streak',
        category: 'streak',
        points: 500,
        iconName: 'fire',
        rarity: 'legendary',
        requiredProgress: 100,
        rewardType: 'premium_day',
        rewardValue: 7,
      ),

      // Weight Loss Achievements
      AchievementModel(
        id: 'weight_loss_1kg',
        title: 'First Milestone',
        description: 'Lose your first 1kg',
        category: 'weight_loss',
        points: 20,
        iconName: 'scale',
        rarity: 'common',
        requiredProgress: 1,
      ),
      AchievementModel(
        id: 'weight_loss_5kg',
        title: 'Halfway Hero',
        description: 'Lose 5kg',
        category: 'weight_loss',
        points: 100,
        iconName: 'scale',
        rarity: 'rare',
        requiredProgress: 5,
      ),
      AchievementModel(
        id: 'weight_loss_10kg',
        title: 'Transformation Master',
        description: 'Lose 10kg',
        category: 'weight_loss',
        points: 250,
        iconName: 'scale',
        rarity: 'epic',
        requiredProgress: 10,
      ),

      // Meal Logging Achievements
      AchievementModel(
        id: 'meals_10',
        title: 'Food Explorer',
        description: 'Log 10 meals',
        category: 'meals_logged',
        points: 10,
        iconName: 'camera',
        rarity: 'common',
        requiredProgress: 10,
      ),
      AchievementModel(
        id: 'meals_50',
        title: 'Dedicated Logger',
        description: 'Log 50 meals',
        category: 'meals_logged',
        points: 50,
        iconName: 'camera',
        rarity: 'rare',
        requiredProgress: 50,
      ),
      AchievementModel(
        id: 'meals_100',
        title: 'Meal Tracking Pro',
        description: 'Log 100 meals',
        category: 'meals_logged',
        points: 150,
        iconName: 'camera',
        rarity: 'epic',
        requiredProgress: 100,
      ),

      // Consistency Achievements
      AchievementModel(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Log all 3 meals every day for a week',
        category: 'consistency',
        points: 50,
        iconName: 'check',
        rarity: 'rare',
        requiredProgress: 21, // 7 days * 3 meals
      ),

      // Healthy Choices
      AchievementModel(
        id: 'protein_goal_7',
        title: 'Protein Power',
        description: 'Meet your protein goal for 7 days',
        category: 'nutrition',
        points: 30,
        iconName: 'protein',
        rarity: 'rare',
        requiredProgress: 7,
      ),
    ];
  }
}
