import 'package:budget/core/database/app_database.dart';
import 'package:budget/features/investments/database/passive_income_tables.dart';
import 'package:drift/drift.dart';

class PassiveIncomeService {
  final AppDatabase _db = AppDatabase.instance;

  // --- WRITE OPERATIONS ---

  Future<void> logIncome({
    required int investmentId,
    required double amount,
    required DateTime date,
    required String type, // 'dividend' or 'interest'
    String? notes,
  }) async {
    await _db
        .into(_db.passiveIncomeLogs)
        .insert(PassiveIncomeLogsCompanion.insert(
          investmentId: investmentId,
          amount: amount,
          date: date,
          type: Value(type),
          notes: Value(notes),
        ));
  }

  Future<void> deleteLog(int id) async {
    await (_db.delete(_db.passiveIncomeLogs)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> updateLog(
      int id, double amount, DateTime date, String? notes) async {
    await (_db.update(_db.passiveIncomeLogs)..where((t) => t.id.equals(id)))
        .write(
      PassiveIncomeLogsCompanion(
        amount: Value(amount),
        date: Value(date),
        notes: Value(notes),
      ),
    );
  }

  // --- READ OPERATIONS ---

  /// Watch all income logs for a specific investment
  Stream<List<PassiveIncomeLog>> watchLogs(int investmentId) {
    return (_db.select(_db.passiveIncomeLogs)
          ..where((t) => t.investmentId.equals(investmentId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Calculates Total Income & Yield
  /// We pass 'totalInvested' from the main module to calc Yield %
  Stream<PassiveIncomeMetrics> watchMetrics(
      int investmentId, double totalInvested) {
    return watchLogs(investmentId).map((logs) {
      double total = logs.fold(0, (sum, item) => sum + item.amount);
      double yieldPct =
          (totalInvested > 0) ? (total / totalInvested) * 100 : 0.0;

      return PassiveIncomeMetrics(
        totalEarned: total,
        yieldPercentage: yieldPct,
        transactionCount: logs.length,
      );
    });
  }
}

class PassiveIncomeMetrics {
  final double totalEarned;
  final double yieldPercentage;
  final int transactionCount;

  PassiveIncomeMetrics({
    required this.totalEarned,
    required this.yieldPercentage,
    required this.transactionCount,
  });
}
