import 'nutrition_model.dart';

class MealModel {
  String id;
  String userId;
  DateTime timestamp;
  String mealType;
  String? photoPath;
  String? photoUrl;
  List<String> foodItems;
  NutritionModel nutrition;
  String? notes;
  int? rating;
  String? mood;
  bool isAnalyzed;
  Map<String, dynamic>? aiAnalysis;
  List<String>? tags;

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
