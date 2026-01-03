import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseAccountModel {
  final String id;
  final String name;
  final String bankName;
  final String type;
  final double currentBalance;
  final Timestamp createdAt;

  final String accountType;
  final String accountNumber;
  final int color;

  // --- NEW DASHBOARD CONFIG FIELDS ---
  final bool showOnDashboard; // Toggle visibility
  final int dashboardOrder; // For Reordering

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
    this.showOnDashboard = true, // Default to visible
    this.dashboardOrder = 0, // Default order
  });

  factory ExpenseAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseAccountModel(
      id: doc.id,
      name: data['name'] ?? '',
      bankName: data['bankName'] ?? '',
      type: data['type'] ?? 'Bank',
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      accountType: data['accountType'] ?? 'Savings Account',
      accountNumber: data['accountNumber'] ?? '',
      color: data['color'] ?? 0xFF1E1E1E,
      // Map new fields
      showOnDashboard: data['showOnDashboard'] ?? true,
      dashboardOrder: data['dashboardOrder'] ?? 0,
    );
  }

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
      // Save new fields
      'showOnDashboard': showOnDashboard,
      'dashboardOrder': dashboardOrder,
    };
  }

  // Helper for updates
  ExpenseAccountModel copyWith({
    bool? showOnDashboard,
    int? dashboardOrder,
  }) {
    return ExpenseAccountModel(
      id: id,
      name: name,
      bankName: bankName,
      type: type,
      currentBalance: currentBalance,
      createdAt: createdAt,
      accountType: accountType,
      accountNumber: accountNumber,
      color: color,
      showOnDashboard: showOnDashboard ?? this.showOnDashboard,
      dashboardOrder: dashboardOrder ?? this.dashboardOrder,
    );
  }
}

// ... (ExpenseTransactionModel remains unchanged)
class ExpenseTransactionModel {
  final String id;
  final String accountId;
  final double amount;
  final Timestamp date;
  final String bucket;
  final String type;
  final String category;
  final String subCategory;
  final String notes;
  final String? transferAccountId;
  final String? transferAccountName;
  final String? transferAccountBankName;

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
  });

  factory ExpenseTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseTransactionModel(
      id: doc.id,
      accountId: data['accountId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: data['date'] ?? Timestamp.now(),
      bucket: data['bucket'] ?? 'Unallocated',
      type: data['type'] ?? 'Expense',
      category: data['category'] ?? 'General',
      subCategory: data['subCategory'] ?? 'General',
      notes: data['notes'] ?? '',
      transferAccountId: data['transferAccountId'],
      transferAccountName: data['transferAccountName'],
      transferAccountBankName: data['transferAccountBankName'],
    );
  }

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
    };
  }
}
