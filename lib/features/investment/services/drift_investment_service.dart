import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
// Note: We don't need cloud_firestore here if the model uses DateTime
import '../../../../core/database/app_database.dart';
import '../models/investment_model.dart' as domain;
import 'investment_service.dart';

class DriftInvestmentService extends InvestmentService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  domain.InvestmentRecord _mapInv(InvestmentRecord row) {
    return domain.InvestmentRecord(
      id: row.id,
      name: row.name,
      symbol: row.symbol,
      // Safe enum parsing
      type: domain.InvestmentType.values.firstWhere(
          (e) => e.toString() == row.type,
          orElse: () => domain.InvestmentType.stock),
      // Removed 'bucket' if it causes errors, otherwise keep it.
      // Assuming 'bucket' exists in Model based on your previous code.
      bucket: row.bucket,
      quantity: row.quantity,
      averagePrice: row.averagePrice,
      currentPrice: row.currentPrice,
      previousClose: row.previousClose,
      // Fix: Pass DateTime directly (No Timestamp conversion)
      lastPurchasedDate: row.lastPurchasedDate,
      lastUpdated: row.lastUpdated,
      // Removed 'isManual' because the Model doesn't support it
    );
  }

  @override
  Stream<List<domain.InvestmentRecord>> getInvestments() {
    return (_db.select(_db.investmentRecords)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.name)]))
        .watch()
        .map((rows) => rows.map(_mapInv).toList());
  }

  @override
  Future<void> addInvestment(domain.InvestmentRecord r) async {
    final id = r.id.isNotEmpty ? r.id : _uuid.v4();
    await _db
        .into(_db.investmentRecords)
        .insert(InvestmentRecordsCompanion.insert(
          id: id,
          name: r.name,
          symbol: r.symbol,
          type: r.type.toString(),
          bucket: drift.Value(r.bucket),
          quantity: r.quantity,
          averagePrice: r.averagePrice,
          currentPrice: r.currentPrice,
          previousClose: drift.Value(r.previousClose),
          // Fix: Pass DateTime directly
          lastPurchasedDate: r.lastPurchasedDate,
          lastUpdated: DateTime.now(),
          // Default isManual to false since Model doesn't provide it
          isManual: const drift.Value(false),
        ));
  }
}
