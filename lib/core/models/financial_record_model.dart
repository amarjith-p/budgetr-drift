import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialRecord {
  final String id;
  final double salary;
  final double extraIncome;
  final double emi;
  final int year;
  final int month;
  final double effectiveIncome;
  final Timestamp createdAt;
  final Timestamp updatedAt; // NEW: Track updates

  // Dynamic Allocations: Key = Category Name, Value = Amount
  final Map<String, double> allocations;
  // Snapshot of percentages used at the time of creation
  final Map<String, double> allocationPercentages;

  FinancialRecord({
    required this.id,
    required this.salary,
    required this.extraIncome,
    required this.emi,
    required this.year,
    required this.month,
    required this.effectiveIncome,
    required this.createdAt,
    required this.updatedAt, // Require in constructor
    required this.allocations,
    required this.allocationPercentages,
  });

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    Map<String, double> allocations = {};
    Map<String, double> percentages = {};

    if (data.containsKey('allocations')) {
      // Load new dynamic structure
      allocations = Map<String, double>.from(
        data['allocations'].map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      );
      if (data.containsKey('allocationPercentages')) {
        percentages = Map<String, double>.from(
          data['allocationPercentages'].map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
        );
      }
    } else {
      // Legacy support: convert old fields to map
      allocations = {
        'Necessities': (data['necessities'] ?? 0.0).toDouble(),
        'Lifestyle': (data['lifestyle'] ?? 0.0).toDouble(),
        'Investment': (data['investment'] ?? 0.0).toDouble(),
        'Emergency': (data['emergency'] ?? 0.0).toDouble(),
        'Buffer': (data['buffer'] ?? 0.0).toDouble(),
      };
      percentages = {
        'Necessities': (data['necessitiesPercentage'] ?? 45.0).toDouble(),
        'Lifestyle': (data['lifestylePercentage'] ?? 15.0).toDouble(),
        'Investment': (data['investmentPercentage'] ?? 20.0).toDouble(),
        'Emergency': (data['emergencyPercentage'] ?? 5.0).toDouble(),
        'Buffer': (data['bufferPercentage'] ?? 15.0).toDouble(),
      };
    }

    return FinancialRecord(
      id: doc.id,
      salary: (data['salary'] ?? 0.0).toDouble(),
      extraIncome: (data['extraIncome'] ?? 0.0).toDouble(),
      emi: (data['emi'] ?? 0.0).toDouble(),
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      effectiveIncome: (data['effectiveIncome'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      // Use updatedAt if available, else fallback to createdAt, else Now
      updatedAt: data['updatedAt'] ?? data['createdAt'] ?? Timestamp.now(),
      allocations: allocations,
      allocationPercentages: percentages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salary': salary,
      'extraIncome': extraIncome,
      'emi': emi,
      'year': year,
      'month': month,
      'effectiveIncome': effectiveIncome,
      'createdAt': createdAt,
      'updatedAt': updatedAt, // Save to DB
      'allocations': allocations,
      'allocationPercentages': allocationPercentages,
    };
  }
}
