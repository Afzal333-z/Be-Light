import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/weight_entry_model.dart';
import '../models/journal_entry_model.dart';
import '../models/achievement_model.dart';
import '../models/nutrition_model.dart';
import '../services/data_service.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final GeminiService _geminiService = GeminiService();
  final NotificationService _notificationService = NotificationService();

  UserModel? _currentUser;
  List<MealModel> _meals = [];
  List<WeightEntryModel> _weightEntries = [];
  List<JournalEntryModel> _journalEntries = [];
  List<AchievementModel> _achievements = [];

  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<MealModel> get meals => _meals;
  List<WeightEntryModel> get weightEntries => _weightEntries;
  List<JournalEntryModel> get journalEntries => _journalEntries;
  List<AchievementModel> get achievements => _achievements;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user data
      _currentUser = _dataService.getUser();

      if (_currentUser != null) {
        // Load all data
        try {
          await loadAllData();
        } catch (e) {
          print('Error loading data: $e');
        }

        // Record daily login and update streak
        try {
          await _dataService.recordDailyLogin();
          _currentUser = _dataService.getUser(); // Refresh user data
        } catch (e) {
          print('Error recording login: $e');
        }

        // Check for new achievements
        try {
          await _checkAchievements();
        } catch (e) {
          print('Error checking achievements: $e');
        }
      }

      // Load theme preference
      try {
        _isDarkMode = _dataService.getSetting('dark_mode', defaultValue: false);
      } catch (e) {
        print('Error loading theme: $e');
        _isDarkMode = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error initializing app: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    _meals = _dataService.getAllMeals();
    _weightEntries = _dataService.getAllWeightEntries();
    _journalEntries = _dataService.getAllJournalEntries();
    _achievements = _dataService.getAllAchievements();

    // Initialize achievements if empty
    if (_achievements.isEmpty) {
      await _dataService.initializeAchievements();
      _achievements = _dataService.getAllAchievements();
    }

    notifyListeners();
  }

  // User operations
  Future<void> createUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dataService.saveUser(user);
      _currentUser = user;

      // Schedule notifications
      await _notificationService.scheduleMealReminders(
        breakfastHour: 8,
        lunchHour: 13,
        dinnerHour: 19,
      );

      await loadAllData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _dataService.saveUser(user);
    _currentUser = user;
    notifyListeners();
  }

  // Meal operations
  Future<void> addMeal(MealModel meal) async {
    await _dataService.saveMeal(meal);
    _meals = _dataService.getAllMeals();

    // Check meal-related achievements
    await _checkMealAchievements();

    notifyListeners();
  }

  Future<void> deleteMeal(String mealId) async {
    await _dataService.deleteMeal(mealId);
    _meals = _dataService.getAllMeals();
    notifyListeners();
  }

  List<MealModel> getTodayMeals() {
    return _dataService.getMealsByDate(DateTime.now());
  }

  NutritionModel getTodayNutrition() {
    return _dataService.getTodayNutrition();
  }

  // Analyze meal with AI
  Future<Map<String, dynamic>> analyzeMealImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _geminiService.analyzeMealImage(imagePath);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get meal suggestions
  Future<List<Map<String, dynamic>>> getMealSuggestions({
    required String mealType,
    required int calorieTarget,
  }) async {
    if (_currentUser == null) return [];

    return await _geminiService.getMealSuggestions(
      mealType: mealType,
      calorieTarget: calorieTarget,
      dietaryPreference: _currentUser!.preferences?['dietary_preference'] ?? 'balanced',
    );
  }

  // Weight operations
  Future<void> addWeightEntry(WeightEntryModel entry) async {
    await _dataService.saveWeightEntry(entry);
    _weightEntries = _dataService.getAllWeightEntries();
    _currentUser = _dataService.getUser(); // Refresh user

    // Check weight achievements
    await _checkWeightAchievements();

    notifyListeners();
  }

  // Journal operations
  Future<void> addJournalEntry(JournalEntryModel entry) async {
    await _dataService.saveJournalEntry(entry);
    _journalEntries = _dataService.getAllJournalEntries();
    notifyListeners();
  }

  // Achievement checking
  Future<void> _checkAchievements() async {
    if (_currentUser == null) return;

    // Check streak achievements
    final streak = _currentUser!.currentStreak;
    final streakMilestones = [3, 7, 30, 100];

    for (var milestone in streakMilestones) {
      if (streak >= milestone) {
        await _dataService.updateAchievementProgress('streak_$milestone', streak);
      }
    }

    // Refresh achievements
    _achievements = _dataService.getAllAchievements();

    // Check for newly unlocked achievements
    final newlyUnlocked = _achievements.where((a) =>
        a.isUnlocked &&
        a.unlockedAt != null &&
        a.unlockedAt!.isAfter(DateTime.now().subtract(const Duration(seconds: 5))));

    for (var achievement in newlyUnlocked) {
      await _notificationService.showAchievementNotification(
        title: achievement.title,
        description: achievement.description,
        points: achievement.points,
      );
    }

    notifyListeners();
  }

  Future<void> _checkMealAchievements() async {
    final totalMeals = _meals.length;
    final mealMilestones = [10, 50, 100];

    for (var milestone in mealMilestones) {
      if (totalMeals >= milestone) {
        await _dataService.updateAchievementProgress('meals_$milestone', totalMeals);
      }
    }

    _achievements = _dataService.getAllAchievements();
    notifyListeners();
  }

  Future<void> _checkWeightAchievements() async {
    if (_currentUser == null || _weightEntries.length < 2) return;

    final sortedWeights = List<WeightEntryModel>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final initialWeight = sortedWeights.first.weight;
    final currentWeight = sortedWeights.last.weight;
    final weightLost = (initialWeight - currentWeight).abs();

    final weightMilestones = [1, 5, 10];

    for (var milestone in weightMilestones) {
      if (weightLost >= milestone) {
        await _dataService.updateAchievementProgress(
            'weight_loss_${milestone}kg', weightLost.toInt());
      }
    }

    _achievements = _dataService.getAllAchievements();
    notifyListeners();
  }

  // Get motivational message
  Future<String> getMotivationalMessage() async {
    if (_currentUser == null) {
      return 'Welcome! Let\'s start your journey! 💪';
    }

    return await _geminiService.getMotivationalMessage(
      streak: _currentUser!.currentStreak,
      weightProgress: _currentUser!.progressPercentage,
      userName: _currentUser!.name,
    );
  }

  // Theme toggle
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _dataService.saveSetting('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Calculate daily calorie goal
  int calculateDailyCalorieGoal() {
    if (_currentUser == null) return 2000;

    final tdee = _currentUser!.tdee;

    switch (_currentUser!.goal) {
      case 'lose_weight':
        return (tdee - 500).round(); // 500 calorie deficit
      case 'gain_weight':
        return (tdee + 300).round(); // 300 calorie surplus
      case 'maintain_weight':
      default:
        return tdee.round();
    }
  }

  // Get today's calorie progress
  double getTodayCalorieProgress() {
    if (_currentUser == null) return 0.0;

    final todayNutrition = getTodayNutrition();
    final goal = _currentUser!.dailyCalorieGoal;

    if (goal == 0) return 0.0;

    return (todayNutrition.calories / goal).clamp(0.0, 2.0);
  }

  // Clear all data (logout)
  Future<void> logout() async {
    await _dataService.clearAllData();
    _currentUser = null;
    _meals = [];
    _weightEntries = [];
    _journalEntries = [];
    _achievements = [];
    notifyListeners();
  }
}
