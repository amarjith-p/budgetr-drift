class GoalModel {
  final String id;
  final String name;
  final String? purpose;
  final String investmentType;
  final String? identificationNumber;

  final double currentAmount;
  final double targetAmount;

  final DateTime startDate;
  final DateTime? deadline;

  final double? expectedReturn;

  final int color;
  final String? icon;
  final bool isCompleted;

  GoalModel({
    required this.id,
    required this.name,
    this.purpose,
    required this.investmentType,
    this.identificationNumber,
    required this.currentAmount,
    required this.targetAmount,
    required this.startDate,
    this.deadline,
    this.expectedReturn,
    required this.color,
    this.icon,
    required this.isCompleted,
  });

  double get progress =>
      (targetAmount == 0) ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);
}

class LoanModel {
  final String id;
  final String title;
  final String provider;

  final double principalAmount; // [NEW] Original Loan Amount
  final double totalAmount; // Total Payable (Principal + Interest)
  final double paidAmount;

  final double interestRate;
  final String type; // 'BORROWED' or 'LENT'

  final DateTime startDate;
  final DateTime? dueDate; // End Date

  final double? emiAmount;
  final DateTime? nextPaymentDate;
  final String? notes; // Account No

  final bool isClosed;

  LoanModel({
    required this.id,
    required this.title,
    required this.provider,
    this.principalAmount = 0.0,
    required this.totalAmount,
    required this.paidAmount,
    this.interestRate = 0.0,
    required this.type,
    required this.startDate,
    this.dueDate,
    this.emiAmount,
    this.nextPaymentDate,
    this.notes,
    required this.isClosed,
  });

  double get remaining => totalAmount - paidAmount;
  double get progress =>
      (totalAmount == 0) ? 0 : (paidAmount / totalAmount).clamp(0.0, 1.0);
}

class AssetLogModel {
  final String id;
  final String parentId;
  final String type;
  final double amount;
  final double interestComponent;
  final DateTime date;
  final String notes;

  AssetLogModel({
    required this.id,
    required this.parentId,
    required this.type,
    required this.amount,
    this.interestComponent = 0.0,
    required this.date,
    required this.notes,
  });

  double get principalComponent => amount - interestComponent;
}
