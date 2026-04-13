import 'package:intl/intl.dart';

class TransactionParserService {
  /// Parses transaction details from a raw string.
  /// NOTE: For push notifications, remember to pass the concatenated
  /// string (e.g., parseRawText('${notification.title} . ${notification.body}'))
  static Map<String, dynamic> parseRawText(String text) {
    String lowerText = text.toLowerCase();

    // 1. Detect Type (Expanded for UPI and Wallets)
    String type = 'Unknown';
    if (lowerText.contains('credited') ||
        lowerText.contains('received') ||
        lowerText.contains('deposited') ||
        lowerText.contains('cashback') ||
        lowerText.contains('refund')) {
      type = 'Credit';
    } else if (lowerText.contains('spent') ||
        lowerText.contains('sent') ||
        lowerText.contains('debited') ||
        lowerText.contains('paid')) {
      type = 'Debit';
    }

    // 2. Detect Amount (Upgraded to handle ₹, Rs, INR, and complex comma placement)
    double? amount;
    RegExp amountRegex = RegExp(
        r'(?:₹|rs\.?|inr|amount)\s*([0-9]+(?:,[0-9]+)*(?:\.[0-9]+)?)',
        caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(text);

    if (amountMatch != null) {
      // Remove commas before parsing to double to prevent FormatExceptions
      String amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }

    // 3. Detect Account/Card (Upgraded to catch "from xx3302" push notification structures)
    String? accountMask;
    String? last4Digits;

    RegExp accountRegex = RegExp(
        r'(?:a/c|ac|account|card|from|to)\s*(?:no\.?\s*)?(?:[xX*\-]+)?([0-9]{3,6})|\(([0-9]{4})\)',
        caseSensitive: false);
    Match? accountMatch = accountRegex.firstMatch(text);

    if (accountMatch != null) {
      last4Digits = accountMatch.group(1) ?? accountMatch.group(2);
      accountMask = accountMatch.group(0);
    }

    // 4. Detect Date (Retained your existing robust implementation)
    DateTime? date;
    RegExp dateRegex =
        RegExp(r'(\d{2}[-/]\d{2}[-/]\d{2,4}|\d{2}-[a-zA-Z]{3}-\d{2,4})');
    Match? dateMatch = dateRegex.firstMatch(text);

    if (dateMatch != null) {
      String dateStr = dateMatch.group(1)!;
      try {
        if (dateStr.contains('-')) {
          if (dateStr.length == 10) {
            date = DateFormat("dd-MM-yyyy").parse(dateStr);
          } else if (dateStr.length == 8) {
            date = DateFormat("dd-MM-yy").parse(dateStr);
          } else if (dateStr.contains(RegExp(r'[a-zA-Z]'))) {
            date = DateFormat("dd-MMM-yy").parse(dateStr);
          }
        } else if (dateStr.contains('/')) {
          if (dateStr.length == 10) {
            date = DateFormat("dd/MM/yyyy").parse(dateStr);
          } else if (dateStr.length == 8) {
            date = DateFormat("dd/MM/yy").parse(dateStr);
          }
        }
      } catch (e) {
        // Safe fallback caught below
      }
    }

    // Push notifications rarely contain inline dates.
    // Fall back to the system's current time if no explicit date string is found.
    date ??= DateTime.now();

    return {
      'type': type,
      'amount': amount,
      'accountMask': accountMask,
      'last4Digits': last4Digits,
      'date': date,
    };
  }
}
