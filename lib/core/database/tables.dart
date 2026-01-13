import 'package:drift/drift.dart';

// --- 1. BUDGET & SETTLEMENTS ---

class FinancialRecords extends Table {
  TextColumn get id => text()();
  RealColumn get salary => real().withDefault(const Constant(0.0))();
  RealColumn get extraIncome => real().withDefault(const Constant(0.0))();
  RealColumn get emi => real().withDefault(const Constant(0.0))();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  RealColumn get effectiveIncome => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get allocations => text()();
  TextColumn get allocationPercentages => text()();
  TextColumn get bucketOrder => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// UPDATED: Matches Settlement Model exactly
class Settlements extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();

  // New fields matching Model
  RealColumn get totalIncome => real().withDefault(const Constant(0.0))();
  RealColumn get totalExpense => real().withDefault(const Constant(0.0))();
  DateTimeColumn get settledAt => dateTime()();

  // JSON Storage for complex types
  TextColumn get allocations => text()(); // Map<String, double>
  TextColumn get expenses => text()(); // Map<String, double>
  TextColumn get bucketOrder => text()(); // List<String>

  @override
  Set<Column> get primaryKey => {id};
}

// --- 2. DAILY EXPENSE ---

class ExpenseAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text()();
  TextColumn get type => text()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get accountType =>
      text().withDefault(const Constant('Savings Account'))();
  TextColumn get accountNumber => text().withDefault(const Constant(''))();
  IntColumn get color => integer().withDefault(const Constant(0xFF1E1E1E))();
  BoolColumn get showOnDashboard =>
      boolean().withDefault(const Constant(true))();
  IntColumn get dashboardOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(ExpenseAccounts, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get bucket => text()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get subCategory => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get transferAccountId => text().nullable()();
  TextColumn get transferAccountName => text().nullable()();
  TextColumn get transferAccountBankName => text().nullable()();
  TextColumn get linkedCreditCardId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 3. CREDIT TRACKER ---

class CreditCards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text()();
  TextColumn get lastFourDigits => text().withDefault(const Constant(''))();
  RealColumn get creditLimit => real()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  IntColumn get billDate => integer()();
  IntColumn get dueDate => integer()();
  IntColumn get color => integer().withDefault(const Constant(0xFF1E1E1E))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CreditTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text().references(CreditCards, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get bucket => text()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get subCategory => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get linkedExpenseId => text().nullable()();
  BoolColumn get includeInNextStatement =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isSettlementVerified =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 4. INVESTMENTS ---

class InvestmentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  TextColumn get type => text()();
  TextColumn get bucket => text().withDefault(const Constant('Long Term'))();
  RealColumn get quantity => real()();
  RealColumn get averagePrice => real()();
  RealColumn get currentPrice => real()();
  RealColumn get previousClose => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastPurchasedDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 5. NET WORTH ---

class NetWorthRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalAmount => real()();
  TextColumn get breakdown => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class NetWorthSplits extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 6. CUSTOM ENTRY ---

class CustomTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get fields => text()();
  TextColumn get xAxisField => text().nullable()();
  TextColumn get yAxisField => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomRecords extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(CustomTemplates, #id)();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'Income' or 'Expense'
  TextColumn get subCategories => text()(); // JSON List<String>
  IntColumn get iconCode => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 11. SETTINGS (Key-Value Store) ---
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON

  @override
  Set<Column> get primaryKey => {key};
}
