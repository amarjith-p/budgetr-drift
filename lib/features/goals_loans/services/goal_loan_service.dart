import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/goal_loan_models.dart';
import '../../../core/database/tables.dart';

// [NEW IMPORT]
import 'goals_loans_notification_scheduler.dart';

class GoalLoanService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // [NEW] Instance of the scheduler
  final _scheduler = GoalsLoansNotificationScheduler();

  // --- MAPPERS ---
  GoalModel _mapGoal(db.Goal row) {
    return GoalModel(
      id: row.id,
      name: row.name,
      purpose: row.purpose,
      investmentType: row.investmentType,
      identificationNumber: row.identificationNumber,
      currentAmount: row.currentAmount,
      targetAmount: row.targetAmount,
      startDate: row.startDate,
      deadline: row.deadline,
      expectedReturn: row.expectedReturn,
      color: row.color,
      icon: row.icon,
      isCompleted: row.isCompleted,
    );
  }

  LoanModel _mapLoan(db.Loan row) {
    return LoanModel(
      id: row.id,
      title: row.title,
      provider: row.provider,
      principalAmount: row.principalAmount,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      interestRate: row.interestRate,
      type: row.type,
      startDate: row.startDate,
      dueDate: row.dueDate,
      emiAmount: row.emiAmount,
      nextPaymentDate: row.nextPaymentDate,
      notes: row.notes,
      isClosed: row.isClosed,
    );
  }

  AssetLogModel _mapLog(db.AssetLog row) {
    return AssetLogModel(
      id: row.id,
      parentId: row.parentId,
      type: row.type,
      amount: row.amount,
      interestComponent: row.interestComponent,
      date: row.date,
      notes: row.notes ?? '',
    );
  }

  // --- GOALS ---
  Stream<List<GoalModel>> getActiveGoals() {
    return getGoals(showHistory: false);
  }

  Stream<List<GoalModel>> getGoals({required bool showHistory}) {
    return (_db.select(_db.goals)
          ..where((t) => t.isCompleted.equals(showHistory))
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapGoal).toList());
  }

  Stream<GoalModel> watchGoal(String id) {
    return (_db.select(_db.goals)..where((t) => t.id.equals(id)))
        .watchSingle()
        .map(_mapGoal);
  }

  Future<void> createGoal(GoalModel goal) async {
    await _db.transaction(() async {
      final goalId = _uuid.v4();

      await _db.into(_db.goals).insert(db.GoalsCompanion.insert(
            id: goalId,
            name: goal.name,
            purpose: Value(goal.purpose),
            investmentType: Value(goal.investmentType),
            identificationNumber: Value(goal.identificationNumber),
            currentAmount: Value(goal.currentAmount),
            targetAmount: goal.targetAmount,
            startDate: Value(goal.startDate),
            deadline: Value(goal.deadline),
            expectedReturn: Value(goal.expectedReturn),
            color: goal.color,
            icon: Value(goal.icon),
            isCompleted: const Value(false),
            createdAt: DateTime.now(),
          ));

      if (goal.currentAmount > 0) {
        await _db.into(_db.assetLogs).insert(db.AssetLogsCompanion.insert(
              id: _uuid.v4(),
              parentId: goalId,
              type: 'Goal_Contribution',
              amount: goal.currentAmount,
              interestComponent: const Value(0.0),
              date: DateTime.now(),
              notes: const Value("Opening Balance"),
            ));
      }
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> updateGoal(GoalModel goal) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(goal.id)))
        .write(db.GoalsCompanion(
      name: Value(goal.name),
      targetAmount: Value(goal.targetAmount),
      startDate: Value(goal.startDate),
      deadline: Value(goal.deadline),
      color: Value(goal.color),
      icon: Value(goal.icon),
      purpose: Value(goal.purpose),
      investmentType: Value(goal.investmentType),
      identificationNumber: Value(goal.identificationNumber),
      expectedReturn: Value(goal.expectedReturn),
    ));
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> deleteGoal(String goalId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.assetLogs)..where((t) => t.parentId.equals(goalId)))
          .go();
      await (_db.delete(_db.goals)..where((t) => t.id.equals(goalId))).go();
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> addGoalContribution(
      String goalId, double principal, String notes, DateTime date) async {
    await _db.transaction(() async {
      await _db.into(_db.assetLogs).insert(db.AssetLogsCompanion.insert(
            id: _uuid.v4(),
            parentId: goalId,
            type: 'Goal_Contribution',
            amount: principal,
            interestComponent: const Value(0.0),
            date: date,
            notes: Value(notes),
          ));

      final goal = await (_db.select(_db.goals)
            ..where((t) => t.id.equals(goalId)))
          .getSingle();
      final newBalance = goal.currentAmount + principal;
      final isComplete = newBalance >= goal.targetAmount;

      await (_db.update(_db.goals)..where((t) => t.id.equals(goalId)))
          .write(db.GoalsCompanion(
        currentAmount: Value(newBalance),
        isCompleted: Value(isComplete),
      ));
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> adjustGoalValue(
      String goalId, double newTotalValue, String notes, DateTime date) async {
    await _db.transaction(() async {
      final goal = await (_db.select(_db.goals)
            ..where((t) => t.id.equals(goalId)))
          .getSingle();
      final difference = newTotalValue - goal.currentAmount;
      if (difference == 0) return;

      await _db.into(_db.assetLogs).insert(db.AssetLogsCompanion.insert(
            id: _uuid.v4(),
            parentId: goalId,
            type: 'Goal_Revaluation',
            amount: difference,
            interestComponent: Value(difference),
            date: date,
            notes: Value(notes),
          ));

      final isComplete = newTotalValue >= goal.targetAmount;

      await (_db.update(_db.goals)..where((t) => t.id.equals(goalId)))
          .write(db.GoalsCompanion(
        currentAmount: Value(newTotalValue),
        isCompleted: Value(isComplete),
      ));
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> deleteGoalLog(String logId) async {
    await _db.transaction(() async {
      final log = await (_db.select(_db.assetLogs)
            ..where((t) => t.id.equals(logId)))
          .getSingle();
      final goal = await (_db.select(_db.goals)
            ..where((t) => t.id.equals(log.parentId)))
          .getSingle();

      final newBalance = goal.currentAmount - log.amount;
      final isComplete = newBalance >= goal.targetAmount;

      await (_db.delete(_db.assetLogs)..where((t) => t.id.equals(logId))).go();
      await (_db.update(_db.goals)..where((t) => t.id.equals(goal.id)))
          .write(db.GoalsCompanion(
        currentAmount: Value(newBalance),
        isCompleted: Value(isComplete),
      ));
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  // --- LOANS ---
  Stream<List<LoanModel>> getActiveLoans() {
    return getLoans(showHistory: false);
  }

  Stream<List<LoanModel>> getLoans({required bool showHistory}) {
    return (_db.select(_db.loans)
          ..where((t) => t.isClosed.equals(showHistory))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapLoan).toList());
  }

  Stream<LoanModel> watchLoan(String id) {
    return (_db.select(_db.loans)..where((t) => t.id.equals(id)))
        .watchSingle()
        .map(_mapLoan);
  }

  Future<void> createLoan(LoanModel loan) async {
    await _db.into(_db.loans).insert(db.LoansCompanion.insert(
          id: _uuid.v4(),
          title: loan.title,
          provider: loan.provider,
          principalAmount: Value(loan.principalAmount),
          totalAmount: loan.totalAmount,
          paidAmount: const Value(0.0),
          type: loan.type,
          interestRate: Value(loan.interestRate),
          startDate: loan.startDate,
          dueDate: Value(loan.dueDate),
          emiAmount: Value(loan.emiAmount),
          nextPaymentDate: Value(loan.nextPaymentDate),
          notes: Value(loan.notes),
        ));
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> updateLoan(LoanModel loan) async {
    await (_db.update(_db.loans)..where((t) => t.id.equals(loan.id)))
        .write(db.LoansCompanion(
      title: Value(loan.title),
      provider: Value(loan.provider),
      principalAmount: Value(loan.principalAmount),
      totalAmount: Value(loan.totalAmount),
      interestRate: Value(loan.interestRate),
      startDate: Value(loan.startDate),
      emiAmount: Value(loan.emiAmount),
      nextPaymentDate: Value(loan.nextPaymentDate),
      dueDate: Value(loan.dueDate),
      notes: Value(loan.notes),
    ));
    _triggerNotificationSync(); // [NEW HOOK]
  }

  Future<void> deleteLoan(String loanId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.assetLogs)..where((t) => t.parentId.equals(loanId)))
          .go();
      await (_db.delete(_db.loans)..where((t) => t.id.equals(loanId))).go();
    });
    _triggerNotificationSync(); // [NEW HOOK]
  }

  // --- REPLACE addLoanPayment AND deleteLoanLog WITH THESE ---

  Future<void> addLoanPayment(
      String loanId, double amount, String type, DateTime date) async {
    await _db.transaction(() async {
      await _db.into(_db.assetLogs).insert(db.AssetLogsCompanion.insert(
            id: _uuid.v4(),
            parentId: loanId,
            type: type == 'EMI' ? 'Loan_EMI' : 'Loan_Prepayment',
            amount: amount,
            interestComponent: const Value(0.0),
            date: date,
            notes: Value(type == 'EMI' ? 'Monthly EMI' : 'Extra Payment'),
          ));

      final loan = await (_db.select(_db.loans)
            ..where((t) => t.id.equals(loanId)))
          .getSingle();
      final newPaid = loan.paidAmount + amount;

      // [FIX] Blocked automatic closure. The loan stays open even if overpaid.
      await (_db.update(_db.loans)..where((t) => t.id.equals(loanId)))
          .write(db.LoansCompanion(
        paidAmount: Value(newPaid),
      ));
    });
    _triggerNotificationSync();
  }

  Future<void> deleteLoanLog(String logId) async {
    await _db.transaction(() async {
      final log = await (_db.select(_db.assetLogs)
            ..where((t) => t.id.equals(logId)))
          .getSingle();
      final loan = await (_db.select(_db.loans)
            ..where((t) => t.id.equals(log.parentId)))
          .getSingle();

      final newPaid = loan.paidAmount - log.amount;

      await (_db.delete(_db.assetLogs)..where((t) => t.id.equals(logId))).go();

      // [FIX] Blocked automatic closure logic here as well.
      await (_db.update(_db.loans)..where((t) => t.id.equals(loan.id)))
          .write(db.LoansCompanion(
        paidAmount: Value(newPaid),
      ));
    });
    _triggerNotificationSync(); 
  }

  // [NEW] Manual status toggle
  Future<void> toggleLoanClosure(String loanId, bool isClosed) async {
    await (_db.update(_db.loans)..where((t) => t.id.equals(loanId)))
        .write(db.LoansCompanion(isClosed: Value(isClosed)));
    _triggerNotificationSync();
  }

  Stream<List<AssetLogModel>> getLogsForParent(String parentId) {
    return (_db.select(_db.assetLogs)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapLog).toList());
  }

  // --- [NEW METHOD] Hand over data directly to Batched Scheduler ---
  Future<void> _triggerNotificationSync() async {
    final loans = await _db.select(_db.loans).get();
    final goals = await _db.select(_db.goals).get();
    await _scheduler.syncNotifications(loans, goals);
  }
}
