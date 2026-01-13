import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../models/investment_model.dart' as domain;
import '../models/search_result_model.dart';

class InvestmentService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  domain.InvestmentRecord _mapInv(InvestmentRecord row) {
    return domain.InvestmentRecord(
      id: row.id,
      name: row.name,
      symbol: row.symbol,
      type: domain.InvestmentType.values.firstWhere(
          (e) => e.toString() == row.type,
          orElse: () => domain.InvestmentType.stock),
      bucket: row.bucket,
      quantity: row.quantity,
      averagePrice: row.averagePrice,
      currentPrice: row.currentPrice,
      previousClose: row.previousClose,
      lastPurchasedDate: row.lastPurchasedDate,
      lastUpdated: row.lastUpdated,
    );
  }

  Stream<List<domain.InvestmentRecord>> getInvestments() {
    return (_db.select(_db.investmentRecords)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch()
        .map((rows) => rows.map(_mapInv).toList());
  }

  Future<void> addInvestment(domain.InvestmentRecord r) async {
    final id = r.id.isNotEmpty ? r.id : _uuid.v4();
    await _db
        .into(_db.investmentRecords)
        .insert(InvestmentRecordsCompanion.insert(
          id: id,
          name: r.name,
          symbol: r.symbol,
          type: r.type.toString(),
          bucket: Value(r.bucket),
          quantity: r.quantity,
          averagePrice: r.averagePrice,
          currentPrice: r.currentPrice,
          previousClose: Value(r.previousClose),
          lastPurchasedDate: r.lastPurchasedDate,
          lastUpdated: DateTime.now(),
          isManual: const Value(false),
        ));
  }

  Future<void> updateInvestment(domain.InvestmentRecord r) async {
    await (_db.update(_db.investmentRecords)..where((t) => t.id.equals(r.id)))
        .write(InvestmentRecordsCompanion(
      quantity: Value(r.quantity),
      averagePrice: Value(r.averagePrice),
      currentPrice: Value(r.currentPrice),
      previousClose: Value(r.previousClose),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  Future<void> deleteInvestment(String id) async {
    await (_db.delete(_db.investmentRecords)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> mergeInvestment(
      domain.InvestmentRecord oldRec, domain.InvestmentRecord newRec) async {
    double totalOldVal = oldRec.quantity * oldRec.averagePrice;
    double totalNewVal = newRec.quantity * newRec.averagePrice;
    double newQty = oldRec.quantity + newRec.quantity;
    double newAvg = (totalOldVal + totalNewVal) / newQty;

    await (_db.update(_db.investmentRecords)
          ..where((t) => t.id.equals(oldRec.id)))
        .write(InvestmentRecordsCompanion(
      quantity: Value(newQty),
      averagePrice: Value(newAvg),
      currentPrice: Value(newRec.currentPrice),
      previousClose: Value(newRec.previousClose),
      lastPurchasedDate: Value(newRec.lastPurchasedDate),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  Future<domain.InvestmentRecord?> findExactMatch(
      String symbol, String bucket) async {
    final row = await (_db.select(_db.investmentRecords)
          ..where((t) => t.symbol.equals(symbol))
          ..where((t) => t.bucket.equals(bucket))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _mapInv(row) : null;
  }

  Future<List<String>> getUniqueBuckets() async {
    final query = _db.selectOnly(_db.investmentRecords, distinct: true)
      ..addColumns([_db.investmentRecords.bucket]);
    final result = await query.get();
    return result
        .map((row) => row.read(_db.investmentRecords.bucket)!)
        .toList();
  }

  Future<void> refreshAllPrices() async {
    // Implement price fetch logic here or simply update timestamp
    await (_db.update(_db.investmentRecords))
        .write(InvestmentRecordsCompanion(lastUpdated: Value(DateTime.now())));
  }

  // Placeholder for search to prevent errors
  Future<List<InvestmentSearchResult>> searchSymbols(
          String query, domain.InvestmentType type) async =>
      [];
  Future<Map<String, double>> fetchPriceData(
          String symbol, domain.InvestmentType type) async =>
      {'price': 0.0, 'prev': 0.0};
}
