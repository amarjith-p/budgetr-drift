class BankConstants {
  static const List<String> indianBanks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'IndusInd Bank',
    'Yes Bank',
    'IDFC FIRST Bank',
    'Canara Bank',
    'Union Bank of India',
    'Standard Chartered',
    'American Express',
    'Citi Bank',
    'HSBC',
    'RBL Bank',
    'Federal Bank',
    'IDBI Bank',
    'UCO Bank',
    'AU Bank',
    'ESAF Small Finance Bank',
    'Bandhan Bank',
    'South Indian Bank',
    'DBS Bank',
    'Punjab and Sind Bank',
    'Indian Bank',
    'Bank of India',
    'Central Bank of India',
    'Bank of Maharashtra',
    'Indian Overseas Bank',
    'Others',
  ];

  // [NEW] Added Wallet List
  static const List<String> wallets = [
    'PayTM',
    'Amazon Pay',
    'Samsung Wallet',
    'Mobikwik',
    'PhonePe',
    'Others',
  ];

  // Helper to get asset path
  // Updates: Removes spaces and special characters to match filenames like 'hdfcbank.png'
  static String getBankLogoPath(String bankName) {
    if (bankName.isEmpty) return '';
    // "HDFC Bank" -> "hdfcbank"
    // "ICICI Bank" -> "icicibank"
    final formatted = bankName
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
    return 'assets/banks/$formatted.png';
  }

  static String getBankInitials(String bankName) {
    if (bankName.isEmpty) return 'BK';
    var parts = bankName.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return bankName.substring(0, 2).toUpperCase();
  }
}
