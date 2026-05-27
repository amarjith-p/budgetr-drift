class BalanceSheetModel {
  final String id;
  final String title;
  final double amount;
  final String entryType; // 'ASSET' or 'LIABILITY'
  final String category;
  final DateTime date;
  final String? notes;

  // --- TRACKING FIELDS ---
  final String? contactName;
  final DateTime? dueDate;
  final bool isSettled;
  final double settledAmount; 
  final bool isForgiven; // [NEW]

  BalanceSheetModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.entryType,
    required this.category,
    required this.date,
    this.notes,
    this.contactName,
    this.dueDate,
    this.isSettled = false,
    this.settledAmount = 0.0,
    this.isForgiven = false, // [NEW] Default to false
  });
}