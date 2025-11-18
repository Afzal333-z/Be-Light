// Simple model without Hive code generation for initial setup
// To enable Hive persistence later, run: flutter pub run build_runner build

class UserModel {
  String id;
  String name;
  int age;
  String gender;
  double height;
  double currentWeight;
  double targetWeight;
  String activityLevel;
  String goal;
  int dailyCalorieGoal;
  DateTime createdAt;
  int currentStreak;
  int longestStreak;
  int totalPoints;
  List<String> achievements;
  bool isPremium;
  DateTime? premiumExpiryDate;
  List<DateTime> loginDates;
  Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieGoal,
    required this.createdAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    List<String>? achievements,
    this.isPremium = false,
    this.premiumExpiryDate,
    List<DateTime>? loginDates,
    this.preferences,
  })  : achievements = achievements ?? [],
        loginDates = loginDates ?? [];

  double get bmi => currentWeight / ((height / 100) * (height / 100));

  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }
    return bmr * multiplier;
  }

  double get progressPercentage {
    double totalToLose = (currentWeight - targetWeight).abs();
    double initialWeight = currentWeight;
    double lost = (initialWeight - currentWeight).abs();
    return totalToLose == 0 ? 100 : (lost / totalToLose) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'achievements': achievements,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'loginDates': loginDates.map((d) => d.toIso8601String()).toList(),
      'preferences': preferences,
    };
  }
}
