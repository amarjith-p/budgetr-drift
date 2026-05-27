import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/balance_sheet_model.dart';
import 'balance_sheet_notification_scheduler.dart'; // [NEW IMPORT]

class BalanceSheetService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // [NEW] Instance of our intelligent scheduler
  final _scheduler = BalanceSheetNotificationScheduler();

  BalanceSheetModel _mapEntry(db.BalanceSheetEntry row) {
    return BalanceSheetModel(
      id: row.id,
      title: row.title,
      amount: row.amount,
      entryType: row.entryType,
      category: row.category,
      date: row.date,
      notes: row.notes,
      contactName: row.contactName,
      dueDate: row.dueDate,
      isSettled: row.isSettled,
      settledAmount: row.settledAmount,
      isForgiven: row.isForgiven, // [NEW] Map value
      isReconciled: row.isReconciled,
    );
  }

  Stream<List<BalanceSheetModel>> watchAssets() {
    return (_db.select(_db.balanceSheetEntries)
          ..where((t) => t.entryType.equals('ASSET'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isSettled, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  Stream<List<BalanceSheetModel>> watchLiabilities() {
    return (_db.select(_db.balanceSheetEntries)
          ..where((t) => t.entryType.equals('LIABILITY'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isSettled, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  Stream<List<BalanceSheetModel>> watchContactEntries(String contactName) {
    return (_db.select(_db.balanceSheetEntries)
          ..where((t) => t.contactName.equals(contactName))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isSettled, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  Future<List<BalanceSheetModel>> fetchAllEntries() async {
    final rows = await (_db.select(_db.balanceSheetEntries)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isSettled, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_mapEntry).toList();
  }

  Future<void> addEntry(BalanceSheetModel entry) async {
    await _db.into(_db.balanceSheetEntries).insert(
          db.BalanceSheetEntriesCompanion.insert(
            id: entry.id.isEmpty ? _uuid.v4() : entry.id,
            title: entry.title,
            amount: entry.amount,
            entryType: entry.entryType,
            category: entry.category,
            date: entry.date,
            notes: Value(entry.notes),
            contactName: Value(entry.contactName),
            dueDate: Value(entry.dueDate),
            isSettled: Value(entry.isSettled),
            settledAmount: Value(entry.settledAmount),
            isForgiven: Value(entry.isForgiven), // [NEW]
            isReconciled: Value(entry.isReconciled),
          ),
        );
    _triggerNotificationSync();
  }

  Future<void> updateEntry(BalanceSheetModel entry) async {
    await (_db.update(_db.balanceSheetEntries)
          ..where((t) => t.id.equals(entry.id)))
        .write(db.BalanceSheetEntriesCompanion(
      title: Value(entry.title),
      amount: Value(entry.amount),
      category: Value(entry.category),
      date: Value(entry.date),
      notes: Value(entry.notes),
      contactName: Value(entry.contactName),
      dueDate: Value(entry.dueDate),
      isSettled: Value(entry.isSettled),
      settledAmount: Value(entry.settledAmount),
      isForgiven: Value(entry.isForgiven), // [NEW]
      isReconciled: Value(entry.isReconciled),
    ));
    _triggerNotificationSync();
  }

  Future<void> deleteEntry(String id) async {
    await (_db.delete(_db.balanceSheetEntries)..where((t) => t.id.equals(id)))
        .go();

    // [NEW HOOK] Resync alarms after delete to wipe pending triggers
    _triggerNotificationSync();
  }

  Future<void> updateSettlement(
      String id, double newSettledAmount, bool isSettled) async {
    await (_db.update(_db.balanceSheetEntries)..where((t) => t.id.equals(id)))
        .write(db.BalanceSheetEntriesCompanion(
      settledAmount: Value(newSettledAmount),
      isSettled: Value(isSettled),
    ));

    // [NEW HOOK] Resync alarms if an item is fully paid off
    _triggerNotificationSync();
  }

  // --- [NEW] Private method to fetch all items and hand them to the scheduler ---
  Future<void> _triggerNotificationSync() async {
    final allEntries = await fetchAllEntries();
    await _scheduler.syncNotifications(allEntries);
  }
  Future<void> updateForgiven(String id, bool isForgiven) async {
    await (_db.update(_db.balanceSheetEntries)..where((t) => t.id.equals(id)))
        .write(db.BalanceSheetEntriesCompanion(
      isForgiven: Value(isForgiven),
    ));
    _triggerNotificationSync();
  }
  Future<void> updateReconciled(String id, bool isReconciled) async {
    await (_db.update(_db.balanceSheetEntries)..where((t) => t.id.equals(id)))
        .write(db.BalanceSheetEntriesCompanion(
      isReconciled: Value(isReconciled),
    ));
    _triggerNotificationSync();
  }
}
