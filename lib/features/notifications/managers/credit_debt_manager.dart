import 'package:budget/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../credit_tracker/models/credit_models.dart';
import '../services/notification_service.dart';
import '../services/notification_channels.dart';

class CreditDebtManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Uses ID range 2000-2999

  Future<void> syncCreditReminders(bool isEnabled) async {
    final service = NotificationService();

    // Fetch all cards
    final snapshot = await _db.collection(FirebaseConstants.creditCards).get();
    final cards =
        snapshot.docs.map((doc) => CreditCardModel.fromFirestore(doc)).toList();

    for (var card in cards) {
      // Unique IDs for this card
      final int billGenId = 2000 + card.name.hashCode % 500;
      final int dueDateId = 2500 + card.name.hashCode % 500;

      // Clear existing
      await service.cancel(billGenId);
      await service.cancel(dueDateId);

      if (!isEnabled || card.isArchived) continue;

      // 1. Schedule Statement Generation Reminder
      final billDate = _getNextInstanceOfDay(card.billDate);
      await service.scheduleNotification(
        id: billGenId,
        title: 'Statement Generated: ${card.name}',
        body: 'Your statement should be generated today. Verify amount.',
        scheduledDate: billDate,
        channelId: NotificationChannels.creditAlerts,
      );

      // 2. Schedule Due Date Reminder (1 day before)
      var dueDate = _getNextInstanceOfDay(card.dueDate);
      // Remind 1 day before due date
      dueDate = dueDate.subtract(const Duration(days: 1));

      await service.scheduleNotification(
        id: dueDateId,
        title: 'Payment Due Tomorrow: ${card.name}',
        body: 'Avoid interest charges. Ensure payment is settled.',
        scheduledDate: dueDate,
        channelId: NotificationChannels.creditAlerts,
      );
    }
  }

  tz.TZDateTime _getNextInstanceOfDay(int dayOfMonth) {
    final now = tz.TZDateTime.now(tz.local);
    // Handle edge cases like February 30th -> defaults to last day of month logic if needed
    // simpler approach for MVP:

    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, dayOfMonth, 9, 0); // 9 AM

    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month + 1, dayOfMonth, 9, 0);
    }
    return scheduledDate;
  }
}
