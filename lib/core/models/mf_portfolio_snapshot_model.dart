import 'package:cloud_firestore/cloud_firestore.dart';

class MfPortfolioSnapshot {
  final String id;
  final double investedValue;
  final double currentValue;
  final Timestamp date;

  MfPortfolioSnapshot({
    required this.id,
    required this.investedValue,
    required this.currentValue,
    required this.date,
  });

  factory MfPortfolioSnapshot.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MfPortfolioSnapshot(
      id: doc.id,
      investedValue: (data['investedValue'] ?? 0.0).toDouble(),
      currentValue: (data['currentValue'] ?? 0.0).toDouble(),
      date: data['date'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'investedValue': investedValue,
      'currentValue': currentValue,
      'date': date,
    };
  }
}
