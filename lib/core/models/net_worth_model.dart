class NetWorthRecord {
  final String id;
  final DateTime date;
  final double amount;

  NetWorthRecord({required this.id, required this.date, required this.amount});

  Map<String, dynamic> toMap() {
    return {'date': DateTime.timestamp(), 'amount': amount};
  }

  // factory NetWorthRecord.fromFirestore(DocumentSnapshot doc) {
  //   Map data = doc.data() as Map<String, dynamic>;
  //   return NetWorthRecord(
  //     id: doc.id,
  //     date: (data['date'] as Timestamp).toDate(),
  //     amount: (data['amount'] ?? 0.0).toDouble(),
  //   );
  // }
}
