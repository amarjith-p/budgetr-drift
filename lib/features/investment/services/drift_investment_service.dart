import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/app_database.dart';
import '../models/investment_model.dart';
import 'investment_service.dart';

class DriftInvestmentService extends InvestmentService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  InvestmentRecord _mapInv(InvestmentRecord row) {
    return InvestmentRecord(
      id: row.id,
      name: row.name,
      symbol: row.symbol,
      type: InvestmentType.values.firstWhere((e) => e.toString() == row.type),
      bucket: row.bucket,
      quantity: row.quantity,
      averagePrice: row.averagePrice,
      currentPrice: row.currentPrice,
      previousClose: row.previousClose,
      lastPurchasedDate: Timestamp.fromDate(row.lastPurchasedDate),
      lastUpdated: Timestamp.fromDate(row.lastUpdated),
    );
  }

  @override
  Stream<List<InvestmentRecord>> getInvestments() {
    return (_db.select(_db.investmentRecords)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.name)]))
        .watch()
        .map((rows) => rows.map(_mapInv).toList());
  }

  @override
  Future<void> addInvestment(InvestmentRecord r) async {
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
          lastPurchasedDate: r.lastPurchasedDate.toDate(),
          lastUpdated: DateTime.now(),
        ));
  }

  // Reuse API logic from parent for search/fetchPriceData as they don't depend on Firestore
}
