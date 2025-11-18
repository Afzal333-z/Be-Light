import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/nutrition_model.dart';
import '../models/weight_entry_model.dart';
import '../models/journal_entry_model.dart';
import '../models/achievement_model.dart';

// Simple data service using SharedPreferences for local storage
// This works without code generation and is suitable for demo/testing
// For production, consider switching to Hive with build_runner or SQLite

class DataService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('DataService initialized');
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString('current_user', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userJson = _prefs?.getString('current_user');
    if (userJson == null) return null;
    
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel(
        id: map['id'],
        name: map['name'],
        age: map['age'],
        gender: map['gender'],
        height: map['height'].toDouble(),
        currentWeight: map['currentWeight'].toDouble(),
        targetWeight: map['targetWeight'].toDouble(),
        activityLevel: map['activityLevel'],
        goal: map['goal'],
        dailyCalorieGoal: map['dailyCalorieGoal'],
        createdAt: DateTime.parse(map['createdAt']),
        currentStreak: map['currentStreak'] ?? 0,
        longestStreak: map['longestStreak'] ?? 0,
        totalPoints: map['totalPoints'] ?? 0,
        achievements: List<String>.from(map['achievements'] ?? []),
        isPremium: map['isPremium'] ?? false,
        premiumExpiryDate: map['premiumExpiryDate'] != null 
            ? DateTime.parse(map['premiumExpiryDate']) 
            : null,
        loginDates: (map['loginDates'] as List?)?.map((e) => DateTime.parse(e)).toList() ?? [],
        preferences: map['preferences'],
      );
    } catch (e) {
      print('Error parsing user: $e');
      return null;
    }
  }

  Future<void> updateUserStreak(int streak) async {
    final user = getUser();
    if (user != null) {
      user.currentStreak = streak;
      if (streak > user.longestStreak) {
        user.longestStreak = streak;
      }
      await saveUser(user);
    }
  }

  Future<void> updateUserWeight(double weight) async {
    final user = getUser();
    if (user != null) {
      user.currentWeight = weight;
      await saveUser(user);
    }
  }

  Future<void> addUserPoints(int points) async {
    final user = getUser();
    if (user != null) {
      user.totalPoints += points;
      await saveUser(user);
    }
  }

  // Meal operations
  Future<void> saveMeal(MealModel meal) async {
    final meals = getAllMeals();
    meals.add(meal);
    final mealsJson = meals.map((m) => m.toJson()).toList();
    await _prefs?.setString('meals', jsonEncode(mealsJson));
  }

  Future<void> deleteMeal(String mealId) async {
    final meals = getAllMeals();
    meals.removeWhere((m) => m.id == mealId);
    final mealsJson = meals.map((m) => m.toJson()).toList();
    await _prefs?.setString('meals', jsonEncode(mealsJson));
  }

  List<MealModel> getAllMeals() {
    final mealsJson = _prefs?.getString('meals');
    if (mealsJson == null) return [];
    
    try {
      final list = jsonDecode(mealsJson) as List;
      return list.map((json) => MealModel.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing meals: $e');
      return [];
    }
  }

  List<MealModel> getMealsByDate(DateTime date) {
    return getAllMeals().where((meal) {
      return meal.timestamp.year == date.year &&
          meal.timestamp.month == date.month &&
          meal.timestamp.day == date.day;
    }).toList();
  }

  List<MealModel> getMealsByDateRange(DateTime start, DateTime end) {
    return getAllMeals().where((meal) {
      return meal.timestamp.isAfter(start) && meal.timestamp.isBefore(end);
    }).toList();
  }

  NutritionModel getTodayNutrition() {
    final todayMeals = getMealsByDate(DateTime.now());
    NutritionModel total = NutritionModel();

    for (var meal in todayMeals) {
      total = total + meal.nutrition;
    }

    return total;
  }

  // Weight operations
  Future<void> saveWeightEntry(WeightEntryModel entry) async {
    final entries = getAllWeightEntries();
    entries.add(entry);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString('weight_entries', jsonEncode(entriesJson));
    await updateUserWeight(entry.weight);
  }

  Future<void> deleteWeightEntry(String entryId) async {
    final entries = getAllWeightEntries();
    entries.removeWhere((e) => e.id == entryId);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString('weight_entries', jsonEncode(entriesJson));
  }

  List<WeightEntryModel> getAllWeightEntries() {
    final entriesJson = _prefs?.getString('weight_entries');
    if (entriesJson == null) return [];
    
    try {
      final list = jsonDecode(entriesJson) as List;
      final entries = list.map((json) => WeightEntryModel.fromJson(json)).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      print('Error parsing weight entries: $e');
      return [];
    }
  }

  WeightEntryModel? getLatestWeightEntry() {
    final entries = getAllWeightEntries();
    return entries.isEmpty ? null : entries.first;
  }

  // Journal operations
  Future<void> saveJournalEntry(JournalEntryModel entry) async {
    final entries = getAllJournalEntries();
    entries.add(entry);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString('journal_entries', jsonEncode(entriesJson));
  }

  Future<void> deleteJournalEntry(String entryId) async {
    final entries = getAllJournalEntries();
    entries.removeWhere((e) => e.id == entryId);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString('journal_entries', jsonEncode(entriesJson));
  }

  List<JournalEntryModel> getAllJournalEntries() {
    final entriesJson = _prefs?.getString('journal_entries');
    if (entriesJson == null) return [];
    
    try {
      final list = jsonDecode(entriesJson) as List;
      final entries = list.map((json) => JournalEntryModel.fromJson(json)).toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      print('Error parsing journal entries: $e');
      return [];
    }
  }

  List<JournalEntryModel> getJournalEntriesByDate(DateTime date) {
    return getAllJournalEntries().where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  // Achievement operations
  Future<void> initializeAchievements() async {
    final achievements = getAllAchievements();
    
    if (achievements.isEmpty) {
      final defaultAchievements = Achievements.getDefaultAchievements();
      final achievementsJson = defaultAchievements.map((a) => a.toJson()).toList();
      await _prefs?.setString('achievements', jsonEncode(achievementsJson));
    }
  }

  Future<void> saveAchievement(AchievementModel achievement) async {
    final achievements = getAllAchievements();
    final index = achievements.indexWhere((a) => a.id == achievement.id);
    
    if (index != -1) {
      achievements[index] = achievement;
    } else {
      achievements.add(achievement);
    }
    
    final achievementsJson = achievements.map((a) => a.toJson()).toList();
    await _prefs?.setString('achievements', jsonEncode(achievementsJson));
  }

  List<AchievementModel> getAllAchievements() {
    final achievementsJson = _prefs?.getString('achievements');
    if (achievementsJson == null) return [];
    
    try {
      final list = jsonDecode(achievementsJson) as List;
      return list.map((json) {
        return AchievementModel(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          category: json['category'],
          points: json['points'],
          iconName: json['iconName'],
          rarity: json['rarity'],
          isUnlocked: json['isUnlocked'],
          unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
          currentProgress: json['currentProgress'],
          requiredProgress: json['requiredProgress'],
          rewardType: json['rewardType'],
          rewardValue: json['rewardValue'],
        );
      }).toList();
    } catch (e) {
      print('Error parsing achievements: $e');
      return [];
    }
  }

  List<AchievementModel> getUnlockedAchievements() {
    return getAllAchievements().where((a) => a.isUnlocked).toList();
  }

  Future<void> unlockAchievement(String achievementId, int points) async {
    final achievements = getAllAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);

    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      await saveAchievement(achievement);
      await addUserPoints(points);
    }
  }

  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final achievements = getAllAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);

    achievement.currentProgress = progress;

    if (progress >= achievement.requiredProgress && !achievement.isUnlocked) {
      await unlockAchievement(achievementId, achievement.points);
    } else {
      await saveAchievement(achievement);
    }
  }

  // Streak calculation
  int calculateCurrentStreak() {
    final user = getUser();
    if (user == null) return 0;

    final loginDates = user.loginDates;
    if (loginDates.isEmpty) return 0;

    loginDates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayDate;

    for (var loginDate in loginDates) {
      final normalizedLogin = DateTime(loginDate.year, loginDate.month, loginDate.day);

      if (normalizedLogin == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedLogin.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  Future<void> recordDailyLogin() async {
    final user = getUser();
    if (user == null) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final alreadyLogged = user.loginDates.any((date) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      return normalizedDate == todayDate;
    });

    if (!alreadyLogged) {
      user.loginDates.add(today);

      final newStreak = calculateCurrentStreak();
      user.currentStreak = newStreak;
      if (newStreak > user.longestStreak) {
        user.longestStreak = newStreak;
      }

      await saveUser(user);
      await _checkStreakAchievements(newStreak);
    }
  }

  Future<void> _checkStreakAchievements(int streak) async {
    final streakMilestones = [3, 7, 30, 100];

    for (var milestone in streakMilestones) {
      if (streak >= milestone) {
        await updateAchievementProgress('streak_$milestone', streak);
      }
    }
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is String) {
      await _prefs?.setString(key, value);
    }
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _prefs?.get(key) ?? defaultValue;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
