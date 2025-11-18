import 'package:hive/hive.dart';

part 'nutrition_model.g.dart';

@HiveType(typeId: 2)
class NutritionModel extends HiveObject {
  // Macronutrients
  @HiveField(0)
  double calories;

  @HiveField(1)
  double protein; // grams

  @HiveField(2)
  double carbs; // grams

  @HiveField(3)
  double fats; // grams

  @HiveField(4)
  double fiber; // grams

  @HiveField(5)
  double sugar; // grams

  // Micronutrients
  @HiveField(6)
  double? vitaminA; // mcg

  @HiveField(7)
  double? vitaminC; // mg

  @HiveField(8)
  double? vitaminD; // mcg

  @HiveField(9)
  double? vitaminE; // mg

  @HiveField(10)
  double? vitaminK; // mcg

  @HiveField(11)
  double? calcium; // mg

  @HiveField(12)
  double? iron; // mg

  @HiveField(13)
  double? magnesium; // mg

  @HiveField(14)
  double? potassium; // mg

  @HiveField(15)
  double? sodium; // mg

  @HiveField(16)
  double? zinc; // mg

  @HiveField(17)
  double? omega3; // grams

  @HiveField(18)
  double? cholesterol; // mg

  @HiveField(19)
  double? saturatedFat; // grams

  @HiveField(20)
  double? transFat; // grams

  NutritionModel({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.calcium,
    this.iron,
    this.magnesium,
    this.potassium,
    this.sodium,
    this.zinc,
    this.omega3,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
  });

  // Add nutrition values
  NutritionModel operator +(NutritionModel other) {
    return NutritionModel(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fats: fats + other.fats,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      vitaminA: (vitaminA ?? 0) + (other.vitaminA ?? 0),
      vitaminC: (vitaminC ?? 0) + (other.vitaminC ?? 0),
      vitaminD: (vitaminD ?? 0) + (other.vitaminD ?? 0),
      vitaminE: (vitaminE ?? 0) + (other.vitaminE ?? 0),
      vitaminK: (vitaminK ?? 0) + (other.vitaminK ?? 0),
      calcium: (calcium ?? 0) + (other.calcium ?? 0),
      iron: (iron ?? 0) + (other.iron ?? 0),
      magnesium: (magnesium ?? 0) + (other.magnesium ?? 0),
      potassium: (potassium ?? 0) + (other.potassium ?? 0),
      sodium: (sodium ?? 0) + (other.sodium ?? 0),
      zinc: (zinc ?? 0) + (other.zinc ?? 0),
      omega3: (omega3 ?? 0) + (other.omega3 ?? 0),
      cholesterol: (cholesterol ?? 0) + (other.cholesterol ?? 0),
      saturatedFat: (saturatedFat ?? 0) + (other.saturatedFat ?? 0),
      transFat: (transFat ?? 0) + (other.transFat ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
      'vitaminE': vitaminE,
      'vitaminK': vitaminK,
      'calcium': calcium,
      'iron': iron,
      'magnesium': magnesium,
      'potassium': potassium,
      'sodium': sodium,
      'zinc': zinc,
      'omega3': omega3,
      'cholesterol': cholesterol,
      'saturatedFat': saturatedFat,
      'transFat': transFat,
    };
  }

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      vitaminA: json['vitaminA']?.toDouble(),
      vitaminC: json['vitaminC']?.toDouble(),
      vitaminD: json['vitaminD']?.toDouble(),
      vitaminE: json['vitaminE']?.toDouble(),
      vitaminK: json['vitaminK']?.toDouble(),
      calcium: json['calcium']?.toDouble(),
      iron: json['iron']?.toDouble(),
      magnesium: json['magnesium']?.toDouble(),
      potassium: json['potassium']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      zinc: json['zinc']?.toDouble(),
      omega3: json['omega3']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
      saturatedFat: json['saturatedFat']?.toDouble(),
      transFat: json['transFat']?.toDouble(),
    );
  }
}
