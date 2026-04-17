import 'package:intl/intl.dart';

class TransactionParserService {
  // ============================================================================
  // [UPDATED] HEURISTIC CONFIDENCE SCORING ENGINE
  // Fixed "The Wonderla Bug" using Regex Word Boundaries and added CC Limits
  // ============================================================================
  static int _calculateConfidenceScore(String text, bool hasAmount, String type,
      bool hasAccountMask, bool hasRefNumber) {
    int score = 0;
    String lower = text.toLowerCase();

    // 1. Base Requirements
    if (hasAmount) score += 1;
    if (type != 'Unknown') score += 1;

    // 2. Structural Density
    if (hasAccountMask) score += 2;
    if (hasRefNumber) score += 2;

    // [FIXED] Added 'limit' and 'avl' to correctly score Credit Card messages
    if (lower.contains('bal') ||
        lower.contains('balance') ||
        lower.contains('limit') ||
        lower.contains('avl')) {
      score += 2;
    }

    // 3. Spam Penalties [FIXED]
    final List<String> exactWordSpam = [
      "deal",
      "offer",
      "discount",
      "coupon",
      "sale",
      "voucher",
      "win",
      "won",
      "jackpot",
      "hurry",
      "cart"
    ];
    final List<String> phraseSpam = [
      "from just",
      "shop top",
      "flat off",
      "% off",
      "grab now",
      "apply code"
    ];

    // Check exact standalone words (prevents "wonderla" from triggering "won")
    for (var word in exactWordSpam) {
      if (RegExp(r'\b' + word + r'\b').hasMatch(lower)) {
        score -= 10;
      }
    }

    // Check phrases normally
    for (var phrase in phraseSpam) {
      if (lower.contains(phrase)) {
        score -= 10;
      }
    }

    return score;
  }

  /// Parses transaction details from a raw string.
  static Map<String, dynamic>? parseRawText(String text) {
    String lowerText = text.toLowerCase();

    // 1. Detect Type
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

    // 2. Detect Amount
    double? amount;
    RegExp amountRegex = RegExp(
        r'(?:₹|rs\.?|inr|amount)\s*([0-9]+(?:,[0-9]+)*(?:\.[0-9]+)?)',
        caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(text);

    if (amountMatch != null) {
      String amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }

    // 3. Detect Account/Card
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

    // 4. Detect Reference / UPI Number
    String? referenceNumber;
    RegExp refRegex = RegExp(r'(?:ref|upi|utr|txn)[^\d]*(\d{12}|\d{9,18})',
        caseSensitive: false);
    Match? refMatch = refRegex.firstMatch(text);
    if (refMatch != null) {
      referenceNumber = refMatch.group(1);
    } else {
      RegExp standaloneUpi = RegExp(r'\b(\d{12})\b');
      Match? upiMatch = standaloneUpi.firstMatch(text);
      if (upiMatch != null) {
        referenceNumber = upiMatch.group(1);
      }
    }

    // 5. Detect Date
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
        // Safe fallback
      }
    }
    date ??= DateTime.now();

    // ============================================================================
    // EXECUTE CONFIDENCE GATEKEEPER
    // ============================================================================
    int score = _calculateConfidenceScore(text, amount != null, type,
        accountMask != null, referenceNumber != null);

    if (score < 4) {
      return null; // Reject message
    }

    return {
      'type': type,
      'amount': amount,
      'accountMask': accountMask,
      'last4Digits': last4Digits,
      'referenceNumber': referenceNumber,
      'date': date,
    };
  }
}
