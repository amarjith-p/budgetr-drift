class CreditCardModel {
  final String id;
  final String name;
  final String bankName;
  final String lastFourDigits;
  final double creditLimit;
  final double currentBalance;
  final int billDate;
  final int dueDate;
  final int color;
  final bool isArchived;
  final DateTime createdAt;

  CreditCardModel({
    required this.id,
    required this.name,
    required this.bankName,
    this.lastFourDigits = '',
    required this.creditLimit,
    this.currentBalance = 0.0,
    required this.billDate,
    required this.dueDate,
    this.color = 0xFF1E1E1E,
    this.isArchived = false,
    required this.createdAt,
  });

  // factory CreditCardModel.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return CreditCardModel(
  //     id: doc.id,
  //     name: data['name'] ?? '',
  //     bankName: data['bankName'] ?? '',
  //     lastFourDigits: data['lastFourDigits'] ?? '',
  //     creditLimit: (data['creditLimit'] ?? 0.0).toDouble(),
  //     billDate: data['billDate'] ?? 1,
  //     dueDate: data['dueDate'] ?? 10,
  //     currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
  //     color: data['color'] ?? 0xFF1E1E1E,
  //     isArchived: data['isArchived'] ?? false,
  //     createdAt: data['createdAt'] ?? Timestamp.now(),
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bankName': bankName,
      'lastFourDigits': lastFourDigits,
      'creditLimit': creditLimit,
      'billDate': billDate,
      'dueDate': dueDate,
      'currentBalance': currentBalance,
      'color': color,
      'isArchived': isArchived,
      'createdAt': createdAt,
    };
  }
}

class CreditTransactionModel {
  final String id;
  final String cardId;
  final double amount;
  final DateTime date;
  final String bucket;
  final String type;
  final String category;
  final String subCategory;
  final String notes;
  final String? linkedExpenseId;

  // FEATURE: Settlement Management
  final bool includeInNextStatement; // Moves txn to next month
  final bool isSettlementVerified; // True if user confirmed/checked it

  CreditTransactionModel({
    required this.id,
    required this.cardId,
    required this.amount,
    required this.date,
    required this.bucket,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.notes,
    this.linkedExpenseId,
    this.includeInNextStatement = false,
    this.isSettlementVerified = false,
  });

  // factory CreditTransactionModel.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return CreditTransactionModel(
  //     id: doc.id,
  //     cardId: data['cardId'] ?? '',
  //     amount: (data['amount'] ?? 0.0).toDouble(),
  //     date: data['date'] ?? Timestamp.now(),
  //     bucket: data['bucket'] ?? 'Unallocated',
  //     type: data['type'] ?? 'Expense',
  //     category: data['category'] ?? 'General',
  //     subCategory: data['subCategory'] ?? 'General',
  //     notes: data['notes'] ?? '',
  //     linkedExpenseId: data['linkedExpenseId'],
  //     includeInNextStatement: data['includeInNextStatement'] ?? false,
  //     isSettlementVerified: data['isSettlementVerified'] ?? false,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'amount': amount,
      'date': date,
      'bucket': bucket,
      'type': type,
      'category': category,
      'subCategory': subCategory,
      'notes': notes,
      'linkedExpenseId': linkedExpenseId,
      'includeInNextStatement': includeInNextStatement,
      'isSettlementVerified': isSettlementVerified,
    };
  }
}
