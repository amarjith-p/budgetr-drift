import 'package:budget/core/database/app_database.dart';
import 'package:budget/features/investments/database/investment_tables.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/utils/xirr_calculator.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

class PortfolioService {
  final AppDatabase _db = AppDatabase.instance;

  // ===========================================================================
  //  CORE: CHAIN RECALCULATION ENGINE (THE FIX)
  // ===========================================================================

  /// This method is the "Brain". It fetches all transactions for an asset,
  /// sorts them by date, and replays the math sequentially to fix any broken chains.
  Future<void> _recalculateChain(int investmentId) async {
    // 1. Fetch all transactions for this investment, sorted by Date ASC
    final allTxns = await (_db.select(_db.investmentTransactions)
          ..where((t) => t.investmentId.equals(investmentId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.transactionDate, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();

    double runningCurrentValue = 0.0;
    double runningTotalInvested = 0.0;

    await _db.transaction(() async {
      for (var txn in allTxns) {
        final isValueUpdate = txn.transactionType == 'valueUpdate';

        // --- STEP 1: Determine Values for this Step ---
        if (isValueUpdate) {
          // For Value Updates, the User's input (stored in snapshot) IS the new running value.
          // We trust the snapshot value for this specific row type.
          runningCurrentValue = txn.currentValueSnapshot;
        } else {
          // For Investment/Withdrawal, the value shifts by the amount
          // amountInvested is positive for Invest, negative for Withdraw
          runningCurrentValue += txn.amountInvested;
          runningTotalInvested += txn.amountInvested;
        }

        // --- STEP 2: Calculate Derived Metrics ---
        // Gain = Current Value - (Money Put In - Money Taken Out)
        final double currentGain = runningCurrentValue - runningTotalInvested;

        // --- STEP 3: Update the Row with Corrected Math ---
        await (_db.update(_db.investmentTransactions)
              ..where((t) => t.id.equals(txn.id)))
            .write(InvestmentTransactionsCompanion(
          // Ensure snapshot is synced (crucial if we just calculated it for 'invested' type)
          currentValueSnapshot: Value(runningCurrentValue),
          calculatedGainLoss: Value(currentGain),
        ));
      }
    });
  }

  // ===========================================================================
  //  WRITE OPERATIONS (Wrapped with Recalculation)
  // ===========================================================================

  /// 1. Add a New Investment
  Future<void> addNewInvestment(InvestmentDto dto, double initialValue) async {
    await _db.transaction(() async {
      final id =
          await _db.into(_db.investments).insert(InvestmentsCompanion.insert(
                name: dto.name,
                type: InvestmentDto.typeToString(dto.type),
                subType: Value(dto.subType),
                providerName: dto.providerName,
                providerWebsite: Value(dto.providerWebsite),
                startDate: dto.startDate,
                endDate: Value(dto.endDate),
                expectedReturn: Value(dto.expectedReturn),
                folioNumber: Value(dto.folioNumber),
                units: Value(dto.units),
                brokerName: Value(dto.brokerName),
                linkedBankName: Value(dto.linkedBankName),
                linkedBankAccount: Value(dto.linkedBankAccount),
                purpose: Value(dto.purpose),
                notes: Value(dto.notes),
                specialId: Value(dto.specialId),
              ));

      // Add the initial transaction
      await _db
          .into(_db.investmentTransactions)
          .insert(InvestmentTransactionsCompanion.insert(
            investmentId: id,
            transactionDate: dto.startDate,
            transactionType: 'invested',
            amountInvested: Value(initialValue),
            currentValueSnapshot: initialValue,
            calculatedGainLoss: const Value(0.0),
          ));

      // Ensure chain is perfect from start
      await _recalculateChain(id);
    });
  }

  /// 2. Log SIP / Lumpsum OR Withdrawal
  Future<void> logInvestmentTransaction(
      int investmentId, double amount, DateTime date,
      {bool isWithdrawal = false}) async {
    final effectiveAmount = isWithdrawal ? -amount : amount;
    final String type = isWithdrawal ? 'withdrawn' : 'invested';

    // Insert with placeholders; _recalculateChain will fix the snapshots/gain
    await _db
        .into(_db.investmentTransactions)
        .insert(InvestmentTransactionsCompanion.insert(
          investmentId: investmentId,
          transactionDate: date,
          transactionType: type,
          amountInvested: Value(effectiveAmount),
          currentValueSnapshot: 0.0, // Placeholder
          calculatedGainLoss: const Value(0.0), // Placeholder
        ));

    await _recalculateChain(investmentId);
  }

  /// 3. Log Current Value (Mark-to-Market)
  Future<void> logValueUpdate(
      int investmentId, double newCurrentValue, DateTime date) async {
    await _db
        .into(_db.investmentTransactions)
        .insert(InvestmentTransactionsCompanion.insert(
          investmentId: investmentId,
          transactionDate: date,
          transactionType: 'valueUpdate',
          amountInvested: const Value(0.0),
          currentValueSnapshot: newCurrentValue, // User Input
          calculatedGainLoss: const Value(0.0), // Placeholder
        ));

    await _recalculateChain(investmentId);
  }

  /// 4. Update Investment Metadata
  Future<void> updateInvestment(InvestmentDto dto) async {
    if (dto.id == null) return;
    await _db.update(_db.investments).replace(InvestmentsCompanion(
          id: Value(dto.id!),
          name: Value(dto.name),
          type: Value(InvestmentDto.typeToString(dto.type)),
          subType: Value(dto.subType),
          providerName: Value(dto.providerName),
          providerWebsite: Value(dto.providerWebsite),
          startDate: Value(dto.startDate),
          endDate: Value(dto.endDate),
          expectedReturn: Value(dto.expectedReturn),
          isActive: Value(dto.isActive),
          folioNumber: Value(dto.folioNumber),
          units: Value(dto.units),
          brokerName: Value(dto.brokerName),
          linkedBankName: Value(dto.linkedBankName),
          linkedBankAccount: Value(dto.linkedBankAccount),
          purpose: Value(dto.purpose),
          notes: Value(dto.notes),
          specialId: Value(dto.specialId),
        ));
  }

  /// 5. Delete Investment (Cascading)
  Future<void> deleteInvestment(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.investmentTransactions)
            ..where((t) => t.investmentId.equals(id)))
          .go();
      await (_db.delete(_db.investments)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- SWIPE ACTIONS ---

  /// 6. Delete a Single Transaction Log
  Future<void> deleteTransaction(int transactionId) async {
    // 1. Get investment ID before deleting (to calc chain later)
    final txn = await (_db.select(_db.investmentTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();

    if (txn != null) {
      await (_db.delete(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .go();

      // Fix the chain for remaining items
      await _recalculateChain(txn.investmentId);
    }
  }

  /// 7. Update a specific Transaction Log
  Future<void> updateLog(int transactionId, double amount, DateTime date,
      bool isWithdrawal, String type) async {
    final txn = await (_db.select(_db.investmentTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();

    if (txn == null) return;

    if (type == 'valueUpdate') {
      // User is updating a Market Value entry
      await (_db.update(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(InvestmentTransactionsCompanion(
        transactionDate: Value(date),
        transactionType: Value(type),
        amountInvested: const Value(0.0), // Value updates have 0 investment
        currentValueSnapshot: Value(amount), // This is the new anchor
      ));
    } else {
      // User is updating an Investment/Withdrawal
      final effectiveAmount = isWithdrawal ? -amount.abs() : amount.abs();
      await (_db.update(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(InvestmentTransactionsCompanion(
        transactionDate: Value(date),
        transactionType: Value(isWithdrawal ? 'withdrawn' : 'invested'),
        amountInvested: Value(effectiveAmount),
        // We do NOT set currentValueSnapshot here, recalculateChain will derive it
      ));
    }

    await _recalculateChain(txn.investmentId);
  }

  // ===========================================================================
  //  READ OPERATIONS
  // ===========================================================================

  Stream<List<InvestmentDto>> watchAllInvestments() {
    return _db.select(_db.investments).watch().switchMap((investmentsList) {
      if (investmentsList.isEmpty) {
        return Stream.value([]);
      }
      final List<Stream<InvestmentDto>> streams = investmentsList.map((row) {
        return _watchInvestmentStats(row);
      }).toList();
      return CombineLatestStream.list(streams);
    });
  }

  Stream<InvestmentDto> _watchInvestmentStats(Investment row) {
    return (_db.select(_db.investmentTransactions)
          ..where((t) => t.investmentId.equals(row.id)))
        .watch()
        .map((transactions) {
      if (transactions.isEmpty) {
        return _mapToDto(row, 0, 0, 0, null);
      }

      double totalInvested = 0.0;
      List<XirrTransaction> xirrFlows = [];

      // Calculate Totals based on Transaction History
      for (var t in transactions) {
        if (t.transactionType == 'invested' ||
            t.transactionType == 'withdrawn') {
          totalInvested += t.amountInvested;
          // XIRR: Invested is negative cash flow (out of pocket)
          xirrFlows.add(XirrTransaction(t.transactionDate, -t.amountInvested));
        }
      }

      // Sort by date to find the Latest Snapshot
      transactions
          .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      final latest = transactions.first;

      // Add Current Value as positive cash flow for XIRR
      if (latest.currentValueSnapshot > 0) {
        xirrFlows
            .add(XirrTransaction(DateTime.now(), latest.currentValueSnapshot));
      }

      final double? calculatedXirr = XirrCalculator.calculate(xirrFlows);

      return _mapToDto(
        row,
        totalInvested,
        latest.currentValueSnapshot,
        latest.calculatedGainLoss,
        calculatedXirr,
      );
    });
  }

  Stream<List<InvestmentLogDto>> watchInvestmentDetails(int id) {
    return (_db.select(_db.investmentTransactions)
          ..where((t) => t.investmentId.equals(id))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.transactionDate, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) {
      return rows.map((row) {
        return InvestmentLogDto(
          id: row.id,
          investmentId: row.investmentId,
          date: row.transactionDate,
          type: row.transactionType,
          amountInvested: row.amountInvested,
          currentValue: row.currentValueSnapshot,
          gainLoss: row.calculatedGainLoss,
        );
      }).toList();
    });
  }

  InvestmentDto _mapToDto(Investment row, double totalInvested,
      double currentVal, double gain, double? xirr) {
    double returnPct = 0.0;
    if (totalInvested > 0) {
      returnPct = (gain / totalInvested) * 100;
    }
    return InvestmentDto(
      id: row.id,
      name: row.name,
      type: InvestmentDto.stringToType(row.type),
      subType: row.subType,
      providerName: row.providerName,
      providerWebsite: row.providerWebsite,
      startDate: row.startDate,
      endDate: row.endDate,
      expectedReturn: row.expectedReturn,
      isActive: row.isActive,
      folioNumber: row.folioNumber,
      units: row.units,
      brokerName: row.brokerName,
      linkedBankName: row.linkedBankName,
      linkedBankAccount: row.linkedBankAccount,
      purpose: row.purpose,
      notes: row.notes,
      specialId: row.specialId,
      totalInvestedAmount: totalInvested,
      currentMarketValue: currentVal,
      totalGainLoss: gain,
      returnPercentage: returnPct,
      xirr: xirr,
    );
  }
}
