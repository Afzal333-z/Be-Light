import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  @HiveField(4)
  double height; // in cm

  @HiveField(5)
  double currentWeight; // in kg

  @HiveField(6)
  double targetWeight; // in kg

  @HiveField(7)
  String activityLevel; // sedentary, light, moderate, active, very_active

  @HiveField(8)
  String goal; // lose_weight, gain_weight, maintain_weight

  @HiveField(9)
  int dailyCalorieGoal;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  int currentStreak;

  @HiveField(12)
  int longestStreak;

  @HiveField(13)
  int totalPoints;

  @HiveField(14)
  List<String> achievements;

  @HiveField(15)
  bool isPremium;

  @HiveField(16)
  DateTime? premiumExpiryDate;

  @HiveField(17)
  List<DateTime> loginDates;

  @HiveField(18)
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

  // Calculate BMI
  double get bmi => currentWeight / ((height / 100) * (height / 100));

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
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

  // Progress percentage
  double get progressPercentage {
    double totalToLose = (currentWeight - targetWeight).abs();
    double initialWeight = currentWeight; // This should ideally be stored separately
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
