import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_record_model.dart';
import '../models/percentage_config_model.dart';
import '../models/settlement_model.dart';
import '../models/mf_transaction_model.dart';
import '../models/mf_portfolio_snapshot_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FinancialRecord>> getFinancialRecords() {
    return _db
        .collection('financial_records')
        .orderBy('id', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FinancialRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> setFinancialRecord(FinancialRecord record) {
    return _db
        .collection('financial_records')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<FinancialRecord> getRecordById(String id) async {
    final doc = await _db.collection('financial_records').doc(id).get();
    return FinancialRecord.fromFirestore(doc);
  }

  Future<PercentageConfig> getPercentageConfig() async {
    final doc = await _db.collection('settings').doc('percentages').get();
    if (doc.exists) {
      return PercentageConfig.fromFirestore(doc);
    } else {
      return PercentageConfig.defaultConfig();
    }
  }

  Future<void> setPercentageConfig(PercentageConfig config) {
    return _db.collection('settings').doc('percentages').set(config.toMap());
  }

  Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
    final snapshot = await _db.collection('financial_records').get();
    final uniqueMonths = <String, Map<String, int>>{};

    for (var doc in snapshot.docs) {
      final record = FinancialRecord.fromFirestore(doc);
      uniqueMonths[record.id] = {'year': record.year, 'month': record.month};
    }

    var sortedList = uniqueMonths.values.toList();
    sortedList.sort((a, b) {
      final yearA = a['year']!;
      final monthA = a['month']!;
      final yearB = b['year']!;
      final monthB = b['month']!;
      if (yearB.compareTo(yearA) != 0) {
        return yearB.compareTo(yearA);
      }
      return monthB.compareTo(monthA);
    });

    return sortedList;
  }

  Future<Settlement?> getSettlementById(String id) async {
    final doc = await _db.collection('settlements').doc(id).get();
    if (doc.exists) {
      return Settlement.fromFirestore(doc);
    }
    return null;
  }

  Future<void> saveSettlement(Settlement settlement) {
    return _db
        .collection('settlements')
        .doc(settlement.id)
        .set(settlement.toMap());
  }

  Stream<List<MfTransaction>> getMfTransactions() {
    return _db
        .collection('mf_transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MfTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addMfTransaction(MfTransaction transaction) {
    return _db.collection('mf_transactions').add(transaction.toMap());
  }

  Stream<List<MfPortfolioSnapshot>> getMfPortfolioSnapshots() {
    return _db
        .collection('mf_portfolio_snapshots')
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MfPortfolioSnapshot.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addMfPortfolioSnapshot(MfPortfolioSnapshot snapshot) {
    return _db.collection('mf_portfolio_snapshots').add(snapshot.toMap());
  }

  Future<List<String>> getFundNames() async {
    final doc = await _db.collection('mf_fund_names').doc('user_funds').get();
    if (doc.exists && doc.data()!.containsKey('names')) {
      return List<String>.from(doc.data()!['names']);
    }
    return [];
  }

  Future<void> addFundName(String newFundName) {
    return _db.collection('mf_fund_names').doc('user_funds').set({
      'names': FieldValue.arrayUnion([newFundName]),
    }, SetOptions(merge: true));
  }

  Future<void> updateMfTransaction(String id, MfTransaction transaction) {
    return _db
        .collection('mf_transactions')
        .doc(id)
        .update(transaction.toMap());
  }

  Future<void> deleteMfTransaction(String id) {
    return _db.collection('mf_transactions').doc(id).delete();
  }
}
