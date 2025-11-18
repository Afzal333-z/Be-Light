import 'package:hive/hive.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 4)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String mood; // happy, sad, stressed, energetic, tired, anxious, calm

  @HiveField(4)
  int moodIntensity; // 1-5

  @HiveField(5)
  String? feelings;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  int? hungerLevel; // 1-5

  @HiveField(8)
  int? energyLevel; // 1-5

  @HiveField(9)
  int? stressLevel; // 1-5

  @HiveField(10)
  int? sleepQuality; // 1-5 (from previous night)

  @HiveField(11)
  List<String>? triggers; // cravings, social_eating, boredom, stress, etc.

  @HiveField(12)
  List<String>? activities; // exercise, meditation, walk, etc.

  @HiveField(13)
  Map<String, dynamic>? metadata;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mood,
    this.moodIntensity = 3,
    this.feelings,
    this.notes,
    this.hungerLevel,
    this.energyLevel,
    this.stressLevel,
    this.sleepQuality,
    this.triggers,
    this.activities,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'moodIntensity': moodIntensity,
      'feelings': feelings,
      'notes': notes,
      'hungerLevel': hungerLevel,
      'energyLevel': energyLevel,
      'stressLevel': stressLevel,
      'sleepQuality': sleepQuality,
      'triggers': triggers,
      'activities': activities,
      'metadata': metadata,
    };
  }

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      mood: json['mood'],
      moodIntensity: json['moodIntensity'] ?? 3,
      feelings: json['feelings'],
      notes: json['notes'],
      hungerLevel: json['hungerLevel'],
      energyLevel: json['energyLevel'],
      stressLevel: json['stressLevel'],
      sleepQuality: json['sleepQuality'],
      triggers: json['triggers'] != null ? List<String>.from(json['triggers']) : null,
      activities: json['activities'] != null ? List<String>.from(json['activities']) : null,
      metadata: json['metadata'],
    );
  }
}
