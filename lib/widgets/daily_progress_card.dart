import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DailyProgressCard extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final double progress;

  const DailyProgressCard({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = calorieGoal - caloriesConsumed;
    final percentComplete = (progress * 100).clamp(0.0, 100.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Calorie Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Circular progress indicator
                CircularPercentIndicator(
                  radius: 70.0,
                  lineWidth: 12.0,
                  percent: progress.clamp(0.0, 1.0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percentComplete.toInt()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  progressColor: _getProgressColor(progress),
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1000,
                ),

                // Calorie breakdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalorieStat(
                      'Consumed',
                      caloriesConsumed,
                      const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 12),
                    _buildCalorieStat(
                      'Goal',
                      calorieGoal,
                      Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    _buildCalorieStat(
                      'Remaining',
                      remaining,
                      remaining >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressColor(progress).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(progress),
                    color: _getProgressColor(progress),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getProgressMessage(progress, remaining),
                      style: TextStyle(
                        color: _getProgressColor(progress),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCalorieStat(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$value cal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return const Color(0xFF4CAF50);
    if (progress < 0.9) return const Color(0xFFFFB800);
    if (progress <= 1.1) return const Color(0xFF6C63FF);
    return Colors.red;
  }

  IconData _getProgressIcon(double progress) {
    if (progress < 0.5) return Icons.trending_up;
    if (progress < 0.9) return Icons.warning_amber;
    if (progress <= 1.1) return Icons.check_circle;
    return Icons.error;
  }

  String _getProgressMessage(double progress, int remaining) {
    if (progress < 0.5) {
      return 'Keep going! You have $remaining calories left today.';
    } else if (progress < 0.9) {
      return 'Good progress! $remaining calories remaining.';
    } else if (progress <= 1.1) {
      return 'Great job! You\'re on track!';
    } else {
      return 'You\'ve exceeded your goal. Consider lighter meals.';
    }
  }
}
