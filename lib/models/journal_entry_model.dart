class JournalEntryModel {
  String id;
  String userId;
  DateTime timestamp;
  String mood;
  int moodIntensity;
  String? feelings;
  String? notes;
  int? hungerLevel;
  int? energyLevel;
  int? stressLevel;
  int? sleepQuality;
  List<String>? triggers;
  List<String>? activities;
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
