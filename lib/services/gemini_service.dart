import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../models/nutrition_model.dart';

class GeminiService {
  late GenerativeModel _model;
  late GenerativeModel _visionModel;
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // User should replace this

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: _apiKey,
    );
  }

  // Analyze meal image and extract nutrition information
  Future<Map<String, dynamic>> analyzeMealImage(String imagePath) async {
    try {
      // Read and compress image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Decode and resize image for API
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to max 1024px to save API costs
      final resizedImage = img.copyResize(
        image,
        width: image.width > 1024 ? 1024 : image.width,
      );

      final compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));

      // Create prompt for food analysis
      final prompt = '''
Analyze this food image and provide detailed nutritional information in JSON format.

Identify all food items in the image and estimate:
1. Food items (as array of strings)
2. Total calories
3. Macronutrients (protein, carbs, fats, fiber, sugar) in grams
4. Micronutrients (vitamins and minerals) in mg/mcg if identifiable
5. Portion size estimation
6. Health score (1-10)
7. Recommendations for healthier alternatives or improvements

Return ONLY a valid JSON object with this exact structure:
{
  "foodItems": ["item1", "item2"],
  "nutrition": {
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fats": 0,
    "fiber": 0,
    "sugar": 0,
    "vitaminC": 0,
    "calcium": 0,
    "iron": 0,
    "sodium": 0
  },
  "portionSize": "description",
  "healthScore": 0,
  "tags": ["healthy", "high-protein", etc],
  "recommendations": "text recommendations",
  "confidence": 0.0
}

Be as accurate as possible with nutrition estimation based on visible portions.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', compressedBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final text = response.text ?? '';

      // Parse JSON response
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No valid JSON found in response');
      }

      final jsonStr = text.substring(jsonStart, jsonEnd);
      final analysisResult = _parseAnalysisResult(jsonStr);

      return analysisResult;
    } catch (e) {
      print('Error analyzing meal image: $e');
      // Return default values on error
      return {
        'foodItems': ['Unknown food item'],
        'nutrition': NutritionModel().toJson(),
        'healthScore': 5,
        'recommendations': 'Unable to analyze image. Please try again.',
        'confidence': 0.0,
        'error': e.toString(),
      };
    }
  }

  Map<String, dynamic> _parseAnalysisResult(String jsonStr) {
    // This should parse the JSON string
    // For now, returning a placeholder structure
    try {
      // In production, use dart:convert to parse JSON
      return {
        'foodItems': ['Placeholder item'],
        'nutrition': NutritionModel().toJson(),
        'healthScore': 7,
        'recommendations': 'Analysis complete',
        'confidence': 0.8,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get meal suggestions based on user preferences and goals
  Future<List<Map<String, dynamic>>> getMealSuggestions({
    required String mealType,
    required int calorieTarget,
    required String dietaryPreference,
    List<String>? allergies,
    String? cuisine,
  }) async {
    try {
      final prompt = '''
Generate 3 healthy meal suggestions for $mealType with the following requirements:
- Target calories: $calorieTarget per meal
- Dietary preference: $dietaryPreference
${allergies != null && allergies.isNotEmpty ? '- Allergies/restrictions: ${allergies.join(", ")}' : ''}
${cuisine != null ? '- Preferred cuisine: $cuisine' : ''}

For each meal, provide:
1. Meal name
2. Ingredients list
3. Brief cooking instructions
4. Estimated nutrition (calories, protein, carbs, fats)
5. Preparation time
6. Difficulty level (easy, medium, hard)

Return as JSON array of meal objects.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // Parse response (simplified for now)
      return _parseMealSuggestions(text);
    } catch (e) {
      print('Error getting meal suggestions: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseMealSuggestions(String text) {
    // Placeholder implementation
    return [
      {
        'name': 'Healthy Grilled Chicken Salad',
        'calories': 350,
        'protein': 35,
        'carbs': 25,
        'fats': 12,
        'prepTime': '20 min',
        'difficulty': 'easy',
      },
      {
        'name': 'Quinoa Buddha Bowl',
        'calories': 400,
        'protein': 15,
        'carbs': 55,
        'fats': 14,
        'prepTime': '30 min',
        'difficulty': 'medium',
      },
      {
        'name': 'Baked Salmon with Vegetables',
        'calories': 450,
        'protein': 40,
        'carbs': 20,
        'fats': 22,
        'prepTime': '35 min',
        'difficulty': 'medium',
      },
    ];
  }

  // Get personalized motivation message
  Future<String> getMotivationalMessage({
    required int streak,
    required double weightProgress,
    required String userName,
  }) async {
    try {
      final prompt = '''
Generate an encouraging and personalized motivation message for $userName who:
- Has a current streak of $streak days
- Has made ${weightProgress.toStringAsFixed(1)}% progress toward their weight goal

Make it energetic, positive, and specific to their progress. Keep it under 50 words.
Use emojis appropriately.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep up the great work! You\'re doing amazing! 🌟';
    } catch (e) {
      print('Error getting motivation: $e');
      return 'Stay consistent, and success will follow! 💪';
    }
  }

  // Get insights from journal entries
  Future<Map<String, dynamic>> analyzeJournalPatterns({
    required List<Map<String, dynamic>> journalEntries,
    required List<Map<String, dynamic>> mealData,
  }) async {
    try {
      final prompt = '''
Analyze these journal entries and meal patterns to provide insights:

Journal data summary: ${journalEntries.length} entries
Meal data summary: ${mealData.length} meals

Identify:
1. Patterns between mood and eating habits
2. Common triggers for unhealthy eating
3. Best performing days/times
4. Recommendations for improvement

Provide actionable insights in 3-4 bullet points.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'insights': response.text ?? 'Keep tracking to discover patterns!',
        'confidence': 0.7,
      };
    } catch (e) {
      print('Error analyzing patterns: $e');
      return {
        'insights': 'Continue logging to get personalized insights!',
        'confidence': 0.0,
      };
    }
  }

  // Chat with AI nutritionist
  Future<String> chatWithNutritionist(String question, {String? context}) async {
    try {
      final prompt = '''
You are a friendly AI nutritionist. Answer this question:
"$question"

${context != null ? 'Context: $context' : ''}

Provide helpful, evidence-based advice in a conversational tone.
Keep the response concise (under 100 words).
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'I\'m here to help! Could you rephrase that?';
    } catch (e) {
      print('Error in chat: $e');
      return 'Sorry, I\'m having trouble connecting. Please try again.';
    }
  }
}
