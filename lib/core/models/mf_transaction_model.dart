import 'package:cloud_firestore/cloud_firestore.dart';

class MfTransaction {
  final String id;
  final String fundName;
  final double amount;
  final double amountAfterCharges;
  final double charges;
  final double nav;
  final double unitsAllocated;
  final Timestamp date;

  MfTransaction({
    required this.id,
    required this.fundName,
    required this.amount,
    required this.amountAfterCharges,
    required this.nav,
    required this.unitsAllocated,
    required this.date,
  }) : charges = amount - amountAfterCharges;

  factory MfTransaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MfTransaction(
      id: doc.id,
      fundName: data['fundName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      amountAfterCharges: (data['amountAfterCharges'] ?? 0.0).toDouble(),
      nav: (data['nav'] ?? 0.0).toDouble(),
      unitsAllocated: (data['unitsAllocated'] ?? 0.0).toDouble(),
      date: data['date'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fundName': fundName,
      'amount': amount,
      'amountAfterCharges': amountAfterCharges,
      'charges': charges,
      'nav': nav,
      'unitsAllocated': unitsAllocated,
      'date': date,
    };
  }
}
