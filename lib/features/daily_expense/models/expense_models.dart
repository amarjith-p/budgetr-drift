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

  // factory ExpenseAccountModel.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return ExpenseAccountModel(
  //     id: doc.id,
  //     name: data['name'] ?? '',
  //     bankName: data['bankName'] ?? '',
  //     type: data['type'] ?? 'Bank',
  //     currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
  //     createdAt: data['createdAt'] ?? DateTime.now(),
  //     accountType: data['accountType'] ?? 'Savings Account',
  //     accountNumber: data['accountNumber'] ?? '',
  //     color: data['color'] ?? 0xFF1E1E1E,
  //     showOnDashboard: data['showOnDashboard'] ?? true,
  //     dashboardOrder: data['dashboardOrder'] ?? 0,
  //   );
  // }

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
  });

  // factory ExpenseTransactionModel.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return ExpenseTransactionModel(
  //     id: doc.id,
  //     accountId: data['accountId'] ?? '',
  //     amount: (data['amount'] ?? 0.0).toDouble(),
  //     date: data['date'] ?? DateTime.now(),
  //     bucket: data['bucket'] ?? 'Unallocated',
  //     type: data['type'] ?? 'Expense',
  //     category: data['category'] ?? 'General',
  //     subCategory: data['subCategory'] ?? 'General',
  //     notes: data['notes'] ?? '',
  //     transferAccountId: data['transferAccountId'],
  //     transferAccountName: data['transferAccountName'],
  //     transferAccountBankName: data['transferAccountBankName'],
  //     linkedCreditCardId: data['linkedCreditCardId'],
  //   );
  // }

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
