import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final todayNutrition = appProvider.getTodayNutrition();
          final user = appProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorie Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Weekly Calorie Intake',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: true),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 1800),
                                    const FlSpot(1, 2100),
                                    const FlSpot(2, 1950),
                                    const FlSpot(3, 2200),
                                    const FlSpot(4, 1900),
                                    const FlSpot(5, 2000),
                                    const FlSpot(6, 2050),
                                  ],
                                  isCurved: true,
                                  color: const Color(0xFF6C63FF),
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Macros Pie Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Today\'s Macros',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: todayNutrition.protein,
                                  title: 'Protein',
                                  color: const Color(0xFFFF6584),
                                  radius: 100,
                                ),
                                PieChartSectionData(
                                  value: todayNutrition.carbs,
                                  title: 'Carbs',
                                  color: const Color(0xFFFFB800),
                                  radius: 100,
                                ),
                                PieChartSectionData(
                                  value: todayNutrition.fats,
                                  title: 'Fats',
                                  color: const Color(0xFF4CAF50),
                                  radius: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
