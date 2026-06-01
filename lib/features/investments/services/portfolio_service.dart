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
  //  CORE: CHAIN RECALCULATION ENGINE
  // ===========================================================================

  Future<void> _recalculateChain(int investmentId) async {
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

        if (isValueUpdate) {
          runningCurrentValue = txn.currentValueSnapshot;
        } else {
          runningCurrentValue += txn.amountInvested;
          runningTotalInvested += txn.amountInvested;

          // ===================================================================
          // [NEW] ZERO-FLOOR CAP: Prevents the negative principal bug globally
          // If a user withdraws more than they invested (withdrawing profits),
          // the principal hits zero and stops.
          // ===================================================================
          if (runningTotalInvested < 0) {
            runningTotalInvested = 0.0;
          }
        }

        final double currentGain = runningCurrentValue - runningTotalInvested;

        await (_db.update(_db.investmentTransactions)
              ..where((t) => t.id.equals(txn.id)))
            .write(InvestmentTransactionsCompanion(
          currentValueSnapshot: Value(runningCurrentValue),
          calculatedGainLoss: Value(currentGain),
        ));
      }
    });
  }

  // ===========================================================================
  //  WRITE OPERATIONS
  // ===========================================================================

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
                targetAmount: Value(dto.targetAmount),
                status: const Value('active'),
                // [NEW] Map exclude flag on creation
                excludeFromNetWorth: Value(dto.excludeFromNetWorth),
              ));

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

      await _recalculateChain(id);
    });
  }

  Future<void> logInvestmentTransaction(
      int investmentId, double amount, DateTime date,
      {bool isWithdrawal = false}) async {
    final effectiveAmount = isWithdrawal ? -amount : amount;
    final String type = isWithdrawal ? 'withdrawn' : 'invested';

    await _db
        .into(_db.investmentTransactions)
        .insert(InvestmentTransactionsCompanion.insert(
          investmentId: investmentId,
          transactionDate: date,
          transactionType: type,
          amountInvested: Value(effectiveAmount),
          currentValueSnapshot: 0.0,
          calculatedGainLoss: const Value(0.0),
        ));

    await _recalculateChain(investmentId);
  }

  // ===========================================================================
  //  [UPDATED] SAFE WITHDRAWAL: Flat Math for Cash-Based Clarity
  // ===========================================================================
  Future<void> logSafeWithdrawal(
      int investmentId, double withdrawalAmount, DateTime date) async {
    final allInvestments = await watchAllInvestments().first;
    final inv = allInvestments.firstWhere((e) => e.id == investmentId);

    await _db.transaction(() async {
      // 1. Log EXACTLY what the user requested to withdraw
      await _db
          .into(_db.investmentTransactions)
          .insert(InvestmentTransactionsCompanion.insert(
            investmentId: investmentId,
            transactionDate: date,
            transactionType: 'withdrawn',
            amountInvested: Value(-withdrawalAmount),
            currentValueSnapshot: 0.0,
            calculatedGainLoss: const Value(0.0),
          ));

      // 2. Reduce the current market value by a flat amount
      double newMarketValue = inv.currentMarketValue - withdrawalAmount;
      if (newMarketValue < 0) newMarketValue = 0;

      await _db
          .into(_db.investmentTransactions)
          .insert(InvestmentTransactionsCompanion.insert(
            investmentId: investmentId,
            transactionDate: date
                .add(const Duration(seconds: 1)), // Slight offset for sorting
            transactionType: 'valueUpdate',
            amountInvested: const Value(0.0),
            currentValueSnapshot: newMarketValue,
            calculatedGainLoss: const Value(0.0),
          ));
    });

    await _recalculateChain(investmentId);
  }

  // ===========================================================================
  //  INVESTMENT CLOSURE
  // ===========================================================================
  Future<void> closeInvestment(int investmentId, double realizationAmount,
      DateTime date, String reason) async {
    await (_db.update(_db.investments)..where((t) => t.id.equals(investmentId)))
        .write(InvestmentsCompanion(
      status: const Value('closed'),
      isActive: const Value(false),
      realizedValue: Value(realizationAmount),
      closureDate: Value(date),
      closureReason: Value(reason),
    ));
    await logValueUpdate(investmentId, realizationAmount, date);
  }

  Future<void> logValueUpdate(
      int investmentId, double newCurrentValue, DateTime date) async {
    await _db
        .into(_db.investmentTransactions)
        .insert(InvestmentTransactionsCompanion.insert(
          investmentId: investmentId,
          transactionDate: date,
          transactionType: 'valueUpdate',
          amountInvested: const Value(0.0),
          currentValueSnapshot: newCurrentValue,
          calculatedGainLoss: const Value(0.0),
        ));

    await _recalculateChain(investmentId);
  }

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
          targetAmount: Value(dto.targetAmount),
          status: Value(dto.status),
          realizedValue: Value(dto.realizedValue),
          closureDate: Value(dto.closureDate),
          closureReason: Value(dto.closureReason),
          // [NEW] Map exclude flag on update
          excludeFromNetWorth: Value(dto.excludeFromNetWorth),
        ));
  }

  Future<void> deleteInvestment(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.investmentTransactions)
            ..where((t) => t.investmentId.equals(id)))
          .go();
      await (_db.delete(_db.investments)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> deleteTransaction(int transactionId) async {
    final txn = await (_db.select(_db.investmentTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();

    if (txn != null) {
      await (_db.delete(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .go();

      await _recalculateChain(txn.investmentId);
    }
  }

  Future<void> updateLog(int transactionId, double amount, DateTime date,
      bool isWithdrawal, String type) async {
    final txn = await (_db.select(_db.investmentTransactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();

    if (txn == null) return;

    if (type == 'valueUpdate') {
      await (_db.update(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(InvestmentTransactionsCompanion(
        transactionDate: Value(date),
        transactionType: Value(type),
        amountInvested: const Value(0.0),
        currentValueSnapshot: Value(amount),
      ));
    } else {
      final effectiveAmount = isWithdrawal ? -amount.abs() : amount.abs();
      await (_db.update(_db.investmentTransactions)
            ..where((t) => t.id.equals(transactionId)))
          .write(InvestmentTransactionsCompanion(
        transactionDate: Value(date),
        transactionType: Value(isWithdrawal ? 'withdrawn' : 'invested'),
        amountInvested: Value(effectiveAmount),
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

      for (var t in transactions) {
        if (t.transactionType == 'invested' ||
            t.transactionType == 'withdrawn') {
          totalInvested += t.amountInvested;
          // Apply the same cap here for the DTO snapshot to match the chain
          if (totalInvested < 0) totalInvested = 0.0;
          xirrFlows.add(XirrTransaction(t.transactionDate, -t.amountInvested));
        }
      }

      transactions
          .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      final latest = transactions.first;

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
      targetAmount: row.targetAmount,
      status: row.status,
      realizedValue: row.realizedValue,
      closureDate: row.closureDate,
      closureReason: row.closureReason,
      // [NEW] Map exclude flag when reading from DB
      excludeFromNetWorth: row.excludeFromNetWorth,
      totalInvestedAmount: totalInvested,
      currentMarketValue: currentVal,
      totalGainLoss: gain,
      returnPercentage: returnPct,
      xirr: xirr,
    );
  }
}