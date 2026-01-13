import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart' as db;
import '../models/investment_model.dart';
import '../models/search_result_model.dart';

class InvestmentService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();
  static List<dynamic>? _cachedMfList;

  // --- MAPPERS ---

  InvestmentRecord _mapInv(db.InvestmentRecord row) {
    // Parse Enum from String
    InvestmentType t = InvestmentType.stock;
    if (row.type.contains('mutualFund')) t = InvestmentType.mutualFund;
    if (row.type.contains('other')) t = InvestmentType.other;

    return InvestmentRecord(
      id: row.id,
      symbol: row.symbol,
      name: row.name,
      type: t,
      quantity: row.quantity,
      averagePrice: row.averagePrice,
      currentPrice: row.currentPrice,
      previousClose: row.previousClose,
      bucket: row.bucket,
      lastPurchasedDate: row.lastPurchasedDate,
      lastUpdated: row.lastUpdated,
    );
  }

  // --- CRUD OPERATIONS ---

  Stream<List<InvestmentRecord>> getInvestments() {
    return (_db.select(_db.investmentRecords)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch()
        .map((rows) => rows.map(_mapInv).toList());
  }

  Future<void> addInvestment(InvestmentRecord r) async {
    final id = r.id.isNotEmpty ? r.id : _uuid.v4();

    await _db
        .into(_db.investmentRecords)
        .insert(db.InvestmentRecordsCompanion.insert(
          id: id,
          symbol: r.symbol,
          name: r.name,
          type: r.type.toString(),
          quantity: r.quantity,
          averagePrice: r.averagePrice,
          currentPrice: r.currentPrice,
          previousClose: Value(r.previousClose),
          bucket: Value(r.bucket),
          lastPurchasedDate: r.lastPurchasedDate,
          lastUpdated: DateTime.now(),
          isManual: const Value(false),
        ));
  }

  Future<void> updateInvestment(InvestmentRecord r) async {
    await (_db.update(_db.investmentRecords)..where((t) => t.id.equals(r.id)))
        .write(db.InvestmentRecordsCompanion(
      quantity: Value(r.quantity),
      averagePrice: Value(r.averagePrice),
      currentPrice: Value(r.currentPrice),
      previousClose: Value(r.previousClose),
      lastPurchasedDate: Value(r.lastPurchasedDate),
      lastUpdated: Value(DateTime.now()),
      bucket: Value(r.bucket),
    ));
  }

  Future<void> deleteInvestment(String id) async {
    await (_db.delete(_db.investmentRecords)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> mergeInvestment(
      InvestmentRecord oldRec, InvestmentRecord newRec) async {
    // Weighted Average Logic
    double totalOldVal = oldRec.quantity * oldRec.averagePrice;
    double totalNewVal = newRec.quantity * newRec.averagePrice;
    double newQty = oldRec.quantity + newRec.quantity;
    double newAvg = (totalOldVal + totalNewVal) / newQty;

    await (_db.update(_db.investmentRecords)
          ..where((t) => t.id.equals(oldRec.id)))
        .write(db.InvestmentRecordsCompanion(
      quantity: Value(newQty),
      averagePrice: Value(newAvg),
      currentPrice: Value(newRec.currentPrice),
      previousClose: Value(newRec.previousClose),
      lastPurchasedDate: Value(newRec.lastPurchasedDate),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  Future<InvestmentRecord?> findExactMatch(String symbol, String bucket) async {
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

  // --- API / PRICE LOGIC ---

  Future<void> refreshAllPrices() async {
    final allRows = await _db.select(_db.investmentRecords).get();

    for (var row in allRows) {
      final r = _mapInv(row);
      if (r.type == InvestmentType.other) continue; // Skip custom/manual assets

      // Fetch new price
      final data = await fetchPriceData(r.symbol, r.type);
      if (data['price']! > 0) {
        await (_db.update(_db.investmentRecords)
              ..where((t) => t.id.equals(r.id)))
            .write(db.InvestmentRecordsCompanion(
          currentPrice: Value(data['price']!),
          previousClose: Value(data['prev']!),
          lastUpdated: Value(DateTime.now()),
        ));
      }
    }
  }

  // --- SEARCH LOGIC (Kept largely the same, but using Drift for local search) ---

  Future<List<InvestmentSearchResult>> searchSymbols(
      String query, InvestmentType type) async {
    if (query.length < 2) return [];
    if (type == InvestmentType.stock) return _searchYahooStocks(query);
    if (type == InvestmentType.mutualFund) return _searchMutualFunds(query);
    if (type == InvestmentType.other) return _searchLocalAssets(query);
    return [];
  }

  Future<List<InvestmentSearchResult>> _searchLocalAssets(String query) async {
    final rows = await (_db.select(_db.investmentRecords)
          ..where((t) => t.type.like('%other%')))
        .get(); // Naive filter for 'other' type

    return rows
        .map(_mapInv)
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .map((r) => InvestmentSearchResult(
              symbol: r.symbol,
              name: r.name,
              type: 'Other',
              exchange: 'Local',
            ))
        .toList();
  }

  Future<List<InvestmentSearchResult>> _searchYahooStocks(String query) async {
    try {
      final url = Uri.parse(
          'https://query1.finance.yahoo.com/v1/finance/search?q=$query&quotesCount=10&newsCount=0');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final quotes = data['quotes'] as List;
        return quotes.map((q) {
          return InvestmentSearchResult(
            symbol: q['symbol'],
            name: q['shortname'] ?? q['longname'] ?? q['symbol'],
            type: q['quoteType'] ?? 'Stock',
            exchange: q['exchange'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      print("Yahoo Search Error: $e");
    }
    return [];
  }

  Future<List<InvestmentSearchResult>> _searchMutualFunds(String query) async {
    try {
      if (_cachedMfList == null) {
        final res = await http.get(Uri.parse('https://api.mfapi.in/mf'));
        if (res.statusCode == 200) {
          _cachedMfList = jsonDecode(res.body) as List;
        }
      }
      if (_cachedMfList == null) return [];

      final lowerQ = query.toLowerCase();
      return _cachedMfList!
          .where((mf) =>
              (mf['schemeName'] as String).toLowerCase().contains(lowerQ))
          .take(15)
          .map((mf) => InvestmentSearchResult(
                symbol: mf['schemeCode'].toString(),
                name: mf['schemeName'],
                type: 'Mutual Fund',
                exchange: 'MFAPI',
              ))
          .toList();
    } catch (e) {
      print("MF Search Error: $e");
    }
    return [];
  }

  // --- PRICE FETCHING ---

  Future<Map<String, double>> fetchPriceData(
      String symbol, InvestmentType type) async {
    if (type == InvestmentType.stock) return _fetchYahooPriceData(symbol);
    if (type == InvestmentType.mutualFund) return _fetchMfNavData(symbol);
    return {'price': 0.0, 'prev': 0.0};
  }

  Future<Map<String, double>> _fetchYahooPriceData(String symbol) async {
    try {
      final url = Uri.parse(
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=2d');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final result = json['chart']['result'][0];
        final meta = result['meta'];
        double price = (meta['regularMarketPrice'] as num).toDouble();
        double prev = (meta['previousClose'] as num).toDouble();
        return {'price': price, 'prev': prev};
      }
    } catch (e) {
      print("Yahoo Price Error: $e");
    }
    return {'price': 0.0, 'prev': 0.0};
  }

  Future<Map<String, double>> _fetchMfNavData(String schemeCode) async {
    try {
      final url = Uri.parse('https://api.mfapi.in/mf/$schemeCode');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['data'] as List;
        if (data.isNotEmpty) {
          double price = double.parse(data[0]['nav']);
          double prev = data.length > 1 ? double.parse(data[1]['nav']) : price;
          return {'price': price, 'prev': prev};
        }
      }
    } catch (e) {
      print("MF Price Error: $e");
    }
    return {'price': 0.0, 'prev': 0.0};
  }
}
