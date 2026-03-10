import 'package:drift/drift.dart';

// --- TYPE CONVERTERS ---

/// Enforces 2 decimal places for double values (e.g., Currency)
class TwoDecimalConverter extends TypeConverter<double, double> {
  const TwoDecimalConverter();

  @override
  double fromSql(double fromDb) {
    return double.parse(fromDb.toStringAsFixed(2));
  }

  @override
  double toSql(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

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

  // FIXED: Applied TwoDecimalConverter to enforce 2 decimal precision
  RealColumn get currentBalance => real()
      .withDefault(const Constant(0.0))
      .map(const TwoDecimalConverter())();

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
  RealColumn get currentBalance => real()
      .withDefault(const Constant(0.0))
      .map(const TwoDecimalConverter())();

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
// class NetWorthSplits extends Table {
//   TextColumn get id => text()();
//   DateTimeColumn get date => dateTime()();

//   RealColumn get netIncome => real().withDefault(const Constant(0.0))();
//   RealColumn get netExpense => real().withDefault(const Constant(0.0))();
//   RealColumn get capitalGain => real().withDefault(const Constant(0.0))();
//   RealColumn get capitalLoss => real().withDefault(const Constant(0.0))();
//   RealColumn get nonCalcIncome => real().withDefault(const Constant(0.0))();
//   RealColumn get nonCalcExpense => real().withDefault(const Constant(0.0))();

//   @override
//   Set<Column> get primaryKey => {id};
// }
@DataClassName("NetWorthSplit")
class NetWorthSplits extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  // --- 1. ASSETS ---
  RealColumn get bankAccounts => real().withDefault(const Constant(0.0))();
  RealColumn get cashInHand => real().withDefault(const Constant(0.0))();
  RealColumn get mutualFunds => real().withDefault(const Constant(0.0))();
  RealColumn get equity => real().withDefault(const Constant(0.0))();
  RealColumn get bonds => real().withDefault(const Constant(0.0))();
  RealColumn get deposits => real().withDefault(const Constant(0.0))();
  RealColumn get realEstate => real().withDefault(const Constant(0.0))();
  RealColumn get otherAssets => real().withDefault(const Constant(0.0))();
  TextColumn get assetNotes => text().nullable()();

  // --- 2. LIABILITIES ---
  RealColumn get loans => real().withDefault(const Constant(0.0))();
  RealColumn get creditCardOutstanding =>
      real().withDefault(const Constant(0.0))();
  RealColumn get creditLineOutstanding =>
      real().withDefault(const Constant(0.0))();
  RealColumn get otherDebts => real().withDefault(const Constant(0.0))();
  TextColumn get liabilityNotes => text().nullable()();

  // --- 3. OTHER CASHFLOWS ---
  RealColumn get totalIncome => real().withDefault(const Constant(0.0))();
  RealColumn get totalExpense => real().withDefault(const Constant(0.0))();
  RealColumn get budgetedIncome => real().withDefault(const Constant(0.0))();
  RealColumn get budgetedExpense => real().withDefault(const Constant(0.0))();
  RealColumn get nonCalcIncome => real().withDefault(const Constant(0.0))();
  RealColumn get nonCalcExpense => real().withDefault(const Constant(0.0))();
  RealColumn get outOfBucketExpense =>
      real().withDefault(const Constant(0.0))();

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

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  // [NEW] Asset Details
  TextColumn get purpose => text().nullable()(); // "Retirement", "Car", etc.
  TextColumn get investmentType => text()
      .withDefault(const Constant('Others'))(); // "Mutual Fund", "Stocks" etc.
  TextColumn get identificationNumber =>
      text().nullable()(); // Folio/Account No

  // Valuation
  RealColumn get currentAmount =>
      real().withDefault(const Constant(0.0))(); // Current Value
  RealColumn get targetAmount => real()(); // Target Value

  // Dates
  DateTimeColumn get startDate =>
      dateTime().withDefault(currentDate)(); // Start Date
  DateTimeColumn get deadline => dateTime().nullable()(); // Target Date

  // Performance
  RealColumn get expectedReturn =>
      real().nullable()(); // Expected Rate of Return (%)

  // UI & Meta
  IntColumn get color => integer()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  // Legacy fields (Optional to keep or remove, keeping for safety)
  TextColumn get category => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Medium'))();
  RealColumn get monthlyContributionTarget => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Loans extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get provider => text()(); // Bank Name
  TextColumn get type => text()(); // 'BORROWED' or 'LENT'

  // Amounts
  RealColumn get principalAmount => real()
      .withDefault(const Constant(0.0))(); // [NEW] The original loan amount
  RealColumn get totalAmount =>
      real()(); // Total Repayment Amount (Principal + Interest)
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();

  // Terms
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();
  RealColumn get emiAmount => real().nullable()(); // [NEW]

  // Dates
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()(); // Loan End Date
  DateTimeColumn get nextPaymentDate => dateTime().nullable()(); // [NEW]

  // Meta
  TextColumn get notes => text().nullable()(); // [NEW] Account No etc.
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- ASSET LOGS (Enhanced) ---
class AssetLogs extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text()();
  TextColumn get type =>
      text()(); // 'Goal_Contribution', 'Loan_Repayment', etc.

  // The Total Amount of the transaction
  RealColumn get amount => real()();

  // [NEW] The portion of 'amount' that is Interest/Profit
  RealColumn get interestComponent => real().withDefault(const Constant(0.0))();

  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HeatmapLimits extends Table {
  // ID Format: "YYYYMM" (e.g., "202402")
  TextColumn get id => text()();

  // Tier 1: Spending <= this is Safe (Green)
  RealColumn get safeLimit => real().withDefault(const Constant(500.0))();

  // Tier 2: Spending <= this is Caution (Yellow)
  RealColumn get cautionLimit => real().withDefault(const Constant(2000.0))();

  // Tier 3: Spending <= this is Warning (Orange) [NEW FIELD]
  // Anything above this is Critical (Red)
  RealColumn get severeLimit => real().withDefault(const Constant(5000.0))();

  @override
  Set<Column> get primaryKey => {id};
}
// --- RECURRING / PLANNED PAYMENTS ---

// --- RECURRING / PLANNED PAYMENTS ---
class RecurringPatterns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();

  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get subCategory => text()();
  TextColumn get bucket => text().withDefault(const Constant('Unallocated'))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  TextColumn get sourceAccountId => text().nullable()();
  TextColumn get sourceCardId => text().nullable()();
  TextColumn get destinationAccountId => text().nullable()();

  // --- SCHEDULING CORE ---
  TextColumn get frequency =>
      text()(); // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  IntColumn get interval => integer().withDefault(const Constant(1))();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get executionTime => text()();

  // [NEW] SMART SCHEDULE COLUMNS
  TextColumn get scheduleType => text().withDefault(const Constant('Fixed'))();
  IntColumn get weekParam => integer().nullable()();
  IntColumn get dayParam => integer().nullable()();

  // [NEW - SCALE UP FIELDS]
  BoolColumn get isVariable => boolean().withDefault(const Constant(false))();
  DateTimeColumn get endDate => dateTime().nullable()(); // Auto-Stop date
  IntColumn get maxOccurrences => integer().nullable()(); // Stop after N times
  IntColumn get occurrencesProcessed =>
      integer().withDefault(const Constant(0))();
  TextColumn get website => text().nullable()(); // For logo fetching
  BoolColumn get notifyBefore => boolean().withDefault(const Constant(true))();

  DateTimeColumn get nextRunAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get autoExecute => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurringLogs extends Table {
  TextColumn get id => text()();
  TextColumn get patternId => text().references(RecurringPatterns, #id)();
  DateTimeColumn get executedAt => dateTime()();
  BoolColumn get isSuccess => boolean()();
  TextColumn get error => text().nullable()();
  TextColumn get generatedTxnId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- 14. VAULT (SECURE STORAGE) ---
class VaultRecords extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'CREDENTIAL' or 'CARD'
  TextColumn get title => text()(); // Plaintext for Dashboard Search

  // Encrypted JSON String containing all sensitive fields
  TextColumn get encryptedPayload => text()();

  // Initialization Vector for AES-GCM (Ensures identical data encrypts differently)
  TextColumn get iv => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
