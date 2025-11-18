import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/app_provider.dart';
import '../widgets/streak_widget.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/motivational_card.dart';
import 'meal_logging_screen.dart';
import 'nutrition_screen.dart';
import 'journal_screen.dart';
import 'weight_tracking_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Show confetti on milestone achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMilestones();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForMilestones() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;

    if (user != null) {
      // Check if user just hit a streak milestone
      if ([3, 7, 30, 100].contains(user.currentStreak)) {
        _confettiController.play();
      }
    }
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NutritionScreen(),
    const MealLoggingScreen(),
    const JournalScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Color(0xFF6C63FF),
                Color(0xFFFF6584),
                Color(0xFF4CAF50),
                Color(0xFFFFB800),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Log Meal'),
              backgroundColor: const Color(0xFF6C63FF),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final user = appProvider.currentUser;
        final todayNutrition = appProvider.getTodayNutrition();
        final calorieProgress = appProvider.getTodayCalorieProgress();

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.emoji_events),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Widget
                    StreakWidget(
                      currentStreak: user.currentStreak,
                      longestStreak: user.longestStreak,
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Motivational Card
                    const MotivationalCard()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 100))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Daily Progress Card
                    DailyProgressCard(
                      caloriesConsumed: todayNutrition.calories.toInt(),
                      calorieGoal: user.dailyCalorieGoal,
                      progress: calorieProgress,
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 200))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Quick Stats
                    QuickStatsWidget(
                      protein: todayNutrition.protein,
                      carbs: todayNutrition.carbs,
                      fats: todayNutrition.fats,
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 300))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Today's Meals Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Meals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Meals List
                    _buildMealsList(appProvider.getTodayMeals()),

                    const SizedBox(height: 20),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildQuickActions(context),

                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  Widget _buildMealsList(List meals) {
    if (meals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No meals logged yet today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to log your first meal!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFF6C63FF),
              ),
            ),
            title: Text(
              meal.mealType.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${meal.nutrition.calories.toInt()} cal',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to meal details
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildQuickActionCard(
          context,
          icon: Icons.scale,
          title: 'Log Weight',
          color: const Color(0xFF4CAF50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WeightTrackingScreen(),
              ),
            );
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.lightbulb,
          title: 'Meal Ideas',
          color: const Color(0xFFFFB800),
          onTap: () {
            // Navigate to meal suggestions
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.water_drop,
          title: 'Water Intake',
          color: const Color(0xFF2196F3),
          onTap: () {
            // Navigate to water tracking
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.insights,
          title: 'Insights',
          color: const Color(0xFFFF6584),
          onTap: () {
            // Navigate to insights
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
