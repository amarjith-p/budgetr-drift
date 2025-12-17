import 'package:cloud_firestore/cloud_firestore.dart';

class NetWorthSplit {
  final String id;
  final DateTime date;

  final double netIncome;
  final double netExpense;
  final double capitalGain;
  final double capitalLoss;
  final double nonCalcIncome;
  final double nonCalcExpense;

  NetWorthSplit({
    required this.id,
    required this.date,
    required this.netIncome,
    required this.netExpense,
    required this.capitalGain,
    required this.capitalLoss,
    required this.nonCalcIncome,
    required this.nonCalcExpense,
  });

  // Calculations
  double get effectiveIncome => netIncome - capitalGain - nonCalcIncome;
  double get effectiveExpense => netExpense - capitalLoss - nonCalcExpense;
  double get effectiveSavings => effectiveIncome - effectiveExpense;

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'netIncome': netIncome,
      'netExpense': netExpense,
      'capitalGain': capitalGain,
      'capitalLoss': capitalLoss,
      'nonCalcIncome': nonCalcIncome,
      'nonCalcExpense': nonCalcExpense,
    };
  }

  factory NetWorthSplit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NetWorthSplit(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      netIncome: (data['netIncome'] ?? 0.0).toDouble(),
      netExpense: (data['netExpense'] ?? 0.0).toDouble(),
      capitalGain: (data['capitalGain'] ?? 0.0).toDouble(),
      capitalLoss: (data['capitalLoss'] ?? 0.0).toDouble(),
      nonCalcIncome: (data['nonCalcIncome'] ?? 0.0).toDouble(),
      nonCalcExpense: (data['nonCalcExpense'] ?? 0.0).toDouble(),
    );
  }
}
