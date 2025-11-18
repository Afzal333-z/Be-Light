import 'package:hive/hive.dart';
import 'nutrition_model.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 1)
class MealModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String mealType; // breakfast, lunch, dinner, snack

  @HiveField(4)
  String? photoPath;

  @HiveField(5)
  String? photoUrl;

  @HiveField(6)
  List<String> foodItems;

  @HiveField(7)
  NutritionModel nutrition;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  int? rating; // 1-5 stars

  @HiveField(10)
  String? mood; // happy, neutral, sad, energetic, tired

  @HiveField(11)
  bool isAnalyzed;

  @HiveField(12)
  Map<String, dynamic>? aiAnalysis;

  @HiveField(13)
  List<String>? tags; // healthy, cheat_meal, homemade, restaurant, etc.

  MealModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mealType,
    this.photoPath,
    this.photoUrl,
    List<String>? foodItems,
    required this.nutrition,
    this.notes,
    this.rating,
    this.mood,
    this.isAnalyzed = false,
    this.aiAnalysis,
    this.tags,
  }) : foodItems = foodItems ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
      'photoPath': photoPath,
      'photoUrl': photoUrl,
      'foodItems': foodItems,
      'nutrition': nutrition.toJson(),
      'notes': notes,
      'rating': rating,
      'mood': mood,
      'isAnalyzed': isAnalyzed,
      'aiAnalysis': aiAnalysis,
      'tags': tags,
    };
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['mealType'],
      photoPath: json['photoPath'],
      photoUrl: json['photoUrl'],
      foodItems: List<String>.from(json['foodItems'] ?? []),
      nutrition: NutritionModel.fromJson(json['nutrition']),
      notes: json['notes'],
      rating: json['rating'],
      mood: json['mood'],
      isAnalyzed: json['isAnalyzed'] ?? false,
      aiAnalysis: json['aiAnalysis'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
