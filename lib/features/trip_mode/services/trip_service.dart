import 'package:drift/drift.dart' as drift;
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/app_database.dart';

class TripTransactionDto {
  final String id;
  final double amount;
  final DateTime date;
  final String type;
  final String category;
  final String subCategory;
  final String notes;
  final String source; // 'Bank' or 'Credit'
  final String sourceId; // accountId or cardId

  TripTransactionDto({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.notes,
    required this.source,
    required this.sourceId,
  });
}

class TripService {
  final AppDatabase _db = GetIt.I<AppDatabase>();
  final _uuid = const Uuid();

  // --- Core Actions ---

  Future<void> startTrip(String name, double? budget) async {
    final active = await getActiveTripFuture();
    if (active != null) throw Exception("A trip is already active.");

    await _db.into(_db.tripRecords).insert(
          TripRecordsCompanion.insert(
            id: _uuid.v4(),
            tripName: name,
            budget: drift.Value(budget),
            startDate: DateTime.now(),
            isActive: const drift.Value(true),
          ),
        );
  }

  Future<void> endTrip(String tripId) async {
    await (_db.update(_db.tripRecords)..where((t) => t.id.equals(tripId)))
        .write(
      TripRecordsCompanion(
        endDate: drift.Value(DateTime.now()),
        isActive: const drift.Value(false),
      ),
    );
  }

  Future<void> excludeTransaction(String tripId, String transactionId) async {
    await _db.into(_db.tripExclusions).insert(
          TripExclusionsCompanion.insert(
            tripId: tripId,
            transactionId: transactionId,
          ),
        );
  }

  Future<void> deleteTrip(String tripId) async {
    await (_db.delete(_db.tripExclusions)
          ..where((e) => e.tripId.equals(tripId)))
        .go();
    await (_db.delete(_db.tripRecords)..where((t) => t.id.equals(tripId))).go();
  }

  // --- Queries & Streams ---

  Stream<TripRecord?> getActiveTrip() {
    return (_db.select(_db.tripRecords)..where((t) => t.isActive.equals(true)))
        .watchSingleOrNull();
  }

  Future<TripRecord?> getActiveTripFuture() {
    return (_db.select(_db.tripRecords)..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  Stream<List<TripRecord>> getCompletedTrips() {
    return (_db.select(_db.tripRecords)
          ..where((t) => t.isActive.equals(false))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  Stream<List<TripTransactionDto>> getTripTransactions(TripRecord trip) {
    final endDate = trip.endDate ?? DateTime.now();

    final expenseStream = (_db.select(_db.expenseTransactions)
          ..where((t) => t.date.isBetweenValues(trip.startDate, endDate)))
        .watch();

    final creditStream = (_db.select(_db.creditTransactions)
          ..where((t) => t.date.isBetweenValues(trip.startDate, endDate)))
        .watch();

    final exclusionStream = (_db.select(_db.tripExclusions)
          ..where((e) => e.tripId.equals(trip.id)))
        .watch();

    return Rx.combineLatest3(
      expenseStream,
      creditStream,
      exclusionStream,
      (expenses, credits, exclusions) {
        final excludedIds = exclusions.map((e) => e.transactionId).toSet();
        final List<TripTransactionDto> combined = [];

        for (var e in expenses) {
          // [FIX]: Prevent Double Entry!
          // If this expense is linked to a Credit Card, we skip it here.
          // The system will automatically add the matching CreditTransaction in the loop below.
          if (e.linkedCreditCardId != null &&
              e.linkedCreditCardId!.isNotEmpty) {
            continue;
          }

          if (!excludedIds.contains(e.id)) {
            combined.add(TripTransactionDto(
              id: e.id,
              amount: e.amount,
              date: e.date,
              type: e.type,
              category: e.category,
              subCategory: e.subCategory ?? '',
              notes: e.notes ?? '',
              source: 'Bank',
              sourceId: e.accountId ?? '',
            ));
          }
        }

        for (var c in credits) {
          if (!excludedIds.contains(c.id)) {
            combined.add(TripTransactionDto(
              id: c.id,
              amount: c.amount,
              date: c.date,
              type: c.type,
              category: c.category,
              subCategory: c.subCategory ?? '',
              notes: c.notes ?? '',
              source: 'Credit',
              sourceId: c.cardId,
            ));
          }
        }

        // Sort by newest date first
        combined.sort((a, b) => b.date.compareTo(a.date));
        return combined;
      },
    );
  }
}
