import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/investment_model.dart';
import '../models/search_result_model.dart';

class InvestmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'investments';
  static List<dynamic>? _cachedMfList;

  // --- Search Logic ---
  Future<List<InvestmentSearchResult>> searchSymbols(
    String query,
    InvestmentType type,
  ) async {
    if (query.length < 2) return [];
    if (type == InvestmentType.stock) return _searchYahooStocks(query);
    if (type == InvestmentType.mutualFund) return _searchMutualFunds(query);
    if (type == InvestmentType.other) return _searchLocalAssets(query);
    return [];
  }

  Future<List<InvestmentSearchResult>> _searchLocalAssets(String query) async {
    final snapshot = await _db
        .collection(_collection)
        .where('type', isEqualTo: InvestmentType.other.toString())
        .get();

    final results = snapshot.docs
        .map((d) => InvestmentRecord.fromFirestore(d))
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .map(
          (r) => InvestmentSearchResult(
            symbol: r.symbol,
            name: r.name,
            type: "OTHER",
            exchange: "MANUAL",
          ),
        )
        .toList();

    final unique = <String>{};
    final distinct = <InvestmentSearchResult>[];
    for (var item in results) {
      if (unique.add(item.name)) distinct.add(item);
    }
    return distinct;
  }

  // --- NEW: Fetch Price Data (Returns Price & Prev Close) ---
  Future<Map<String, double>> fetchPriceData(
    String symbol,
    InvestmentType type,
  ) async {
    if (type == InvestmentType.stock) return _fetchYahooPriceData(symbol);
    if (type == InvestmentType.mutualFund) return _fetchMfNavData(symbol);
    return {'price': 0.0, 'prev': 0.0};
  }

  // Yahoo Finance: Get Price & Chart Previous Close
  Future<Map<String, double>> _fetchYahooPriceData(String symbol) async {
    try {
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=1d',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meta = data['chart']['result'][0]['meta'];
        return {
          'price': (meta['regularMarketPrice'] ?? 0.0).toDouble(),
          'prev': (meta['chartPreviousClose'] ?? 0.0).toDouble(),
        };
      }
    } catch (_) {}
    return {'price': 0.0, 'prev': 0.0};
  }

  // MFAPI: Get Latest NAV & Previous NAV
  Future<Map<String, double>> _fetchMfNavData(String code) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mfapi.in/mf/$code'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List navList = data['data'];
        if (navList.isNotEmpty) {
          final current = double.parse(navList[0]['nav'].toString());
          // If history exists, get prev, else same as current
          final prev = navList.length > 1
              ? double.parse(navList[1]['nav'].toString())
              : current;
          return {'price': current, 'prev': prev};
        }
      }
    } catch (_) {}
    return {'price': 0.0, 'prev': 0.0};
  }

  // --- API Helpers (Search) ---
  Future<List<InvestmentSearchResult>> _searchYahooStocks(String query) async {
    try {
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v1/finance/search?q=$query&quotesCount=10',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['quotes'] as List)
            .where(
              (q) =>
                  q['quoteType'] == 'EQUITY' &&
                  (q['symbol'] as String).contains('.'),
            )
            .map<InvestmentSearchResult>(
              (q) => InvestmentSearchResult(
                symbol: q['symbol'],
                name: q['shortname'] ?? q['longname'] ?? q['symbol'],
                type: "STOCK",
                exchange: q['exchange'] ?? 'N/A',
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<InvestmentSearchResult>> _searchMutualFunds(String query) async {
    try {
      if (_cachedMfList == null) {
        final response = await http.get(Uri.parse('https://api.mfapi.in/mf'));
        if (response.statusCode == 200)
          _cachedMfList = json.decode(response.body);
      }
      final q = query.toLowerCase();
      return _cachedMfList!
          .where((mf) => (mf['schemeName'] as String).toLowerCase().contains(q))
          .take(10)
          .map(
            (mf) => InvestmentSearchResult(
              symbol: mf['schemeCode'].toString(),
              name: mf['schemeName'],
              type: "MF",
              exchange: "AMFI",
            ),
          )
          .toList();
    } catch (_) {}
    return [];
  }

  // --- Firestore CRUD ---
  Stream<List<InvestmentRecord>> getInvestments() {
    return _db
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map(
          (s) => s.docs.map((d) => InvestmentRecord.fromFirestore(d)).toList(),
        );
  }

  Future<List<String>> getUniqueBuckets() async {
    final docs = await _db.collection(_collection).get();
    return docs.docs
        .map((d) => d.data()['bucket'] as String?)
        .where((b) => b != null && b.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
  }

  Future<InvestmentRecord?> findExactMatch(String symbol, String bucket) async {
    final q = await _db
        .collection(_collection)
        .where('symbol', isEqualTo: symbol)
        .where('bucket', isEqualTo: bucket)
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) return InvestmentRecord.fromFirestore(q.docs.first);
    return null;
  }

  Future<void> addInvestment(InvestmentRecord r) =>
      _db.collection(_collection).add(r.toMap());
  Future<void> updateInvestment(InvestmentRecord r) =>
      _db.collection(_collection).doc(r.id).update(r.toMap());
  Future<void> deleteInvestment(String id) =>
      _db.collection(_collection).doc(id).delete();

  Future<void> mergeInvestment(
    InvestmentRecord oldRec,
    InvestmentRecord newRec,
  ) async {
    double totalOldVal = oldRec.quantity * oldRec.averagePrice;
    double totalNewVal = newRec.quantity * newRec.averagePrice;
    double newQty = oldRec.quantity + newRec.quantity;
    double newAvg = (totalOldVal + totalNewVal) / newQty;

    await _db.collection(_collection).doc(oldRec.id).update({
      'quantity': newQty,
      'averagePrice': newAvg,
      'currentPrice': newRec.currentPrice,
      'previousClose': newRec.previousClose, // Update Prev Close
      'lastPurchasedDate': Timestamp.fromDate(newRec.lastPurchasedDate),
      'lastUpdated': Timestamp.now(),
    });
  }

  Future<void> refreshAllPrices() async {
    final docs = await _db.collection(_collection).get();
    final batch = _db.batch();
    for (var doc in docs.docs) {
      final r = InvestmentRecord.fromFirestore(doc);
      if (r.type == InvestmentType.other) continue;

      final data = await fetchPriceData(r.symbol, r.type);
      if (data['price']! > 0) {
        batch.update(doc.reference, {
          'currentPrice': data['price'],
          'previousClose': data['prev'], // Update Prev Close
          'lastUpdated': Timestamp.now(),
        });
      }
    }
    await batch.commit();
  }
}
