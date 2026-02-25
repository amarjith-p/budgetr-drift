class InvestmentLogDto {
  final int id;
  final int investmentId;
  final DateTime date;
  final String type; // 'invested' or 'valueUpdate'
  final double amountInvested;
  final double currentValue;
  final double gainLoss;

  InvestmentLogDto({
    required this.id,
    required this.investmentId,
    required this.date,
    required this.type,
    required this.amountInvested,
    required this.currentValue,
    required this.gainLoss,
  });
}
