import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'lose_weight';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _targetWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final targetWeight = double.tryParse(_targetWeightController.text) ?? 0;

    if (age <= 0 || height <= 0 || weight <= 0 || targetWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values')),
      );
      return;
    }

    // Create user model
    final user = UserModel(
      id: const Uuid().v4(),
      name: _nameController.text,
      age: age,
      gender: _gender,
      height: height,
      currentWeight: weight,
      targetWeight: targetWeight,
      activityLevel: _activityLevel,
      goal: _goal,
      dailyCalorieGoal: _calculateCalorieGoal(
        gender: _gender,
        age: age,
        height: height,
        weight: weight,
        activityLevel: _activityLevel,
        goal: _goal,
      ),
      createdAt: DateTime.now(),
    );

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.createUser(user);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/home');
  }

  int _calculateCalorieGoal({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String activityLevel,
    required String goal,
  }) {
    // BMR calculation (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
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

    double tdee = bmr * multiplier;

    // Adjust for goal
    switch (goal) {
      case 'lose_weight':
        return (tdee - 500).round();
      case 'gain_weight':
        return (tdee + 300).round();
      case 'maintain_weight':
      default:
        return tdee.round();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildPersonalInfoPage(),
                  _buildBodyMetricsPage(),
                  _buildActivityLevelPage(),
                  _buildGoalPage(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Color(0xFF6C63FF),
          ).animate().scale(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 30),
          const Text(
            'Welcome to NutriTrack!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          const SizedBox(height: 20),
          Text(
            'Your personal AI-powered meal tracking companion',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
          const SizedBox(height: 40),
          _buildFeatureItem(
            Icons.camera_alt,
            'Photo Analysis',
            'Snap a photo and get instant nutrition info',
          ),
          _buildFeatureItem(
            Icons.trending_up,
            'Track Progress',
            'Monitor weight, calories, and macros',
          ),
          _buildFeatureItem(
            Icons.emoji_events,
            'Earn Rewards',
            'Stay motivated with achievements and streaks',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This helps us personalize your experience',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gender',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  'Male',
                  _gender == 'male',
                  () => setState(() => _gender = 'male'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOptionButton(
                  'Female',
                  _gender == 'female',
                  () => setState(() => _gender = 'female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your body metrics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We need this to calculate your calorie goals',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current Weight (kg)',
              prefixIcon: Icon(Icons.monitor_weight),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Weight (kg)',
              prefixIcon: Icon(Icons.flag),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'How active are you on a typical day?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          _buildActivityOption(
            'Sedentary',
            'Little or no exercise',
            'sedentary',
          ),
          _buildActivityOption(
            'Light',
            'Exercise 1-3 days/week',
            'light',
          ),
          _buildActivityOption(
            'Moderate',
            'Exercise 3-5 days/week',
            'moderate',
          ),
          _buildActivityOption(
            'Active',
            'Exercise 6-7 days/week',
            'active',
          ),
          _buildActivityOption(
            'Very Active',
            'Intense exercise daily',
            'very_active',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'What do you want to achieve?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          _buildGoalOption(
            'Lose Weight',
            'Reduce body weight gradually',
            Icons.trending_down,
            'lose_weight',
          ),
          _buildGoalOption(
            'Gain Weight',
            'Build muscle and gain mass',
            Icons.trending_up,
            'gain_weight',
          ),
          _buildGoalOption(
            'Maintain Weight',
            'Stay at current weight',
            Icons.trending_flat,
            'maintain_weight',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityOption(String title, String subtitle, String value) {
    final isSelected = _activityLevel == value;
    return GestureDetector(
      onTap: () => setState(() => _activityLevel = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String subtitle, IconData icon, String value) {
    final isSelected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
