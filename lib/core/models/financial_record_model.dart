import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialRecord {
  final String id;
  final double salary;
  final double extraIncome;
  final double emi;
  final int year;
  final int month;
  final double effectiveIncome;
  final double necessities;
  final double lifestyle;
  final double investment;
  final double emergency;
  final double buffer;
  final Timestamp createdAt;

  final double necessitiesPercentage;
  final double lifestylePercentage;
  final double investmentPercentage;
  final double emergencyPercentage;
  final double bufferPercentage;

  FinancialRecord({
    required this.id,
    required this.salary,
    required this.extraIncome,
    required this.emi,
    required this.year,
    required this.month,
    required this.effectiveIncome,
    required this.necessities,
    required this.lifestyle,
    required this.investment,
    required this.emergency,
    required this.buffer,
    required this.createdAt,
    required this.necessitiesPercentage,
    required this.lifestylePercentage,
    required this.investmentPercentage,
    required this.emergencyPercentage,
    required this.bufferPercentage,
  });

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FinancialRecord(
      id: doc.id,
      salary: (data['salary'] ?? 0.0).toDouble(),
      extraIncome: (data['extraIncome'] ?? 0.0).toDouble(),
      emi: (data['emi'] ?? 0.0).toDouble(),
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      effectiveIncome: (data['effectiveIncome'] ?? 0.0).toDouble(),
      necessities: (data['necessities'] ?? 0.0).toDouble(),
      lifestyle: (data['lifestyle'] ?? 0.0).toDouble(),
      investment: (data['investment'] ?? 0.0).toDouble(),
      emergency: (data['emergency'] ?? 0.0).toDouble(),
      buffer: (data['buffer'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      necessitiesPercentage: (data['necessitiesPercentage'] ?? 45.0).toDouble(),
      lifestylePercentage: (data['lifestylePercentage'] ?? 15.0).toDouble(),
      investmentPercentage: (data['investmentPercentage'] ?? 20.0).toDouble(),
      emergencyPercentage: (data['emergencyPercentage'] ?? 5.0).toDouble(),
      bufferPercentage: (data['bufferPercentage'] ?? 15.0).toDouble(),
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
      'necessities': necessities,
      'lifestyle': lifestyle,
      'investment': investment,
      'emergency': emergency,
      'buffer': buffer,
      'createdAt': createdAt,
      'necessitiesPercentage': necessitiesPercentage,
      'lifestylePercentage': lifestylePercentage,
      'investmentPercentage': investmentPercentage,
      'emergencyPercentage': emergencyPercentage,
      'bufferPercentage': bufferPercentage,
    };
  }
}
