import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/weight_entry_model.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addWeightEntry() async {
    final weight = double.tryParse(_weightController.text);

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight')),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final entry = WeightEntryModel(
      id: const Uuid().v4(),
      userId: appProvider.currentUser!.id,
      date: DateTime.now(),
      weight: weight,
    );

    await appProvider.addWeightEntry(entry);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight logged successfully! ⚖️'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    _weightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracking'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final user = appProvider.currentUser;
          final entries = appProvider.weightEntries;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeightStat(
                              'Current',
                              user.currentWeight,
                              const Color(0xFF6C63FF),
                            ),
                            _buildWeightStat(
                              'Target',
                              user.targetWeight,
                              const Color(0xFF4CAF50),
                            ),
                            _buildWeightStat(
                              'Remaining',
                              (user.currentWeight - user.targetWeight).abs(),
                              const Color(0xFFFF6584),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: user.progressPercentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF6C63FF),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user.progressPercentage.toStringAsFixed(1)}% to goal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Weight Chart
                if (entries.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weight Progress',
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
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(show: true),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: entries
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(
                                            e.key.toDouble(), e.value.weight))
                                        .toList(),
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
                  const SizedBox(height: 20),
                ],

                // Add Weight Entry
                const Text(
                  'Log Weight',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addWeightEntry,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeightStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}kg',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
