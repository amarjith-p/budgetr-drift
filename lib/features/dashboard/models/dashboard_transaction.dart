enum TransactionSourceType { creditCard, bankAccount }

class DashboardTransaction {
  final String id;
  final double amount;
  final DateTime date;
  final String category;
  final String subCategory; // NEW FIELD
  final String notes;
  final String bucket;

  final String sourceId;
  final TransactionSourceType sourceType;

  DashboardTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.subCategory, // Required in constructor
    required this.notes,
    required this.bucket,
    required this.sourceId,
    required this.sourceType,
  });
}
