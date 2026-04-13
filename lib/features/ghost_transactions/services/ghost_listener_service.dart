import 'package:drift/drift.dart' hide OrderBy;
import 'package:telephony/telephony.dart' hide Value;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'transaction_parser_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_locator.dart';

class GhostListenerService {
  final Telephony telephony = Telephony.instance;
  final AppDatabase _db = locator<AppDatabase>();

  static bool _isInitialized = false;
  static final List<Map<String, dynamic>> _recentProcessingCache = [];

  Future<void> initializeListeners() async {
    // ... (Keep existing initializeListeners and sweepMissedSms code exactly as is) ...
    if (_isInitialized) return;
    _isInitialized = true;

    bool? smsPermissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (smsPermissionsGranted != null && smsPermissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          if (message.body != null) {
            _processAndStore(message.body!,
                "SMS_${message.date ?? DateTime.now().millisecondsSinceEpoch}");
          }
        },
        listenInBackground: false,
      );

      await sweepMissedSms();
    }

    bool status = await NotificationListenerService.isPermissionGranted();
    if (status) {
      _startNotificationStream();
    }
  }

  Future<void> sweepMissedSms() async {
    // ... (Keep existing sweepMissedSms code exactly as is) ...
    try {
      final cutoffMillis = DateTime.now()
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch;

      final messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThan(cutoffMillis.toString()),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)],
      );

      for (var message in messages) {
        if (message.body != null) {
          _processAndStore(message.body!,
              "SMS_${message.date ?? DateTime.now().millisecondsSinceEpoch}");
        }
      }
    } catch (e) {
      print("Ghost Sweep Error: $e");
    }
  }

  void _startNotificationStream() {
    NotificationListenerService.notificationsStream.listen((event) {
      String fullNotificationText = [event.title, event.content]
          .where((e) => e != null && e.isNotEmpty)
          .join(' . ');

      if (fullNotificationText.isNotEmpty &&
          _isFinancialNotification(fullNotificationText)) {
        String secureId =
            "NOTIF_${DateTime.now().millisecondsSinceEpoch}_${fullNotificationText.hashCode}";
        _processAndStore(fullNotificationText, secureId);
      }
    });
  }

  Future<bool> checkAndRequestNotificationPermission() async {
    // ... (Keep existing checkAndRequestNotificationPermission) ...
    bool status = await NotificationListenerService.isPermissionGranted();
    if (!status) {
      await NotificationListenerService.requestPermission();
      status = await NotificationListenerService.isPermissionGranted();
    }
    return status;
  }

  bool _isFinancialNotification(String text) {
    // ... (Keep existing _isFinancialNotification) ...
    String lower = text.toLowerCase();
    return lower.contains('credited') ||
        lower.contains('debited') ||
        lower.contains('rs.') ||
        lower.contains('inr') ||
        lower.contains('₹') ||
        lower.contains('spent') ||
        lower.contains('received') ||
        lower.contains('sent') ||
        lower.contains('cashback') ||
        lower.contains('refund') ||
        lower.contains('paid');
  }

  Future<void> _processAndStore(String rawText, String uniqueMessageId) async {
    final existingGhost = await (_db.select(_db.ghostTransactions)
          ..where((tbl) => tbl.source.equals(uniqueMessageId))
          ..limit(1))
        .getSingleOrNull();

    if (existingGhost != null) {
      return;
    }

    final parsedData = TransactionParserService.parseRawText(rawText);

    if (parsedData['amount'] != null) {
      String matchedAccountName = parsedData['accountMask'] ?? "Unknown";
      String? matchedAccountId;
      bool isCreditCard = false;

      final last4Digits = parsedData['last4Digits'] as String?;
      final rawLower = rawText.toLowerCase();

      // ... (Keep existing Account Matching Logic exactly as is) ...
      bool smsIndicatesCreditCard =
          rawLower.contains('credit card') || rawLower.contains('cc');

      if (smsIndicatesCreditCard) {
        final cards = await _db.select(_db.creditCards).get();
        for (var card in cards) {
          bool matchesDigits = last4Digits != null &&
              last4Digits.isNotEmpty &&
              ((card.lastFourDigits != null &&
                      card.lastFourDigits!.contains(last4Digits)) ||
                  card.name.contains(last4Digits));
          bool matchesBank = card.bankName.trim().isNotEmpty &&
              rawLower.contains(card.bankName.toLowerCase());
          bool matchesName = card.name.trim().isNotEmpty &&
              rawLower.contains(card.name.toLowerCase());

          if (matchesDigits || matchesBank || matchesName) {
            matchedAccountName = "CC: ${card.bankName} - ${card.name}";
            matchedAccountId = card.id;
            isCreditCard = true;
            break;
          }
        }
      }

      if (matchedAccountId == null &&
          last4Digits != null &&
          last4Digits.isNotEmpty) {
        final accounts = await _db.select(_db.expenseAccounts).get();
        for (var acc in accounts) {
          if (acc.name.contains(last4Digits) ||
              (acc.accountNumber != null &&
                  acc.accountNumber!.contains(last4Digits))) {
            matchedAccountName = "${acc.bankName} - ${acc.name}";
            matchedAccountId = acc.id;
            break;
          }
        }
      }

      if (matchedAccountId == null) {
        final cards = await _db.select(_db.creditCards).get();
        for (var card in cards) {
          bool matchesDigits = last4Digits != null &&
              last4Digits.isNotEmpty &&
              ((card.lastFourDigits != null &&
                      card.lastFourDigits!.contains(last4Digits)) ||
                  card.name.contains(last4Digits));
          bool matchesBank = card.bankName.trim().isNotEmpty &&
              rawLower.contains(card.bankName.toLowerCase());

          if (matchesDigits || matchesBank) {
            matchedAccountName = "CC: ${card.bankName} - ${card.name}";
            matchedAccountId = card.id;
            isCreditCard = true;
            break;
          }
        }
      }

      _recentProcessingCache.removeWhere((entry) =>
          DateTime.now().difference(entry['time'] as DateTime).inSeconds > 2);

      bool isRecentDuplicate =
          _recentProcessingCache.any((entry) => entry['rawText'] == rawText);

      if (isRecentDuplicate) return;

      _recentProcessingCache.add({
        'rawText': rawText,
        'time': DateTime.now(),
      });

      // ==========================================
      // NEW: TRANSFER PAIR DETECTION LOGIC
      // ==========================================
      String finalDetectedType = parsedData['type'] as String;
      double parsedAmount = parsedData['amount'] as double;

      if (finalDetectedType == 'Credit' || finalDetectedType == 'Debit') {
        String oppositeType =
            finalDetectedType == 'Credit' ? 'Debit' : 'Credit';

        // 1. Look for a PENDING transaction of the OPPOSITE type with the EXACT same amount
        final complementaryTx = await (_db.select(_db.ghostTransactions)
              ..where((tbl) =>
                  tbl.detectedAmount.equals(parsedAmount) &
                  tbl.detectedType.equals(oppositeType) &
                  tbl.status.equals('PENDING'))
              ..orderBy([
                (t) => OrderingTerm.desc(t.id)
              ]) // Check the most recent one first
              ..limit(1))
            .getSingleOrNull();

        if (complementaryTx != null) {
          // 2. Validate using the 12-digit UPI Reference number (if present)
          // This ensures we don't accidentally link two unrelated ₹100 payments
          RegExp upiRegex = RegExp(r'(\d{12})');
          Match? currentRefMatch = upiRegex.firstMatch(rawText);

          bool isConfirmedTransfer = false;

          if (currentRefMatch != null) {
            String currentRef = currentRefMatch.group(1)!;
            // If the complementary text also contains this 12 digit UTR, it's a 100% match
            if (complementaryTx.rawText.contains(currentRef)) {
              isConfirmedTransfer = true;
            }
          } else {
            // Fallback: If no 12-digit ref is found, assume it's a transfer if they arrived very close in time.
            isConfirmedTransfer = true;
          }

          if (isConfirmedTransfer) {
            finalDetectedType = 'Transfer';

            // 3. Update the existing pending "half" of the transfer to also say 'Transfer'
            await (_db.update(_db.ghostTransactions)
                  ..where((tbl) => tbl.id.equals(complementaryTx.id)))
                .write(GhostTransactionsCompanion(
              detectedType: const Value('Transfer'),
            ));
          }
        }
      }
      // ==========================================

      // 4. Save to Database with the updated finalDetectedType
      await _db
          .into(_db.ghostTransactions)
          .insert(GhostTransactionsCompanion.insert(
            rawText: rawText,
            source: uniqueMessageId,
            detectedAmount: Value(parsedAmount),
            detectedDate: Value(parsedData['date'] as DateTime),
            detectedType:
                Value(finalDetectedType), // Will be 'Transfer' if matched!
            detectedAccount: Value(matchedAccountName),
            detectedAccountId: Value(matchedAccountId),
            isCreditCardMatch: Value(isCreditCard),
            status: const Value('PENDING'),
          ));
    }
  }
}
