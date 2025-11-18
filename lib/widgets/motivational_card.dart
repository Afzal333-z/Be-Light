import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/app_provider.dart';

class MotivationalCard extends StatefulWidget {
  const MotivationalCard({super.key});

  @override
  State<MotivationalCard> createState() => _MotivationalCardState();
}

class _MotivationalCardState extends State<MotivationalCard> {
  String _message = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMotivation();
  }

  Future<void> _loadMotivation() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      final message = await appProvider.getMotivationalMessage();
      setState(() {
        _message = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = _getDefaultMotivation();
        _isLoading = false;
      });
    }
  }

  String _getDefaultMotivation() {
    final messages = [
      'Every meal logged is a step toward your goal! 🌟',
      'Your dedication is paying off! Keep going! 💪',
      'Small progress is still progress! 🎯',
      'You\'re building healthy habits one day at a time! 🌱',
      'Consistency is key, and you\'re showing up! 🔥',
      'Believe in yourself - you\'ve got this! ✨',
      'Your future self will thank you! 🙌',
    ];

    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            // Message
            Expanded(
              child: _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.5),
                      highlightColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Motivation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
            ),

            // Refresh button
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadMotivation();
                },
              ),
          ],
        ),
      ),
    );
  }
}
