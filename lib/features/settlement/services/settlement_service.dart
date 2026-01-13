// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/firebase_constants.dart';
// import '../../../core/models/financial_record_model.dart';
// import '../../../core/models/settlement_model.dart';

// class SettlementService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
//     // Queries financial records to see which months exist
//     final snapshot = await _db
//         .collection(FirebaseConstants.financialRecords)
//         .get();
//     final uniqueMonths = <String, Map<String, int>>{};

//     for (var doc in snapshot.docs) {
//       final record = FinancialRecord.fromFirestore(doc);
//       uniqueMonths[record.id] = {'year': record.year, 'month': record.month};
//     }

//     var sortedList = uniqueMonths.values.toList();
//     sortedList.sort((a, b) {
//       final yearA = a['year']!;
//       final monthA = a['month']!;
//       final yearB = b['year']!;
//       final monthB = b['month']!;
//       if (yearB.compareTo(yearA) != 0) {
//         return yearB.compareTo(yearA);
//       }
//       return monthB.compareTo(monthA);
//     });

//     return sortedList;
//   }

//   Future<Settlement?> getSettlementById(String id) async {
//     final doc = await _db
//         .collection(FirebaseConstants.settlements)
//         .doc(id)
//         .get();
//     if (doc.exists) {
//       return Settlement.fromFirestore(doc);
//     }
//     return null;
//   }

//   /// NEW: Checks if a specific month is already settled
//   Future<bool> isMonthSettled(int year, int month) async {
//     final id = '$year${month.toString().padLeft(2, '0')}';
//     final doc = await _db
//         .collection(FirebaseConstants.settlements)
//         .doc(id)
//         .get();
//     return doc.exists;
//   }

//   Future<void> saveSettlement(Settlement settlement) {
//     return _db
//         .collection(FirebaseConstants.settlements)
//         .doc(settlement.id)
//         .set(settlement.toMap());
//   }
// }
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/settlement_model.dart';

class SettlementService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
    final records = await _db.select(_db.financialRecords).get();
    final uniqueMonths = <String, Map<String, int>>{};

    for (var row in records) {
      final key = '${row.year}-${row.month}';
      uniqueMonths[key] = {'year': row.year, 'month': row.month};
    }

    var sortedList = uniqueMonths.values.toList();
    sortedList.sort((a, b) {
      if (b['year']! != a['year']!) return b['year']!.compareTo(a['year']!);
      return b['month']!.compareTo(a['month']!);
    });
    return sortedList;
  }

  Future<Settlement?> getSettlementById(String id) async {
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row != null) {
      return Settlement(
        id: row.id,
        year: row.year,
        month: row.month,
        settledAt: row.settledAt,
        data: jsonDecode(row.data),
      );
    }
    return null;
  }

  // Missing Method Fix
  Future<bool> isMonthSettled(int year, int month) async {
    final id = '$year${month.toString().padLeft(2, '0')}';
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> saveSettlement(Settlement settlement) async {
    await _db
        .into(_db.settlements)
        .insertOnConflictUpdate(SettlementsCompanion.insert(
          id: settlement.id,
          year: settlement.year,
          month: settlement.month,
          settledAt: settlement.settledAt,
          data: jsonEncode(settlement.data),
        ));
  }
}
