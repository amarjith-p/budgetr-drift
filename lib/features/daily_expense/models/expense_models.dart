class ExpenseAccountModel {
  final String id;
  final String name;
  final String bankName;
  final String type;
  final double currentBalance;
  final DateTime createdAt;

  final String accountType;
  final String accountNumber;
  final int color;

  final bool showOnDashboard;
  final int dashboardOrder;

  ExpenseAccountModel({
    required this.id,
    required this.name,
    required this.bankName,
    required this.type,
    this.currentBalance = 0.0,
    required this.createdAt,
    this.accountType = 'Savings Account',
    this.accountNumber = '',
    this.color = 0xFF1E1E1E,
    this.showOnDashboard = true,
    this.dashboardOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bankName': bankName,
      'type': type,
      'currentBalance': currentBalance,
      'createdAt': createdAt,
      'accountType': accountType,
      'accountNumber': accountNumber,
      'color': color,
      'showOnDashboard': showOnDashboard,
      'dashboardOrder': dashboardOrder,
    };
  }

  ExpenseAccountModel copyWith({
    bool? showOnDashboard,
    int? dashboardOrder,
    double? currentBalance,
  }) {
    return ExpenseAccountModel(
      id: id,
      name: name,
      bankName: bankName,
      type: type,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt,
      accountType: accountType,
      accountNumber: accountNumber,
      color: color,
      showOnDashboard: showOnDashboard ?? this.showOnDashboard,
      dashboardOrder: dashboardOrder ?? this.dashboardOrder,
    );
  }
}

class ExpenseTransactionModel {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String bucket;
  final String type;
  final String category;
  final String subCategory;
  final String notes;

  // Transfer fields
  final String? transferAccountId;
  final String? transferAccountName;
  final String? transferAccountBankName;

  // --- NEW FIELD FOR SYNC ---
  final String? linkedCreditCardId;

  // --- [NEW ADDITION START] TRANSIENT STATE FOR RUNNING BALANCE ---
  final double? runningBalance;
  // --- [NEW ADDITION END] ---

  ExpenseTransactionModel({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.bucket,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.notes,
    this.transferAccountId,
    this.transferAccountName,
    this.transferAccountBankName,
    this.linkedCreditCardId,
    this.runningBalance, // [NEW ADDITION]
  });

  // --- [NEW ADDITION START] copyWith method to safely inject runningBalance in memory ---
  ExpenseTransactionModel copyWith({
    String? id,
    String? accountId,
    double? amount,
    DateTime? date,
    String? bucket,
    String? type,
    String? category,
    String? subCategory,
    String? notes,
    String? transferAccountId,
    String? transferAccountName,
    String? transferAccountBankName,
    String? linkedCreditCardId,
    double? runningBalance,
  }) {
    return ExpenseTransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      bucket: bucket ?? this.bucket,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      notes: notes ?? this.notes,
      transferAccountId: transferAccountId ?? this.transferAccountId,
      transferAccountName: transferAccountName ?? this.transferAccountName,
      transferAccountBankName:
          transferAccountBankName ?? this.transferAccountBankName,
      linkedCreditCardId: linkedCreditCardId ?? this.linkedCreditCardId,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }
  // --- [NEW ADDITION END] ---

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'amount': amount,
      'date': date,
      'bucket': bucket,
      'type': type,
      'category': category,
      'subCategory': subCategory,
      'notes': notes,
      'transferAccountId': transferAccountId,
      'transferAccountName': transferAccountName,
      'transferAccountBankName': transferAccountBankName,
      'linkedCreditCardId': linkedCreditCardId,
    };
  }
}
