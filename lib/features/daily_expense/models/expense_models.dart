import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseAccountModel {
  final String id;
  final String name; // e.g., "HDFC Savings"
  final String bankName; // For Logo mapping
  final String type; // 'Bank' or 'Cash'
  final double currentBalance;
  final Timestamp createdAt;

  // --- NEW FIELDS ADDED ---
  final String accountType; // e.g., 'Savings Account', 'Salary Account'
  final String accountNumber; // e.g., '8842' (Last 4 digits)
  final int color; // Color value as int (e.g., 0xFF1E1E1E)

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
    };
  }
}

class ExpenseTransactionModel {
  final String id;
  final String accountId;
  final double amount;
  final Timestamp date;
  final String bucket;
  final String type; // 'Income', 'Expense', 'Transfer Out', 'Transfer In'
  final String category;
  final String subCategory;
  final String notes;

  // Fields for Transfer
  final String? transferAccountId;
  final String? transferAccountName;
  final String? transferAccountBankName; // NEW FIELD

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
    this.transferAccountBankName, // NEW
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
      transferAccountBankName: data['transferAccountBankName'], // NEW
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
      'transferAccountBankName': transferAccountBankName, // NEW
    };
  }
}
