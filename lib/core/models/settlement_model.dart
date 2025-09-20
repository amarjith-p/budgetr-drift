import 'package:cloud_firestore/cloud_firestore.dart';

class Settlement {
  final String id;
  final int year;
  final int month;

  final double necessitiesAllocation;
  final double necessitiesExpense;
  final double necessitiesBalance;

  final double lifestyleAllocation;
  final double lifestyleExpense;
  final double lifestyleBalance;

  final double investmentAllocation;
  final double investmentExpense;
  final double investmentBalance;

  final double emergencyAllocation;
  final double emergencyExpense;
  final double emergencyBalance;

  final double bufferAllocation;
  final double bufferExpense;
  final double bufferBalance;

  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final Timestamp settledAt;

  Settlement({
    required this.id,
    required this.year,
    required this.month,
    required this.necessitiesAllocation,
    required this.necessitiesExpense,
    required this.lifestyleAllocation,
    required this.lifestyleExpense,
    required this.investmentAllocation,
    required this.investmentExpense,
    required this.emergencyAllocation,
    required this.emergencyExpense,
    required this.bufferAllocation,
    required this.bufferExpense,
    required this.totalIncome,
    required this.totalExpense,
    required this.settledAt,
  }) : necessitiesBalance = necessitiesAllocation - necessitiesExpense,
       lifestyleBalance = lifestyleAllocation - lifestyleExpense,
       investmentBalance = investmentAllocation - investmentExpense,
       emergencyBalance = emergencyAllocation - emergencyExpense,
       bufferBalance = bufferAllocation - bufferExpense,
       totalBalance = totalIncome - totalExpense;

  factory Settlement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Settlement(
      id: doc.id,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      necessitiesAllocation: (data['necessitiesAllocation'] ?? 0.0).toDouble(),
      necessitiesExpense: (data['necessitiesExpense'] ?? 0.0).toDouble(),
      lifestyleAllocation: (data['lifestyleAllocation'] ?? 0.0).toDouble(),
      lifestyleExpense: (data['lifestyleExpense'] ?? 0.0).toDouble(),
      investmentAllocation: (data['investmentAllocation'] ?? 0.0).toDouble(),
      investmentExpense: (data['investmentExpense'] ?? 0.0).toDouble(),
      emergencyAllocation: (data['emergencyAllocation'] ?? 0.0).toDouble(),
      emergencyExpense: (data['emergencyExpense'] ?? 0.0).toDouble(),
      bufferAllocation: (data['bufferAllocation'] ?? 0.0).toDouble(),
      bufferExpense: (data['bufferExpense'] ?? 0.0).toDouble(),
      totalIncome: (data['totalIncome'] ?? 0.0).toDouble(),
      totalExpense: (data['totalExpense'] ?? 0.0).toDouble(),
      settledAt: data['settledAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'necessitiesAllocation': necessitiesAllocation,
      'necessitiesExpense': necessitiesExpense,
      'necessitiesBalance': necessitiesBalance,
      'lifestyleAllocation': lifestyleAllocation,
      'lifestyleExpense': lifestyleExpense,
      'lifestyleBalance': lifestyleBalance,
      'investmentAllocation': investmentAllocation,
      'investmentExpense': investmentExpense,
      'investmentBalance': investmentBalance,
      'emergencyAllocation': emergencyAllocation,
      'emergencyExpense': emergencyExpense,
      'emergencyBalance': emergencyBalance,
      'bufferAllocation': bufferAllocation,
      'bufferExpense': bufferExpense,
      'bufferBalance': bufferBalance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalBalance': totalBalance,
      'settledAt': settledAt,
    };
  }
}
