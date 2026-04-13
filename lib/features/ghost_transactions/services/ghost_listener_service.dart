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
      if (event.content != null && _isFinancialNotification(event.content!)) {
        _processAndStore(event.content!,
            "NOTIF_${event.id ?? DateTime.now().millisecondsSinceEpoch}");
      }
    });
  }

  Future<bool> checkAndRequestNotificationPermission() async {
    bool status = await NotificationListenerService.isPermissionGranted();
    if (!status) {
      await NotificationListenerService.requestPermission();
      status = await NotificationListenerService.isPermissionGranted();
    }
    return status;
  }

  bool _isFinancialNotification(String text) {
    String lower = text.toLowerCase();
    return lower.contains('credited') ||
        lower.contains('debited') ||
        lower.contains('rs.') ||
        lower.contains('inr') ||
        lower.contains('spent');
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
          DateTime.now().difference(entry['time'] as DateTime).inSeconds > 15);

      String txSignature =
          "${parsedData['amount']}_${parsedData['type']}_$matchedAccountName";

      bool isRecentDuplicate = _recentProcessingCache.any((entry) =>
          entry['signature'] == txSignature || entry['rawText'] == rawText);

      if (isRecentDuplicate) return;

      _recentProcessingCache.add({
        'signature': txSignature,
        'rawText': rawText,
        'time': DateTime.now(),
      });

      // --- FIX: REMOVED 'drift.' FROM ALL OF THESE ---
      // 3. Save to Database
      await _db
          .into(_db.ghostTransactions)
          .insert(GhostTransactionsCompanion.insert(
            rawText: rawText,
            source:
                uniqueMessageId, // <-- THE FIX: Removed Value() wrapper here
            detectedAmount: Value(parsedData['amount'] as double),
            detectedDate: Value(parsedData['date'] as DateTime),
            detectedType: Value(parsedData['type'] as String),
            detectedAccount: Value(matchedAccountName),
            detectedAccountId: Value(matchedAccountId),
            isCreditCardMatch: Value(isCreditCard),
            status: const Value('PENDING'),
          ));
    }
  }
}
