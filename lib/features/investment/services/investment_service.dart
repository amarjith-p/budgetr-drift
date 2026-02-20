import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../custom_entry/services/custom_entry_service.dart';
import '../../../core/models/custom_data_models.dart';
import '../models/investment_model.dart';
import '../models/search_result_model.dart';
// [NEW] Import Notification Service for the Hook
import '../../notifications/services/notification_service.dart';

class InvestmentService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();
  static List<dynamic>? _cachedMfList;

  // --- MAPPERS ---

  InvestmentRecord _mapInv(db.InvestmentRecord row) {
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

  Future<void> triggerBucketAutoTracker() async {
    final customEntryService = GetIt.I<CustomEntryService>();
    final templateId =
        await customEntryService.ensureInvestmentTemplateExists();
    final buckets = await getUniqueBuckets();

    for (var bucket in buckets) {
      final rows = await (_db.select(_db.investmentRecords)
            ..where((t) => t.bucket.equals(bucket)))
          .get();

      if (rows.isEmpty) continue;

      double totalInvested = 0.0;
      double totalCurrent = 0.0;
      double totalDayGain = 0.0;

      for (var row in rows) {
        final qty = row.quantity;
        final avg = row.averagePrice;
        final cur = row.currentPrice;
        final prev = row.previousClose;

        totalInvested += (qty * avg);
        totalCurrent += (qty * cur);
        totalDayGain += ((cur - prev) * qty);
      }

      final totalGain = totalCurrent - totalInvested;
      double returnsPercent = 0.0;
      if (totalInvested > 0) {
        returnsPercent = (totalGain / totalInvested) * 100;
      }

      final record = CustomRecord(
        id: _uuid.v4(),
        templateId: templateId,
        createdAt: DateTime.now(),
        data: {
          'Date': DateTime.now(),
          'Bucket Name': bucket,
          'Invested': totalInvested,
          'Current Value': totalCurrent,
          'Day Gain': totalDayGain,
          'Total Gain': totalGain,
          'Returns %': returnsPercent,
        },
      );

      await customEntryService.addCustomRecord(record);
    }
  }

  // --- API / PRICE LOGIC ---

  Future<void> refreshAllPrices() async {
    final allRows = await _db.select(_db.investmentRecords).get();

    for (var row in allRows) {
      final r = _mapInv(row);
      if (r.type == InvestmentType.other) continue;

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

    // [HOOK] Trigger Notifications after price update
    // We use GetIt lazy access to avoid circular dependency in constructors
    // try {
    //   if (GetIt.I.isRegistered<NotificationService>()) {
    //     await GetIt.I<NotificationService>()
    //         .checkInvestmentVolatilityAndMilestones();
    //   }
    // } catch (e) {
    //   print("Notification Hook Error: $e");
    // }
  }

  // --- SEARCH LOGIC ---

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
        .get();

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
          'https://query1.finance.yahoo.com/v1/finance/search?q=$query&quotesCount=10');

      final res = await http.get(url, headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final quotes = data['quotes'] as List;

        return quotes
            .where((q) => q['quoteType'] == 'EQUITY')
            .where((q) => (q['symbol'] as String).contains('.'))
            .map((q) {
          return InvestmentSearchResult(
            symbol: q['symbol'],
            name: q['shortname'] ?? q['longname'] ?? q['symbol'],
            type: 'Stock',
            exchange: q['exchange'] ?? 'N/A',
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
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=1d');

      final response = await http.get(url, headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']['result'];

        if (result == null || result.isEmpty) {
          return {'price': 0.0, 'prev': 0.0};
        }

        final meta = result[0]['meta'];
        double price = (meta['regularMarketPrice'] ?? 0.0).toDouble();
        double prev = (meta['chartPreviousClose'] ?? 0.0).toDouble();

        return {'price': price, 'prev': prev};
      } else {
        print("Yahoo API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Yahoo Price Exception: $e");
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
