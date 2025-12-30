import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/models/settlement_model.dart';

class SettlementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
    // Queries financial records to see which months exist
    final snapshot = await _db
        .collection(FirebaseConstants.financialRecords)
        .get();
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
    final doc = await _db
        .collection(FirebaseConstants.settlements)
        .doc(id)
        .get();
    if (doc.exists) {
      return Settlement.fromFirestore(doc);
    }
    return null;
  }

  /// NEW: Checks if a specific month is already settled
  Future<bool> isMonthSettled(int year, int month) async {
    final id = '$year${month.toString().padLeft(2, '0')}';
    final doc = await _db
        .collection(FirebaseConstants.settlements)
        .doc(id)
        .get();
    return doc.exists;
  }

  Future<void> saveSettlement(Settlement settlement) {
    return _db
        .collection(FirebaseConstants.settlements)
        .doc(settlement.id)
        .set(settlement.toMap());
  }
}
