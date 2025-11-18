import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/meal_model.dart';
import '../models/nutrition_model.dart';

class MealLoggingScreen extends StatefulWidget {
  const MealLoggingScreen({super.key});

  @override
  State<MealLoggingScreen> createState() => _MealLoggingScreenState();
}

class _MealLoggingScreenState extends State<MealLoggingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String _selectedMealType = 'breakfast';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
        await _analyzeImage();
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _analyzeImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      final result = await appProvider.analyzeMealImage(_imageFile!.path);

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('Failed to analyze image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (_imageFile == null || _analysisResult == null) {
      _showError('Please capture and analyze a meal first');
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Parse nutrition from analysis result
    final nutritionData = _analysisResult!['nutrition'] ?? {};
    final nutrition = NutritionModel.fromJson(nutritionData);

    final meal = MealModel(
      id: const Uuid().v4(),
      userId: appProvider.currentUser!.id,
      timestamp: DateTime.now(),
      mealType: _selectedMealType,
      photoPath: _imageFile!.path,
      foodItems: List<String>.from(_analysisResult!['foodItems'] ?? []),
      nutrition: nutrition,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isAnalyzed: true,
      aiAnalysis: _analysisResult,
      tags: List<String>.from(_analysisResult!['tags'] ?? []),
    );

    await appProvider.addMeal(meal);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal logged successfully! 🎉'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    // Reset form
    setState(() {
      _imageFile = null;
      _analysisResult = null;
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal Type Selection
            const Text(
              'Meal Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMealTypeChip('Breakfast', 'breakfast', Icons.wb_sunny),
                const SizedBox(width: 8),
                _buildMealTypeChip('Lunch', 'lunch', Icons.lunch_dining),
                const SizedBox(width: 8),
                _buildMealTypeChip('Dinner', 'dinner', Icons.dinner_dining),
                const SizedBox(width: 8),
                _buildMealTypeChip('Snack', 'snack', Icons.cookie),
              ],
            ),

            const SizedBox(height: 24),

            // Image Capture Section
            if (_imageFile == null) ...[
              _buildImageCapture(),
            ] else ...[
              _buildImagePreview(),
            ],

            const SizedBox(height: 24),

            // Analysis Result
            if (_isAnalyzing) ...[
              _buildAnalyzingIndicator(),
            ] else if (_analysisResult != null) ...[
              _buildAnalysisResult(),
            ],

            const SizedBox(height: 24),

            // Notes Section
            if (_imageFile != null) ...[
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How did you feel? Any observations?',
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            if (_analysisResult != null)
              ElevatedButton(
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Save Meal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(String label, String value, IconData icon) {
    final isSelected = _selectedMealType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMealType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCapture() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Capture Your Meal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo to get instant nutrition analysis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _imageFile!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _analysisResult = null;
                  });
                },
              ),
            ),
          ),
          if (!_isAnalyzing && _analysisResult == null)
            Positioned(
              bottom: 8,
              right: 8,
              child: ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyze'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Analyzing your meal...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI is identifying food items and calculating nutrition',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: const Duration(seconds: 2));
  }

  Widget _buildAnalysisResult() {
    final nutrition = NutritionModel.fromJson(_analysisResult!['nutrition'] ?? {});
    final foodItems = List<String>.from(_analysisResult!['foodItems'] ?? []);
    final healthScore = _analysisResult!['healthScore'] ?? 5;
    final recommendations = _analysisResult!['recommendations'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 8),
                    const Text(
                      'Detected Foods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: foodItems.map((item) {
                    return Chip(
                      label: Text(item),
                      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn()
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 8),
                    const Text(
                      'Nutrition Facts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildNutritionRow('Calories', '${nutrition.calories.toInt()} kcal'),
                _buildNutritionRow('Protein', '${nutrition.protein.toInt()}g'),
                _buildNutritionRow('Carbs', '${nutrition.carbs.toInt()}g'),
                _buildNutritionRow('Fats', '${nutrition.fats.toInt()}g'),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 100))
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 12),

        if (recommendations.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Color(0xFFFFB800)),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recommendations,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 200))
              .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
