import 'package:flutter/material.dart';

class RecurringPatternModel {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String category;
  final String subCategory;
  final String bucket;
  final String notes;
  final String? sourceAccountId;
  final String? sourceCardId;
  final String? destinationAccountId;

  final String frequency;
  final int interval;
  final DateTime startDate;
  final TimeOfDay executionTime;

  // [NEW] Smart Fields
  final String scheduleType; // 'Fixed' or 'Smart'
  final int? weekParam; // 1, 2, 3, 4, -1 (Last)
  final int? dayParam; // 1 (Mon) to 7 (Sun)

  final DateTime nextRunAt;
  final bool isActive;
  final bool autoExecute;

  RecurringPatternModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.bucket,
    required this.notes,
    this.sourceAccountId,
    this.sourceCardId,
    this.destinationAccountId,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    required this.executionTime,
    this.scheduleType = 'Fixed',
    this.weekParam,
    this.dayParam,
    required this.nextRunAt,
    this.isActive = true,
    this.autoExecute = true,
  });
}
