import 'package:drift/drift.dart';

// --- 1. BUDGET & SETTLEMENTS ---
class FinancialRecords extends Table {
  TextColumn get id => text()(); // Format: "YYYYMM"
  IntColumn get year => integer()();
  IntColumn get month => integer()();

  // Income Components
  RealColumn get salary => real().withDefault(const Constant(0.0))();
  RealColumn get extraIncome => real().withDefault(const Constant(0.0))();
  RealColumn get emi => real().withDefault(const Constant(0.0))();

  // The missing field #1
  RealColumn get effectiveIncome => real().withDefault(const Constant(0.0))();

  RealColumn get budget => real().withDefault(const Constant(0.0))();

  // JSON Data Maps
  TextColumn get allocations => text()(); // Map<String, double> (Amounts)

  // The missing field #2
  TextColumn get allocationPercentages =>
      text()(); // Map<String, double> (Percentages)

  TextColumn get bucketOrder => text()(); // List<String>

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settlements extends Table {
  TextColumn get id => text()(); // Format: "YYYYMM"
  IntColumn get year => integer()();
  IntColumn get month => integer()();

  // Store Maps as JSON Strings
  TextColumn get allocations => text()(); // Map<String, double>
  TextColumn get expenses => text()(); // Map<String, double>

  // Store List as JSON String
  TextColumn get bucketOrder => text()(); // List<String>

  // Totals
  RealColumn get totalIncome => real().withDefault(const Constant(0.0))();
  RealColumn get totalExpense => real().withDefault(const Constant(0.0))();

  DateTimeColumn get settledAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text()();
  TextColumn get type =>
      text().withDefault(const Constant('Bank'))(); // 'Bank', 'Cash', etc.

  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();

  // Missing fields from Model
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

// --- 3. EXPENSE TRANSACTIONS ---
class ExpenseTransactions extends Table {
  TextColumn get id => text()();
  // CHANGED: Made nullable to support Credit Card Only transactions (No Bank Account)
  TextColumn get accountId =>
      text().nullable().references(ExpenseAccounts, #id)();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();

  TextColumn get bucket => text().withDefault(const Constant('Unallocated'))();
  TextColumn get type => text().withDefault(const Constant(
      'Expense'))(); // 'Expense', 'Income', 'Transfer Out', 'Transfer In'
  TextColumn get category => text().withDefault(const Constant('General'))();
  TextColumn get subCategory => text().withDefault(const Constant('General'))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  // Transfer Fields
  TextColumn get transferAccountId => text().nullable()();
  TextColumn get transferAccountName => text().nullable()();
  TextColumn get transferAccountBankName => text().nullable()();

  // Credit Link
  TextColumn get linkedCreditCardId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CreditCards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text()();
  TextColumn get lastFourDigits =>
      text().withDefault(const Constant(''))(); // Found in Model

  RealColumn get creditLimit => real()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();

  IntColumn get billDate => integer()();
  IntColumn get dueDate => integer()(); // Found in Model
  IntColumn get color =>
      integer().withDefault(const Constant(0xFF1E1E1E))(); // Found in Model

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 5. CREDIT TRANSACTIONS ---
class CreditTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text().references(CreditCards, #id)();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();

  TextColumn get description => text()(); // Mapped to 'description' in Model
  TextColumn get bucket => text().withDefault(const Constant('Unallocated'))();
  TextColumn get type => text()(); // 'Expense' or 'Payment'

  TextColumn get category => text()();
  TextColumn get subCategory => text()();
  TextColumn get notes => text()();

  // Link to Expense
  TextColumn get linkedExpenseId => text().nullable()();

  // Specific Flags from Model
  BoolColumn get includeInNextStatement =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isSettlementVerified =>
      boolean().withDefault(const Constant(false))();

  // EMI Logic
  BoolColumn get isEmi => boolean().withDefault(const Constant(false))();
  IntColumn get emiMonths => integer().withDefault(const Constant(0))();
  IntColumn get emiRemaining => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class InvestmentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // Stores 'InvestmentType.stock' etc.

  RealColumn get quantity => real()();
  RealColumn get averagePrice => real()();
  RealColumn get currentPrice => real()();
  RealColumn get previousClose =>
      real().withDefault(const Constant(0.0))(); // For Day Gain

  TextColumn get bucket => text().withDefault(const Constant('General'))();

  DateTimeColumn get lastPurchasedDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  // Flag to differentiate manually added vs API tracked assets (optional but good practice)
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class NetWorthRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 13. NET WORTH SPLITS ---
class NetWorthSplits extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  RealColumn get netIncome => real().withDefault(const Constant(0.0))();
  RealColumn get netExpense => real().withDefault(const Constant(0.0))();
  RealColumn get capitalGain => real().withDefault(const Constant(0.0))();
  RealColumn get capitalLoss => real().withDefault(const Constant(0.0))();
  RealColumn get nonCalcIncome => real().withDefault(const Constant(0.0))();
  RealColumn get nonCalcExpense => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 6. CUSTOM ENTRY ---

class CustomTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  // Stores List<CustomFieldConfig> as JSON
  TextColumn get fields => text()();

  TextColumn get xAxisField => text().nullable()();
  TextColumn get yAxisField => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 10. CUSTOM RECORDS ---
class CustomRecords extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(CustomTemplates, #id)();
  DateTimeColumn get createdAt => dateTime()();

  // Stores Map<String, dynamic> as JSON
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'Expense' or 'Income'

  // Stored as JSON List<String>
  TextColumn get subCategories => text()();

  // Nullable Integer for Icon CodePoints
  IntColumn get iconCode => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON
  @override
  Set<Column> get primaryKey => {key};
}
