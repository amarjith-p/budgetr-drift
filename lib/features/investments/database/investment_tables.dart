import 'package:drift/drift.dart';

@DataClassName('Investment')
class Investments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Store as string: 'Mutual Fund', 'Stocks', 'FD', 'RD', 'Savings', 'Others'
  TextColumn get type => text()();
  TextColumn get subType => text().nullable()(); // For 'Others' input
  TextColumn get providerName => text()();
  TextColumn get providerWebsite => text().nullable()(); // For favicon
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  RealColumn get expectedReturn => real().nullable()(); // In percentage
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Additional Info
  TextColumn get folioNumber => text().nullable()();
  TextColumn get units => text().nullable()();
  TextColumn get brokerName => text().nullable()();
  TextColumn get linkedBankName => text().nullable()();
  TextColumn get linkedBankAccount => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get targetAmount => real().nullable()();
  // [NEW] Special ID for filtering
  TextColumn get specialId => text().nullable()();
}

@DataClassName('InvestmentTransaction')
class InvestmentTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get investmentId => integer().references(Investments, #id)();
  DateTimeColumn get transactionDate => dateTime()();

  // 'invested', 'withdrawn', 'valueUpdate'
  TextColumn get transactionType => text()();

  // Amount added/removed from user's pocket
  RealColumn get amountInvested => real().withDefault(const Constant(0.0))();

  // The total value of the investment at this specific time
  RealColumn get currentValueSnapshot => real()();

  // Snapshot of Gain/Loss at this specific time
  RealColumn get calculatedGainLoss =>
      real().withDefault(const Constant(0.0))();
}
