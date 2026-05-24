// lib/features/credit_tracker/models/credit_models.dart

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

// ==========================================
// --- [NEW] SMART CYCLE INDICATOR MODELS ---
// ==========================================

enum SmartCyclePhase {
  noActivity, // Balance is 0
  paymentDue, // In grace period, Statement Balance > 0
  statementPaid, // In grace period, Statement Balance paid off
  unbilledSpending, // Normal spending phase
  overdue // [NEW] Missed due date, Statement Balance still > 0
}

class SmartCycleInfo {
  final SmartCyclePhase phase;
  final DateTime? startDate;
  final DateTime? endDate;
  final int daysRemaining;
  final double progress;

  SmartCycleInfo({
    required this.phase,
    this.startDate,
    this.endDate,
    required this.daysRemaining,
    required this.progress,
  });
}

class CreditCardDashboardData {
  final CreditCardModel card;
  final double statementBalance;
  final double unbilledBalance;

  CreditCardDashboardData({
    required this.card,
    required this.statementBalance,
    required this.unbilledBalance,
  });
}
