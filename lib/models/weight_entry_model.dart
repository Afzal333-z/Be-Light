import 'package:hive/hive.dart';

part 'weight_entry_model.g.dart';

@HiveType(typeId: 3)
class WeightEntryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double weight; // in kg

  @HiveField(4)
  double? bodyFat; // percentage

  @HiveField(5)
  double? muscleMass; // in kg

  @HiveField(6)
  double? waterPercentage;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? source; // manual, smart_watch, scale

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
