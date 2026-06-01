import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';

// --- Imports for Auto-Calculated Net Worth ---
import '../../daily_expense/services/expense_service.dart';
import '../../investments/services/portfolio_service.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../goals_loans/services/goal_loan_service.dart';

class NetWorthService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Auto-Calculated Net Worth Stream ---
  // --- Auto-Calculated Net Worth Stream ---
// --- Auto-Calculated Net Worth Stream ---
  Stream<double> getAutoCalculatedNetWorth() {
    final expenseService = GetIt.I<ExpenseService>();
    final portfolioService = GetIt.I<PortfolioService>();
    final creditService = GetIt.I<CreditService>();
    final goalLoanService = GetIt.I<GoalLoanService>();

    return Rx.combineLatest4(
      expenseService.getAccounts(),
      portfolioService.watchAllInvestments(),
      creditService.getSmartCreditCardsDashboard(),
      goalLoanService.getActiveLoans(),
      (
        accounts,
        investments,
        creditCardDataList,
        loans,
      ) {
        // 1. Total Account Balance (Assets)
        double totalAccountBalance = 0;
        for (var acc in accounts) {
          totalAccountBalance += acc.currentBalance;
        }

        // 2. Total Portfolio Value (Assets)
        double totalPortfolioValue = 0;
        for (var inv in investments) {
          // UPDATED: Check both status AND the new excludeFromNetWorth flag
          if (inv.status != 'closed' && inv.excludeFromNetWorth != true) {
            totalPortfolioValue += inv.currentMarketValue;
          }
        }

        // 3. Total Payable Credit (Liabilities)
        double totalPayable = 0;
        for (var cardData in creditCardDataList) {
          // FIX: Use the pure database 'currentBalance' instead of the UI-clamped dashboard values.
          totalPayable += cardData.card.currentBalance;
        }

        // 4. Total Outstanding Loans (Liabilities) & Lent Money (Assets)
        double totalLoanOutstanding = 0; // Liabilities
        double totalLentAssets = 0; // Assets

        for (var loan in loans) {
          if (!loan.isClosed) {
            if (loan.type == 'BORROWED') {
              // Money you owe
              totalLoanOutstanding += loan.remaining;
            } else if (loan.type == 'LENT') {
              // Money owed TO you (Asset)
              // FIX: This must be added to your net worth, not subtracted!
              totalLentAssets += loan.remaining;
            }
          }
        }

        // NEW FORMULA: (Bank Balances + Investments + Lent Money) - (Credit Card Bills + Borrowed Loans)
        double totalAssets =
            totalAccountBalance + totalPortfolioValue + totalLentAssets;
        double totalLiabilities = totalPayable + totalLoanOutstanding;

        return totalAssets - totalLiabilities;
      },
    );
  }

  // --- Total Net Worth ---

  Stream<List<NetWorthRecord>> getNetWorthRecords() {
    return (_db.select(_db.netWorthRecords)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows
            .map((r) => NetWorthRecord(
                  id: r.id,
                  date: r.date,
                  amount: r.amount,
                ))
            .toList());
  }

  Future<void> addNetWorthRecord(NetWorthRecord record) async {
    final id = record.id.isNotEmpty ? record.id : _uuid.v4();
    await _db
        .into(_db.netWorthRecords)
        .insert(db.NetWorthRecordsCompanion.insert(
          id: id,
          date: record.date,
          amount: record.amount,
        ));
  }

  Future<void> deleteNetWorthRecord(String id) async {
    await (_db.delete(_db.netWorthRecords)..where((t) => t.id.equals(id))).go();
  }

  // Map DB Row to Domain Model
  NetWorthSplitModel _mapSplit(db.NetWorthSplit row) {
    return NetWorthSplitModel(
      id: row.id,
      date: row.date,
      // Assets
      bankAccounts: row.bankAccounts,
      cashInHand: row.cashInHand,
      mutualFunds: row.mutualFunds,
      equity: row.equity,
      bonds: row.bonds,
      deposits: row.deposits,
      realEstate: row.realEstate,
      otherAssets: row.otherAssets,
      assetNotes: row.assetNotes,
      // Liabilities
      loans: row.loans,
      creditCardOutstanding: row.creditCardOutstanding,
      creditLineOutstanding: row.creditLineOutstanding,
      otherDebts: row.otherDebts,
      liabilityNotes: row.liabilityNotes,
      // Cashflow
      totalIncome: row.totalIncome,
      totalExpense: row.totalExpense,
      budgetedIncome: row.budgetedIncome,
      budgetedExpense: row.budgetedExpense,
      nonCalcIncome: row.nonCalcIncome,
      nonCalcExpense: row.nonCalcExpense,
      outOfBucketExpense: row.outOfBucketExpense,
    );
  }

  Stream<List<NetWorthSplitModel>> getSplits() {
    return (_db.select(_db.netWorthSplits)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapSplit).toList());
  }

  Future<void> createSplit(NetWorthSplitModel split) async {
    await _db.into(_db.netWorthSplits).insert(db.NetWorthSplitsCompanion.insert(
          id: _uuid.v4(),
          date: split.date,
          bankAccounts: Value(split.bankAccounts),
          cashInHand: Value(split.cashInHand),
          mutualFunds: Value(split.mutualFunds),
          equity: Value(split.equity),
          bonds: Value(split.bonds),
          deposits: Value(split.deposits),
          realEstate: Value(split.realEstate),
          otherAssets: Value(split.otherAssets),
          assetNotes: Value(split.assetNotes),
          loans: Value(split.loans),
          creditCardOutstanding: Value(split.creditCardOutstanding),
          creditLineOutstanding: Value(split.creditLineOutstanding),
          otherDebts: Value(split.otherDebts),
          liabilityNotes: Value(split.liabilityNotes),
          totalIncome: Value(split.totalIncome),
          totalExpense: Value(split.totalExpense),
          budgetedIncome: Value(split.budgetedIncome),
          budgetedExpense: Value(split.budgetedExpense),
          nonCalcIncome: Value(split.nonCalcIncome),
          nonCalcExpense: Value(split.nonCalcExpense),
          outOfBucketExpense: Value(split.outOfBucketExpense),
        ));
  }

  Future<void> updateSplit(NetWorthSplitModel split) async {
    await (_db.update(_db.netWorthSplits)..where((t) => t.id.equals(split.id)))
        .write(db.NetWorthSplitsCompanion(
      date: Value(split.date),
      bankAccounts: Value(split.bankAccounts),
      cashInHand: Value(split.cashInHand),
      mutualFunds: Value(split.mutualFunds),
      equity: Value(split.equity),
      bonds: Value(split.bonds),
      deposits: Value(split.deposits),
      realEstate: Value(split.realEstate),
      otherAssets: Value(split.otherAssets),
      assetNotes: Value(split.assetNotes),
      loans: Value(split.loans),
      creditCardOutstanding: Value(split.creditCardOutstanding),
      creditLineOutstanding: Value(split.creditLineOutstanding),
      otherDebts: Value(split.otherDebts),
      liabilityNotes: Value(split.liabilityNotes),
      totalIncome: Value(split.totalIncome),
      totalExpense: Value(split.totalExpense),
      budgetedIncome: Value(split.budgetedIncome),
      budgetedExpense: Value(split.budgetedExpense),
      nonCalcIncome: Value(split.nonCalcIncome),
      nonCalcExpense: Value(split.nonCalcExpense),
      outOfBucketExpense: Value(split.outOfBucketExpense),
    ));
  }

  Future<void> deleteSplit(String id) async {
    await (_db.delete(_db.netWorthSplits)..where((t) => t.id.equals(id))).go();
  }
}
