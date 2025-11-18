import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class QuickStatsWidget extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;

  const QuickStatsWidget({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    // Recommended daily values (adjustable based on user goals)
    const proteinGoal = 150.0; // grams
    const carbsGoal = 200.0; // grams
    const fatsGoal = 65.0; // grams

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Protein
            _buildMacroStat(
              'Protein',
              protein,
              proteinGoal,
              const Color(0xFFFF6584),
              Icons.fitness_center,
            ),

            const SizedBox(height: 16),

            // Carbs
            _buildMacroStat(
              'Carbs',
              carbs,
              carbsGoal,
              const Color(0xFFFFB800),
              Icons.bakery_dining,
            ),

            const SizedBox(height: 16),

            // Fats
            _buildMacroStat(
              'Fats',
              fats,
              fatsGoal,
              const Color(0xFF4CAF50),
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroStat(
    String name,
    double current,
    double goal,
    Color color,
    IconData icon,
  ) {
    final percent = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${current.toInt()}g / ${goal.toInt()}g',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8.0,
          percent: percent,
          backgroundColor: Colors.grey.shade200,
          progressColor: color,
          barRadius: const Radius.circular(4),
          animation: true,
          animationDuration: 1000,
        ),
      ],
    );
  }
}
