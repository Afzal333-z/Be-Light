class WeightEntryModel {
  String id;
  String userId;
  DateTime date;
  double weight;
  double? bodyFat;
  double? muscleMass;
  double? waterPercentage;
  String? notes;
  String? source;

  WeightEntryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
    this.waterPercentage,
    this.notes,
    this.source = 'manual',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'waterPercentage': waterPercentage,
      'notes': notes,
      'source': source,
    };
  }

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      bodyFat: json['bodyFat']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      waterPercentage: json['waterPercentage']?.toDouble(),
      notes: json['notes'],
      source: json['source'] ?? 'manual',
    );
  }
}
