import 'package:hive/hive.dart';

part 'medication.g.dart';

/// Status of a scheduled dose.
enum DoseStatus { upcoming, taken, skipped }

/// Unit for medication dosage.
enum DoseUnit { mg, ml }

@HiveType(typeId: 0)
class Medication extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double dosage;

  @HiveField(3)
  final String unit; // 'mg' or 'ml'

  @HiveField(4)
  final String scheduledTime; // Stored as 'HH:mm' (24-hour)

  @HiveField(5)
  final String? instructions;

  @HiveField(6)
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.scheduledTime,
    this.instructions,
    required this.createdAt,
  });

  /// Parse the scheduledTime string into a TimeOfDay.
  DateTime get scheduledDateTime {
    final parts = scheduledTime.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

@HiveType(typeId: 1)
class DoseLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String status; // 'taken', 'skipped'

  @HiveField(4)
  final DateTime? actionTime; // When the user tapped Taken/Skipped

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.status,
    this.actionTime,
  });
}
