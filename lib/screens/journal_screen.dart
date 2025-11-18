import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/journal_entry_model.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _selectedMood = 'happy';
  int _moodIntensity = 3;
  int _hungerLevel = 3;
  int _energyLevel = 3;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'value': 'happy', 'icon': '😊', 'label': 'Happy'},
    {'value': 'energetic', 'icon': '⚡', 'label': 'Energetic'},
    {'value': 'calm', 'icon': '😌', 'label': 'Calm'},
    {'value': 'tired', 'icon': '😴', 'label': 'Tired'},
    {'value': 'stressed', 'icon': '😰', 'label': 'Stressed'},
    {'value': 'sad', 'icon': '😢', 'label': 'Sad'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveJournalEntry() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final entry = JournalEntryModel(
      id: const Uuid().v4(),
      userId: appProvider.currentUser!.id,
      timestamp: DateTime.now(),
      mood: _selectedMood,
      moodIntensity: _moodIntensity,
      notes: _notesController.text,
      hungerLevel: _hungerLevel,
      energyLevel: _energyLevel,
    );

    await appProvider.addJournalEntry(entry);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved! 📝'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    _notesController.clear();
    setState(() {
      _moodIntensity = 3;
      _hungerLevel = 3;
      _energyLevel = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = _selectedMood == mood['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['value']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood['icon'], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSlider('Hunger Level', _hungerLevel, (val) {
              setState(() => _hungerLevel = val.toInt());
            }),
            const SizedBox(height: 16),
            _buildSlider('Energy Level', _energyLevel, (val) {
              setState(() => _energyLevel = val.toInt());
            }),
            const SizedBox(height: 24),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write about your day, feelings, or observations...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveJournalEntry,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
