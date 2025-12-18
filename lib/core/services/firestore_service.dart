import 'package:budget/core/models/custom_data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_record_model.dart';
import '../models/percentage_config_model.dart';
import '../models/settlement_model.dart';
import '../models/mf_transaction_model.dart';
import '../models/mf_portfolio_snapshot_model.dart';
import '../models/net_worth_model.dart';
import '../models/net_worth_split_model.dart'; // Import the new split model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // FINANCIAL RECORDS (DASHBOARD)
  // ---------------------------------------------------------------------------
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

  Future<void> deleteFinancialRecord(String id) async {
    final batch = _db.batch();

    // 1. Delete the Budget Record
    final financeRef = _db.collection('financial_records').doc(id);
    batch.delete(financeRef);

    // 2. Delete the Settlement Record for that same month (if exists)
    final settlementRef = _db.collection('settlements').doc(id);
    batch.delete(settlementRef);

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // SETTINGS & CONFIGURATION
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // SETTLEMENTS
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // MUTUAL FUNDS
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // NET WORTH (TOTAL)
  // ---------------------------------------------------------------------------
  Stream<List<NetWorthRecord>> getNetWorthRecords() {
    return _db
        .collection('net_worth')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NetWorthRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addNetWorthRecord(NetWorthRecord record) {
    return _db.collection('net_worth').add(record.toMap());
  }

  // NEW: Delete Net Worth Record
  Future<void> deleteNetWorthRecord(String id) {
    return _db.collection('net_worth').doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // NET WORTH SPLITS (NEW)
  // ---------------------------------------------------------------------------
  Stream<List<NetWorthSplit>> getNetWorthSplits() {
    return _db
        .collection('net_worth_splits')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NetWorthSplit.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addNetWorthSplit(NetWorthSplit split) {
    return _db.collection('net_worth_splits').add(split.toMap());
  }

  Future<void> deleteNetWorthSplit(String id) {
    return _db.collection('net_worth_splits').doc(id).delete();
  }

  // --- CUSTOM DATA ENTRY ---
  Stream<List<CustomTemplate>> getCustomTemplates() {
    return _db
        .collection('custom_templates')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => CustomTemplate.fromFirestore(d)).toList(),
        );
  }

  Future<void> addCustomTemplate(CustomTemplate template) {
    return _db.collection('custom_templates').add(template.toMap());
  }

  Future<void> updateCustomTemplate(CustomTemplate template) {
    return _db
        .collection('custom_templates')
        .doc(template.id)
        .update(template.toMap());
  }

  Future<void> deleteCustomTemplate(String id) async {
    // Note: In production, you should also delete all records linked to this template
    return _db.collection('custom_templates').doc(id).delete();
  }

  Stream<List<CustomRecord>> getCustomRecords(String templateId) {
    return _db
        .collection('custom_records')
        .where('templateId', isEqualTo: templateId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CustomRecord.fromFirestore(d)).toList());
  }

  Future<void> addCustomRecord(CustomRecord record) {
    return _db.collection('custom_records').add(record.toMap());
  }

  Future<void> deleteCustomRecord(String id) {
    return _db.collection('custom_records').doc(id).delete();
  }
}
