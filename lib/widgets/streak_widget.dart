import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6584), Color(0xFFFF4D6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Fire icon with animation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 40,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: const Duration(milliseconds: 1000)),

            const SizedBox(width: 20),

            // Streak information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currentStreak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'days',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Longest: $longestStreak days',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Motivation badge
            if (currentStreak >= 7)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStreakBadge(currentStreak),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: const Duration(seconds: 2)),
          ],
        ),
      ),
    );
  }

  String _getStreakBadge(int streak) {
    if (streak >= 100) return '👑 LEGEND';
    if (streak >= 30) return '🔥 ON FIRE';
    if (streak >= 14) return '⭐ AMAZING';
    if (streak >= 7) return '💪 STRONG';
    return '';
  }
}
