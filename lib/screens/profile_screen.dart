import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final user = appProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF6C63FF),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!user.isPremium)
                          OutlinedButton.icon(
                            onPressed: () {
                              _showPremiumDialog(context);
                            },
                            icon: const Icon(Icons.star),
                            label: const Text('Upgrade to Premium'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFFB800),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Age', '${user.age} years'),
                        _buildStatRow('Height', '${user.height.toInt()} cm'),
                        _buildStatRow('Current Weight',
                            '${user.currentWeight.toStringAsFixed(1)} kg'),
                        _buildStatRow('Target Weight',
                            '${user.targetWeight.toStringAsFixed(1)} kg'),
                        _buildStatRow('BMI', user.bmi.toStringAsFixed(1)),
                        _buildStatRow(
                            'Daily Calorie Goal', '${user.dailyCalorieGoal} kcal'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          appProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: appProvider.isDarkMode,
                          onChanged: (value) {
                            appProvider.toggleDarkMode();
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          _showLogoutDialog(context, appProvider);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
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

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Color(0xFFFFB800)),
            SizedBox(width: 8),
            Text('Premium Features'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumFeature('Unlimited AI meal analysis'),
            _buildPremiumFeature('Advanced nutrition insights'),
            _buildPremiumFeature('Custom meal plans'),
            _buildPremiumFeature('Priority support'),
            _buildPremiumFeature('Ad-free experience'),
            const SizedBox(height: 16),
            const Text(
              '\$9.99/month or \$79.99/year',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement in-app purchase
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
