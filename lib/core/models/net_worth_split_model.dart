class NetWorthSplitModel {
  final String id;
  final DateTime date;

  // Assets
  final double bankAccounts;
  final double cashInHand;
  final double mutualFunds;
  final double equity;
  final double bonds;
  final double deposits;
  final double realEstate;
  final double otherAssets;
  final String? assetNotes;

  // Liabilities
  final double loans;
  final double creditCardOutstanding;
  final double otherDebts;
  final String? liabilityNotes;

  // Cashflows
  final double budgetedIncome;
  final double budgetedExpense;
  final double nonCalcIncome;
  final double nonCalcExpense;
  final double outOfBucketExpense;

  NetWorthSplitModel({
    required this.id,
    required this.date,
    this.bankAccounts = 0,
    this.cashInHand = 0,
    this.mutualFunds = 0,
    this.equity = 0,
    this.bonds = 0,
    this.deposits = 0,
    this.realEstate = 0,
    this.otherAssets = 0,
    this.assetNotes,
    this.loans = 0,
    this.creditCardOutstanding = 0,
    this.otherDebts = 0,
    this.liabilityNotes,
    this.budgetedIncome = 0,
    this.budgetedExpense = 0,
    this.nonCalcIncome = 0,
    this.nonCalcExpense = 0,
    this.outOfBucketExpense = 0,
  });

  // Computed Getters
  double get totalAssets =>
      bankAccounts +
      cashInHand +
      mutualFunds +
      equity +
      bonds +
      deposits +
      realEstate +
      otherAssets;

  double get totalLiabilities => loans + creditCardOutstanding + otherDebts;

  double get netWorth => totalAssets - totalLiabilities;
}
