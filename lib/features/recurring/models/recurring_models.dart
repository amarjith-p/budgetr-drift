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

  // Smart Fields
  final String scheduleType; // 'Fixed' or 'Smart'
  final int? weekParam; // 1, 2, 3, 4, -1 (Last)
  final int? dayParam; // 1 (Mon) to 7 (Sun)

  // [NEW] Scale Up Fields
  final bool isVariable; // If true, pauses for amount input
  final DateTime? endDate; // Optional stop date
  final int? maxOccurrences; // Optional stop count
  final int occurrencesProcessed;
  final String? website; // For Favicons
  final bool notifyBefore;

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
    this.isVariable = false,
    this.endDate,
    this.maxOccurrences,
    this.occurrencesProcessed = 0,
    this.website,
    this.notifyBefore = true,
    required this.nextRunAt,
    this.isActive = true,
    this.autoExecute = true,
  });
}
