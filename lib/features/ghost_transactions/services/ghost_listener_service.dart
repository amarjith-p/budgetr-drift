import 'package:drift/drift.dart' hide OrderBy;
import 'package:telephony/telephony.dart' hide Value;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'transaction_parser_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_locator.dart';

class GhostListenerService {
  final Telephony telephony = Telephony.instance;
  final AppDatabase _db = locator<AppDatabase>();
  static const MethodChannel _settingsChannel =
      MethodChannel('com.amarjith.budgetr/settings');

  static bool _isInitialized = false;
  static final List<Map<String, dynamic>> _recentProcessingCache = [];

  Future<void> initializeListeners() async {
    if (_isInitialized) return;
    _isInitialized = true;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (statuses[Permission.sms]!.isGranted) {
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
      // ============================================================================
      // [UPDATED] OS-LEVEL IGNORE LIST & NATIVE SMS EXCLUSION
      // WhatsApp is explicitly ALLOWED to pass through because banks send alerts there.
      // Personal WhatsApp chats will be filtered out downstream by the Confidence Engine.
      //
      // [NEW]: We now EXCLUDE native SMS apps (messaging, mms) to prevent duplicate
      // entries since the dedicated SMS listener already handles them natively.
      // ============================================================================
      if (event.packageName != null &&
          (event.packageName!.contains('telegram') ||
              event.packageName!.contains('instagram') ||
              event.packageName!.contains('facebook') ||
              event.packageName!.contains('snapchat') ||
              event.packageName!
                  .contains('messaging') || // Google & Samsung Messages
              event.packageName!.contains('mms')))
        return; // Generic/Native MMS apps

      String fullNotificationText = [event.title, event.content]
          .where((e) => e != null && e.isNotEmpty)
          .join(' . ');

      if (fullNotificationText.isNotEmpty) {
        String secureId =
            "NOTIF_${DateTime.now().millisecondsSinceEpoch}_${fullNotificationText.hashCode}";
        _processAndStore(fullNotificationText, secureId);
      }
    });
  }

  Future<bool> checkAndRequestNotificationPermission() async {
    bool status = await NotificationListenerService.isPermissionGranted();
    if (!status) {
      try {
        await _settingsChannel.invokeMethod('openNotificationListenerSettings');
      } catch (e) {
        print("Could not open settings: $e");
      }
    }
    return status;
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

    // If parsedData is null, the Confidence Gatekeeper rejected it as spam/personal chat.
    if (parsedData == null || parsedData['amount'] == null) {
      return;
    }

    String matchedAccountName = parsedData['accountMask'] ?? "Unknown";
    String? matchedAccountId;
    bool isCreditCard = false;

    final last4Digits = parsedData['last4Digits'] as String?;
    final rawLower = rawText.toLowerCase();

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

    String finalDetectedType = parsedData['type'] as String;
    double parsedAmount = parsedData['amount'] as double;
    DateTime parsedDate = parsedData['date'] as DateTime;
    String? refNumber = parsedData['referenceNumber'] as String?;

    // ============================================================================
    // AGGRESSIVE SEMANTIC DEDUPLICATION
    // Solves the multi-channel issue (e.g., catching SMS and GPay at the same time).
    // Checks a 10-minute window for identical amounts AND directions.
    // ============================================================================
    final searchWindowStart = parsedDate.subtract(const Duration(minutes: 10));
    final searchWindowEnd = parsedDate.add(const Duration(minutes: 10));

    final possibleDuplicates = await (_db.select(_db.ghostTransactions)
          ..where((tbl) =>
              tbl.detectedAmount.equals(parsedAmount) &
              tbl.detectedType.equals(finalDetectedType) &
              tbl.detectedDate
                  .isBetweenValues(searchWindowStart, searchWindowEnd)))
        .get();

    if (possibleDuplicates.isNotEmpty) {
      bool isDuplicate = false;
      for (var duplicate in possibleDuplicates) {
        // Condition A: If they share the same UPI/Ref Number, it's 100% a duplicate
        if (refNumber != null && duplicate.rawText.contains(refNumber)) {
          isDuplicate = true;
          break;
        }
        // Condition B: Same exact amount and direction within 2 minutes is almost certainly a duplicate (SMS vs Push latency)
        if (duplicate.detectedDate != null &&
            parsedDate.difference(duplicate.detectedDate!).abs().inMinutes <=
                2) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        return; // Drop this entry silently
      }
    }
    // ============================================================================

    // Run complementary Transfer Check (Your existing untouched logic)
    if (finalDetectedType == 'Credit' || finalDetectedType == 'Debit') {
      String oppositeType = finalDetectedType == 'Credit' ? 'Debit' : 'Credit';

      final complementaryTx = await (_db.select(_db.ghostTransactions)
            ..where((tbl) =>
                tbl.detectedAmount.equals(parsedAmount) &
                tbl.detectedType.equals(oppositeType) &
                tbl.status.equals('PENDING'))
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();

      if (complementaryTx != null) {
        bool isConfirmedTransfer = false;

        if (refNumber != null) {
          if (complementaryTx.rawText.contains(refNumber)) {
            isConfirmedTransfer = true;
          }
        } else {
          isConfirmedTransfer = true;
        }

        if (isConfirmedTransfer) {
          finalDetectedType = 'Transfer';

          await (_db.update(_db.ghostTransactions)
                ..where((tbl) => tbl.id.equals(complementaryTx.id)))
              .write(GhostTransactionsCompanion(
            detectedType: const Value('Transfer'),
          ));
        }
      }
    }

    await _db
        .into(_db.ghostTransactions)
        .insert(GhostTransactionsCompanion.insert(
          rawText: rawText,
          source: uniqueMessageId,
          detectedAmount: Value(parsedAmount),
          detectedDate: Value(parsedDate),
          detectedType: Value(finalDetectedType),
          detectedAccount: Value(matchedAccountName),
          detectedAccountId: Value(matchedAccountId),
          isCreditCardMatch: Value(isCreditCard),
          status: const Value('PENDING'),
        ));
  }
}
