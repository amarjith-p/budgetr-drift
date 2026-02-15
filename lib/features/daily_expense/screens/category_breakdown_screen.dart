import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../widgets/transaction_item.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../widgets/category_export_sheet.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  final ExpenseService _service = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();
  final DashboardService _dashboardService = GetIt.I<DashboardService>();

  String _selectedRange = 'This Month';
  DateTimeRange? _customDateRange;

  String? _selectedAccountId;
  bool _showIncome = false;
  bool _viewByBucket = false;

  // Sorting: false = Amount (High to Low), true = Health (Over Budget first)
  bool _sortByHealth = false;

  static const String kGroupBanks = 'group_banks';
  static const String kGroupCredits = 'group_credits';

  // --- Date & Budget Helpers ---

  // Helper: Get list of YYYYMM strings for the selected range to fetch Budget Records
  List<String> _getAffectedMonthIds() {
    final now = DateTime.now();
    DateTime start, end;

    if (_selectedRange == 'Custom Range' && _customDateRange != null) {
      start = _customDateRange!.start;
      end = _customDateRange!.end;
    } else if (_selectedRange == 'Last Month') {
      start = DateTime(now.year, now.month - 1, 1);
      end = DateTime(now.year, now.month, 0);
    } else if (_selectedRange == 'This Year') {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31);
    } else if (_selectedRange == 'Last Year') {
      start = DateTime(now.year - 1, 1, 1);
      end = DateTime(now.year - 1, 12, 31);
    } else if (_selectedRange == 'All Time') {
      return []; // No budget limits aggregation for All Time
    } else {
      // Default: This Month
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
    }

    final ids = <String>{};
    // Normalize to the 1st of the month to avoid infinite loops
    DateTime current = DateTime(start.year, start.month, 1);
    final loopEnd = DateTime(end.year, end.month, 1);

    while (current.isBefore(loopEnd) || current.isAtSameMomentAs(loopEnd)) {
      ids.add("${current.year}${current.month.toString().padLeft(2, '0')}");
      // Move to next month safely
      current = DateTime(current.year, current.month + 1, 1);
    }
    return ids.toList();
  }

  // --- Filter Logic ---
  bool _matchesDateFilter(DateTime date,
      {DateTimeRange? customRangeOverride, String? rangeTypeOverride}) {
    final now = DateTime.now();
    final type = rangeTypeOverride ?? _selectedRange;
    final custom = customRangeOverride ?? _customDateRange;

    switch (type) {
      case 'This Month':
        return date.year == now.year && date.month == now.month;
      case 'Last Month':
        final last = DateTime(now.year, now.month - 1, 1);
        return date.year == last.year && date.month == last.month;
      case 'This Year':
        return date.year == now.year;
      case 'Last Year':
        return date.year == now.year - 1;
      case 'All Time':
        return true;
      case 'Custom Range':
        if (custom == null) return true;
        // Inclusive comparison for custom range
        return date
                .isAfter(custom.start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(custom.end.add(const Duration(days: 1)));
      default:
        return true;
    }
  }

  // Helper: Calculate Previous Period Date Range for Trends
  ({String type, DateTimeRange? custom}) _getPreviousPeriod() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'This Month':
        return (type: 'Last Month', custom: null);
      case 'Last Month':
        final prevStart = DateTime(now.year, now.month - 2, 1);
        final prevEnd = DateTime(now.year, now.month - 1, 0);
        return (
          type: 'Custom Range',
          custom: DateTimeRange(start: prevStart, end: prevEnd)
        );
      case 'This Year':
        return (type: 'Last Year', custom: null);
      case 'Custom Range':
        if (_customDateRange == null) return (type: 'All Time', custom: null);
        final duration = _customDateRange!.duration;
        final currentStart = _customDateRange!.start;
        final prevEnd = currentStart.subtract(const Duration(days: 1));
        final prevStart = prevEnd.subtract(duration);
        return (
          type: 'Custom Range',
          custom: DateTimeRange(start: prevStart, end: prevEnd)
        );
      default:
        return (type: 'All Time', custom: null);
    }
  }

  // Helper: Get Explicit Date Label for Report (e.g., "01 Feb 2024 - 28 Feb 2024")
  String _getReportDateLabel(List<dynamic> transactions) {
    final now = DateTime.now();
    final fmt = DateFormat('dd MMM yyyy');
    DateTime start, end;

    switch (_selectedRange) {
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Last Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31);
        break;
      case 'Last Year':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year - 1, 12, 31);
        break;
      case 'Custom Range':
        if (_customDateRange != null) {
          start = _customDateRange!.start;
          end = _customDateRange!.end;
        } else {
          return "Custom Range";
        }
        break;
      case 'All Time':
        if (transactions.isEmpty) return "All Time";
        DateTime? minDate;
        DateTime? maxDate;
        for (var t in transactions) {
          final date = (t is ExpenseTransactionModel)
              ? t.date
              : (t as CreditTransactionModel).date;
          if (minDate == null || date.isBefore(minDate)) minDate = date;
          if (maxDate == null || date.isAfter(maxDate)) maxDate = date;
        }
        if (minDate != null && maxDate != null) {
          return "${fmt.format(minDate)} - ${fmt.format(maxDate)}";
        }
        return "All Time";
      default:
        return _selectedRange;
    }
    return "${fmt.format(start)} - ${fmt.format(end)}";
  }

  // --- Breakdown Generator ---
  List<CategoryBreakdownItem> _generateBreakdown({
    required List<dynamic> allTxns,
    required bool forIncome,
    required Map<String, IconData> iconMap,
    List<String>? definedBuckets,
    Map<String, double>? bucketLimits,
  }) {
    // 1. Filter by Income/Expense
    final targetTxns = allTxns.where((t) {
      final bool isCredit = t is CreditTransactionModel;
      final String type = isCredit ? t.type : t.type;

      // Credit Card Payments (Income type in Credit model) are usually excluded from income aggregation
      if (type == 'Income' && isCredit) return false;

      if (forIncome) return type == 'Income';
      return type == 'Expense';
    }).toList();

    // 2. Grouping (Category vs Bucket)
    final groupedByMain = groupBy(targetTxns, (t) {
      if (_viewByBucket) {
        final bucket = (t is ExpenseTransactionModel)
            ? t.bucket
            : (t as CreditTransactionModel).bucket;
        return bucket.isEmpty ? 'General' : bucket;
      } else {
        return (t is ExpenseTransactionModel)
            ? t.category
            : (t as CreditTransactionModel).category;
      }
    });

    final List<CategoryBreakdownItem> result = [];

    // 3. Process Transactions
    groupedByMain.forEach((mainName, txns) {
      final catTotal = txns.fold(0.0, (sum, t) {
        final amt = (t is ExpenseTransactionModel)
            ? t.amount
            : (t as CreditTransactionModel).amount;
        return sum + amt;
      });

      // Sub-Grouping
      final groupedBySub = groupBy(txns, (t) {
        if (_viewByBucket) {
          return (t is ExpenseTransactionModel)
              ? t.category
              : (t as CreditTransactionModel).category;
        } else {
          return (t is ExpenseTransactionModel)
              ? t.subCategory
              : (t as CreditTransactionModel).subCategory;
        }
      });

      final List<SubCategoryItem> subItems = [];
      groupedBySub.forEach((subName, subTxns) {
        final subTotal = subTxns.fold(0.0, (sum, t) {
          final amt = (t is ExpenseTransactionModel)
              ? t.amount
              : (t as CreditTransactionModel).amount;
          return sum + amt;
        });
        subTxns.sort((a, b) {
          final dateA = (a is ExpenseTransactionModel)
              ? a.date
              : (a as CreditTransactionModel).date;
          final dateB = (b is ExpenseTransactionModel)
              ? b.date
              : (b as CreditTransactionModel).date;
          return dateB.compareTo(dateA);
        });
        subItems.add(SubCategoryItem(
            name: subName, amount: subTotal, transactions: subTxns));
      });
      subItems.sort((a, b) => b.amount.compareTo(a.amount));

      // Attach Limit (if Bucket View)
      double? limit;
      if (_viewByBucket && bucketLimits != null) {
        limit = bucketLimits[mainName];
      }

      result.add(CategoryBreakdownItem(
        name: mainName,
        totalAmount: catTotal,
        subcategories: subItems,
        icon: _viewByBucket
            ? Icons.all_inbox_rounded
            : (iconMap[mainName] ?? Icons.category_outlined),
        trendPercentage: null, // Trend is calculated in UI layer only
        budgetLimit: limit,
      ));
    });

    // 4. Fill Missing Buckets (Expense View Only)
    if (_viewByBucket && definedBuckets != null && !forIncome) {
      for (var bucket in definedBuckets) {
        if (!result.any((item) => item.name == bucket)) {
          double? limit = bucketLimits?[bucket];
          result.add(CategoryBreakdownItem(
            name: bucket,
            totalAmount: 0.0,
            subcategories: [],
            icon: Icons.all_inbox_rounded,
            trendPercentage: null,
            budgetLimit: limit,
          ));
        }
      }
    }

    // 5. Sorting Logic
    if (_sortByHealth && !forIncome && bucketLimits != null) {
      result.sort((a, b) {
        final limitA = a.budgetLimit ?? 0;
        final limitB = b.budgetLimit ?? 0;

        final diffA = a.totalAmount - limitA;
        final diffB = b.totalAmount - limitB;

        // Prioritize over-budget items
        if (diffA > 0 && diffB <= 0) return -1;
        if (diffB > 0 && diffA <= 0) return 1;
        if (diffA > 0 && diffB > 0) return diffB.compareTo(diffA);

        // Fallback to total amount
        return b.totalAmount.compareTo(a.totalAmount);
      });
    } else {
      // Default: Sort by Amount Descending
      result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    }
    return result;
  }

  Future<void> _pickDateRange() async {
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00B4D8),
                onPrimary: Colors.white,
                surface: Color(0xFF1B263B),
                onSurface: Colors.white),
            dialogBackgroundColor: const Color(0xFF151D29),
          ),
          child: child!),
    );
    if (picked != null)
      setState(() {
        _customDateRange = picked;
        _selectedRange = 'Custom Range';
      });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final String? fetchId = (_selectedAccountId == kGroupBanks ||
            _selectedAccountId == kGroupCredits)
        ? null
        : _selectedAccountId;
    final List<String> monthIds = _getAffectedMonthIds();

    return StreamBuilder<List<TransactionCategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, catSnapshot) {
        final Map<String, IconData> iconMap = {};
        if (catSnapshot.hasData) {
          for (var c in catSnapshot.data!) {
            if (c.iconCode != null)
              iconMap[c.name] = IconConstants.getIconByCode(c.iconCode!);
          }
        }

        return StreamBuilder<List<ExpenseAccountModel>>(
            stream: _service.getAccounts(),
            builder: (context, accountListSnap) {
              return StreamBuilder<List<CreditCardModel>>(
                  stream: _creditService.getCreditCards(),
                  builder: (context, cardListSnap) {
                    final Map<String, String> accountNameMap = {};
                    if (accountListSnap.hasData)
                      for (var acc in accountListSnap.data!)
                        accountNameMap[acc.id] =
                            "${acc.name} (${acc.bankName})";
                    if (cardListSnap.hasData)
                      for (var card in cardListSnap.data!)
                        accountNameMap[card.id] =
                            "${card.name} (${card.bankName})";

                    // 4. Fetch Financial Records to Aggregate Budget
                    return StreamBuilder<List<FinancialRecord>>(
                        stream: _dashboardService.getFinancialRecords(),
                        builder: (context, recordsSnapshot) {
                          final Map<String, double> aggregatedLimits = {};
                          final Set<String> definedBuckets = {};

                          if (recordsSnapshot.hasData) {
                            for (var record in recordsSnapshot.data!) {
                              if (monthIds.contains(record.id)) {
                                definedBuckets.addAll(record.bucketOrder);
                                record.allocations.forEach((bucket, amount) {
                                  aggregatedLimits[bucket] =
                                      (aggregatedLimits[bucket] ?? 0.0) +
                                          amount;
                                });
                              }
                            }
                          }

                          // 5. Fetch Transactions
                          return StreamBuilder<List<ExpenseTransactionModel>>(
                            stream:
                                _service.getTransactions(accountId: fetchId),
                            builder: (context, expenseSnapshot) {
                              return StreamBuilder<
                                  List<CreditTransactionModel>>(
                                stream: fetchId == null
                                    ? _creditService.getAllTransactions()
                                    : _creditService
                                        .getTransactionsForCard(fetchId),
                                builder: (context, creditSnapshot) {
                                  if (!expenseSnapshot.hasData &&
                                      !creditSnapshot.hasData)
                                    return const Center(child: ModernLoader());

                                  final expenses = expenseSnapshot.data ?? [];
                                  final credits = creditSnapshot.data ?? [];

                                  final List<dynamic> rawFilteredByAccount = [];
                                  if (_selectedAccountId != kGroupCredits) {
                                    rawFilteredByAccount.addAll(expenses.where(
                                        (t) => (_selectedAccountId != null &&
                                                _selectedAccountId !=
                                                    kGroupBanks &&
                                                t.accountId !=
                                                    _selectedAccountId)
                                            ? false
                                            : true));
                                  }
                                  if (_selectedAccountId != kGroupBanks) {
                                    rawFilteredByAccount.addAll(credits.where(
                                        (t) => (_selectedAccountId != null &&
                                                _selectedAccountId !=
                                                    kGroupCredits &&
                                                t.cardId != _selectedAccountId)
                                            ? false
                                            : true));
                                  }

                                  final List<dynamic> currentPeriodTxns =
                                      rawFilteredByAccount
                                          .where(
                                              (t) => _matchesDateFilter(t.date))
                                          .toList();

                                  double totalIncome = 0;
                                  double totalExpense = 0;
                                  for (var t in currentPeriodTxns) {
                                    final bool isCredit =
                                        t is CreditTransactionModel;
                                    final String type =
                                        isCredit ? t.type : t.type;
                                    final double amount =
                                        isCredit ? t.amount : t.amount;
                                    if (type == 'Income' && !isCredit)
                                      totalIncome += amount;
                                    else if (type == 'Expense')
                                      totalExpense += amount;
                                  }
                                  final currentTotal =
                                      _showIncome ? totalIncome : totalExpense;

                                  // Generate Breakdown
                                  final uiBreakdownItems = _generateBreakdown(
                                    allTxns: currentPeriodTxns,
                                    forIncome: _showIncome,
                                    iconMap: iconMap,
                                    definedBuckets: definedBuckets.toList(),
                                    bucketLimits: aggregatedLimits,
                                  );

                                  return ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 120),
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      // --- Filters & Actions ---
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildAccountFilter(
                                                  accountListSnap.data ?? [],
                                                  cardListSnap.data ?? [])),
                                          const SizedBox(width: 8),
                                          _buildTimeFilter(),
                                          const SizedBox(width: 8),
                                          _buildExportButton(
                                              currentPeriodTxns,
                                              iconMap,
                                              aggregatedLimits,
                                              accountNameMap,
                                              totalIncome,
                                              totalExpense,
                                              definedBuckets.toList()),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // --- Toggles ---
                                      Row(
                                        children: [
                                          Expanded(child: _buildViewToggle()),
                                          if (_viewByBucket &&
                                              !_showIncome) ...[
                                            const SizedBox(width: 12),
                                            _buildSortToggle(),
                                          ]
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Summary Cards ---
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildSummaryCard(
                                              "Total Income",
                                              totalIncome,
                                              const Color(0xFF00E676),
                                              Icons.arrow_downward_rounded,
                                              isActive: _showIncome,
                                              onTap: () => setState(
                                                  () => _showIncome = true),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildSummaryCard(
                                              "Total Expense",
                                              totalExpense,
                                              const Color(0xFFFF4D6D),
                                              Icons.arrow_upward_rounded,
                                              isActive: !_showIncome,
                                              onTap: () => setState(
                                                  () => _showIncome = false),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30),

                                      // --- List Header ---
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _showIncome
                                                ? "INCOME SOURCES"
                                                : "EXPENSE BREAKDOWN",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          if (_selectedRange != 'All Time')
                                            Text(
                                              "vs Prev. Period",
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      if (uiBreakdownItems.isEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(Icons.analytics_outlined,
                                                    size: 48,
                                                    color: Colors.white
                                                        .withOpacity(0.1)),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "No records found for this period",
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.3)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        ...uiBreakdownItems.map((item) {
                                          // Trends
                                          double? trend;
                                          final prevPeriod =
                                              _getPreviousPeriod();
                                          if (_selectedRange != 'All Time') {
                                            double prevTotal = 0;
                                            for (var t
                                                in rawFilteredByAccount) {
                                              if (!_matchesDateFilter(t.date,
                                                  customRangeOverride:
                                                      prevPeriod.custom,
                                                  rangeTypeOverride: prevPeriod
                                                      .type)) continue;
                                              final isCredit =
                                                  t is CreditTransactionModel;
                                              final type =
                                                  isCredit ? t.type : t.type;
                                              if (_showIncome &&
                                                  type != 'Income') continue;
                                              if (!_showIncome &&
                                                  type != 'Expense') continue;

                                              String tGroup;
                                              if (_viewByBucket) {
                                                final b = (t
                                                        is ExpenseTransactionModel)
                                                    ? t.bucket
                                                    : (t as CreditTransactionModel)
                                                        .bucket;
                                                tGroup =
                                                    b.isEmpty ? 'General' : b;
                                              } else {
                                                tGroup = (t
                                                        is ExpenseTransactionModel)
                                                    ? t.category
                                                    : (t as CreditTransactionModel)
                                                        .category;
                                              }
                                              if (tGroup == item.name) {
                                                prevTotal += (t
                                                        is ExpenseTransactionModel)
                                                    ? t.amount
                                                    : (t as CreditTransactionModel)
                                                        .amount;
                                              }
                                            }
                                            if (prevTotal > 0)
                                              trend = ((item.totalAmount -
                                                          prevTotal) /
                                                      prevTotal) *
                                                  100;
                                            else if (prevTotal == 0 &&
                                                item.totalAmount > 0)
                                              trend = 100;
                                          }

                                          final showLimit =
                                              _viewByBucket && !_showIncome;
                                          final displayItem =
                                              CategoryBreakdownItem(
                                            name: item.name,
                                            totalAmount: item.totalAmount,
                                            subcategories: item.subcategories,
                                            icon: item.icon,
                                            trendPercentage: trend,
                                            budgetLimit: showLimit
                                                ? item.budgetLimit
                                                : null,
                                          );

                                          return _buildCategoryTile(
                                              displayItem,
                                              currentTotal,
                                              currencyFmt,
                                              accountNameMap);
                                        }),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        });
                  });
            });
      },
    );
  }

  // --- Widgets ---

  Widget _buildExportButton(
      List<dynamic> txns,
      Map<String, IconData> iconMap,
      Map<String, double> limits,
      Map<String, String> accountNameMap,
      double income,
      double expense,
      List<String> definedBuckets) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
          color: const Color(0xFF00B4D8).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3))),
      child: IconButton(
        icon: const Icon(Icons.download_rounded,
            color: Color(0xFF00B4D8), size: 18),
        padding: EdgeInsets.zero,
        onPressed: () {
          final incomeList = _generateBreakdown(
              allTxns: txns,
              forIncome: true,
              iconMap: iconMap,
              bucketLimits: limits);
          final expenseList = _generateBreakdown(
              allTxns: txns,
              forIncome: false,
              iconMap: iconMap,
              bucketLimits: limits,
              definedBuckets: definedBuckets);

          final reportLabel = _getReportDateLabel(txns);
          String accountFilterName = "All Accounts";
          if (_selectedAccountId != null) {
            accountFilterName = accountNameMap[_selectedAccountId] ??
                (_selectedAccountId == kGroupBanks
                    ? "All Banks"
                    : "All Credit Cards");
          }

          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => CategoryExportSheet(
              incomeItems: incomeList, expenseItems: expenseList,
              dateRangeName: reportLabel,
              filterAccountName: accountFilterName,
              accountNameMap: accountNameMap,
              totalIncome: income, totalExpense: expense,
              groupingType: _viewByBucket
                  ? "Bucket"
                  : "Category", // [SAFE EXPORT] Pass grouping type for filename
            ),
          );
        },
      ),
    );
  }

  // ... (Widgets: _buildViewToggle, _buildSortToggle, _buildAccountFilter, _buildTimeFilter, _buildSummaryCard, _buildCategoryTile, _ReadOnlyItems)
  // These implementations remain strictly preserved as per previous versions

  Widget _buildViewToggle() {
    return Container(
        height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFF151D29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(children: [
          Expanded(
              child: GestureDetector(
                  onTap: () => setState(() => _viewByBucket = false),
                  child: Container(
                      decoration: BoxDecoration(
                          color: !_viewByBucket
                              ? const Color(0xFF00B4D8).withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: !_viewByBucket
                              ? Border.all(
                                  color:
                                      const Color(0xFF00B4D8).withOpacity(0.3))
                              : null),
                      alignment: Alignment.center,
                      child: Text("By Category",
                          style: TextStyle(
                              color: !_viewByBucket
                                  ? const Color(0xFF00B4D8)
                                  : Colors.white54,
                              fontWeight: !_viewByBucket
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12))))),
          Expanded(
              child: GestureDetector(
                  onTap: () => setState(() => _viewByBucket = true),
                  child: Container(
                      decoration: BoxDecoration(
                          color: _viewByBucket
                              ? const Color(0xFF00B4D8).withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: _viewByBucket
                              ? Border.all(
                                  color:
                                      const Color(0xFF00B4D8).withOpacity(0.3))
                              : null),
                      alignment: Alignment.center,
                      child: Text("By Bucket",
                          style: TextStyle(
                              color: _viewByBucket
                                  ? const Color(0xFF00B4D8)
                                  : Colors.white54,
                              fontWeight: _viewByBucket
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12)))))
        ]));
  }

  Widget _buildSortToggle() {
    return GestureDetector(
        onTap: () => setState(() => _sortByHealth = !_sortByHealth),
        child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: _sortByHealth
                    ? Colors.redAccent.withOpacity(0.2)
                    : const Color(0xFF151D29),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _sortByHealth
                        ? Colors.redAccent.withOpacity(0.5)
                        : Colors.white.withOpacity(0.05))),
            child: Icon(
                _sortByHealth ? Icons.warning_rounded : Icons.sort_rounded,
                color: _sortByHealth ? Colors.redAccent : Colors.white54,
                size: 20)));
  }

  Widget _buildAccountFilter(
      List<ExpenseAccountModel> accounts, List<CreditCardModel> cards) {
    if (_selectedAccountId != null &&
        _selectedAccountId != kGroupBanks &&
        _selectedAccountId != kGroupCredits) {
      bool exists = accounts.any((a) => a.id == _selectedAccountId) ||
          cards.any((c) => c.id == _selectedAccountId);
      if (!exists) _selectedAccountId = null;
    }
    return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
                value: _selectedAccountId,
                dropdownColor: const Color(0xFF1B263B),
                icon: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 16),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                isExpanded: true,
                hint: const Text("All Accounts",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text("All Accounts")),
                  if (accounts.isNotEmpty)
                    const DropdownMenuItem<String?>(
                        enabled: false,
                        value: 'header_bank',
                        child: Text("BANK ACCOUNTS",
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  if (accounts.isNotEmpty)
                    const DropdownMenuItem<String?>(
                        value: kGroupBanks,
                        child: Text("All Bank Accounts",
                            style: TextStyle(fontWeight: FontWeight.w500))),
                  ...accounts.map((acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Text("${acc.name} ( ${acc.bankName} )",
                          overflow: TextOverflow.ellipsis))),
                  if (cards.isNotEmpty)
                    const DropdownMenuItem<String?>(
                        enabled: false,
                        value: 'header_credit',
                        child: Text("CREDIT CARDS",
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  if (cards.isNotEmpty)
                    const DropdownMenuItem<String?>(
                        value: kGroupCredits,
                        child: Text("All Credit Cards",
                            style: TextStyle(fontWeight: FontWeight.w500))),
                  ...cards.map((card) => DropdownMenuItem(
                      value: card.id,
                      child: Text("${card.name} ( ${card.bankName} )",
                          overflow: TextOverflow.ellipsis)))
                ],
                onChanged: (val) {
                  setState(() => _selectedAccountId = val);
                })));
  }

  Widget _buildTimeFilter() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                value: _selectedRange,
                dropdownColor: const Color(0xFF1B263B),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70, size: 18),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                isDense: true,
                items: [
                  'This Month',
                  'Last Month',
                  'This Year',
                  'Last Year',
                  'All Time',
                  'Custom Range'
                ].map((e) {
                  if (e == 'Custom Range' &&
                      _selectedRange == 'Custom Range' &&
                      _customDateRange != null) {
                    final start =
                        DateFormat('dd MMM').format(_customDateRange!.start);
                    final end =
                        DateFormat('dd MMM').format(_customDateRange!.end);
                    return DropdownMenuItem(
                        value: e,
                        onTap: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _pickDateRange());
                        },
                        child: Text("$start - $end"));
                  }
                  if (e == 'Custom Range') {
                    return DropdownMenuItem(
                        value: e,
                        onTap: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _pickDateRange());
                        },
                        child: Text(e));
                  }
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  if (val != null && val != 'Custom Range') {
                    setState(() => _selectedRange = val);
                  }
                })));
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon,
      {required bool isActive, required VoidCallback onTap}) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: isActive
                    ? color.withOpacity(0.15)
                    : const Color(0xFF151D29),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        isActive ? color.withOpacity(0.5) : Colors.transparent,
                    width: 1.5)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 16)),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600))
              ]),
              const SizedBox(height: 12),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(currencyFmt.format(amount),
                      style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)))
            ])));
  }

  Widget _buildCategoryTile(CategoryBreakdownItem item, double totalAmount,
      NumberFormat fmt, Map<String, String> accountNameMap) {
    double percentage;
    Color color;
    String statusLabel = "";
    if (item.budgetLimit != null && item.budgetLimit! > 0) {
      percentage = item.totalAmount / item.budgetLimit!;
      final remaining = item.budgetLimit! - item.totalAmount;
      if (remaining >= 0) {
        statusLabel = "Left: ${fmt.format(remaining)}";
        if (percentage < 0.75)
          color = const Color(0xFF00E676);
        else if (percentage < 1.0)
          color = Colors.orangeAccent;
        else
          color = Colors.redAccent;
      } else {
        statusLabel = "Over: ${fmt.format(remaining.abs())}";
        color = const Color(0xFFFF4D6D);
      }
    } else {
      percentage = totalAmount > 0 ? (item.totalAmount / totalAmount) : 0.0;
      color = _showIncome ? const Color(0xFF00E676) : const Color(0xFF00B4D8);
      statusLabel = "${(percentage * 100).toStringAsFixed(1)}% of total";
    }
    final double visualProgress = percentage > 1.0 ? 1.0 : percentage;
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF151D29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(item.icon, color: color, size: 20)),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(item.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            if (item.trendPercentage != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(children: [
                                    Icon(
                                        item.trendPercentage! > 0
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        size: 10,
                                        color: item.trendPercentage! > 0
                                            ? Colors.redAccent
                                            : Colors.greenAccent),
                                    const SizedBox(width: 2),
                                    Text(
                                        "${item.trendPercentage!.abs().toStringAsFixed(1)}%",
                                        style: TextStyle(
                                            color: item.trendPercentage! > 0
                                                ? Colors.redAccent
                                                : Colors.greenAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold))
                                  ]))
                          ])),
                      const SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(fmt.format(item.totalAmount),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            if (item.budgetLimit != null &&
                                item.budgetLimit! > 0)
                              Text("/ ${fmt.format(item.budgetLimit)}",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 10))
                          ])
                    ]),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                              value: visualProgress,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 4)),
                      const SizedBox(height: 4),
                      Text(statusLabel,
                          style: TextStyle(
                              color: color.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600))
                    ]),
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16))),
                      child: Column(
                          children: item.subcategories.map((sub) {
                        return Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                                tilePadding: const EdgeInsets.only(
                                    left: 24, right: 16, top: 4, bottom: 4),
                                title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(sub.name,
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 13),
                                              overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 8),
                                      Text(fmt.format(sub.amount),
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500))
                                    ]),
                                children: [
                                  ...sub.transactions.map((txn) {
                                    if (txn is ExpenseTransactionModel) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          child:
                                              _ReadOnlyExpenseTransactionItem(
                                                  key: ValueKey(txn.id),
                                                  txn: txn,
                                                  iconData: item.icon,
                                                  sourceAccountName:
                                                      accountNameMap[
                                                          txn.accountId]));
                                    } else if (txn is CreditTransactionModel) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          child: _ReadOnlyCreditTransactionItem(
                                              key: ValueKey(txn.id),
                                              txn: txn,
                                              iconData: item.icon,
                                              cardName:
                                                  accountNameMap[txn.cardId]));
                                    }
                                    return const SizedBox();
                                  })
                                ]));
                      }).toList()))
                ])));
  }
}

class CategoryBreakdownItem {
  final String name;
  final double totalAmount;
  final List<SubCategoryItem> subcategories;
  final IconData icon;
  final double? trendPercentage;
  final double? budgetLimit;
  CategoryBreakdownItem(
      {required this.name,
      required this.totalAmount,
      required this.subcategories,
      required this.icon,
      this.trendPercentage,
      this.budgetLimit});
}

class SubCategoryItem {
  final String name;
  final double amount;
  final List<dynamic> transactions;
  SubCategoryItem(
      {required this.name, required this.amount, required this.transactions});
}

class _ReadOnlyExpenseTransactionItem extends StatefulWidget {
  final ExpenseTransactionModel txn;
  final IconData iconData;
  final String? sourceAccountName;
  const _ReadOnlyExpenseTransactionItem(
      {required this.txn,
      required this.iconData,
      this.sourceAccountName,
      super.key});
  @override
  State<_ReadOnlyExpenseTransactionItem> createState() =>
      _ReadOnlyExpenseTransactionItemState();
}

class _ReadOnlyExpenseTransactionItemState
    extends State<_ReadOnlyExpenseTransactionItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final isTransferOut = widget.txn.type == 'Transfer Out';
    final isTransferIn = widget.txn.type == 'Transfer In';
    Color amountColor;
    Color iconColor;
    IconData icon;
    String title;
    String sign;
    if (isExpense) {
      amountColor = Colors.redAccent;
      iconColor = const Color(0xFF00B4D8);
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '-';
    } else if (isTransferOut) {
      amountColor = Colors.orangeAccent;
      iconColor = Colors.orangeAccent;
      icon = Icons.arrow_outward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title = bank.isNotEmpty ? "Transfer to $bank - $acc" : "Transfer to $acc";
      sign = '-';
    } else if (isTransferIn) {
      amountColor = Colors.greenAccent;
      iconColor = Colors.greenAccent;
      icon = Icons.arrow_downward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title =
          bank.isNotEmpty ? "Transfer from $bank - $acc" : "Transfer from $acc";
      sign = '+';
    } else {
      amountColor = Colors.greenAccent;
      iconColor = Colors.green;
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '+';
    }
    final bool hasSummary = (isExpense && widget.txn.bucket.isNotEmpty) ||
        widget.txn.notes.isNotEmpty ||
        widget.sourceAccountName != null;
    return GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _isExpanded
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05)),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : []),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        if (widget.sourceAccountName != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(widget.sourceAccountName!,
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600))))
                        else if (widget.txn.subCategory.isNotEmpty &&
                            widget.txn.subCategory != 'General')
                          Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(widget.txn.subCategory,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12)))
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text("$sign ${currency.format(widget.txn.amount)}",
                      style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM').format(widget.txn.date),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11))
                ])
              ]),
              AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: hasSummary
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 8, left: 56),
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (isExpense && widget.txn.bucket.isNotEmpty)
                                  _buildTag(widget.txn.bucket),
                                if (widget.txn.notes.isNotEmpty)
                                  Text(widget.txn.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic))
                              ]))
                      : const SizedBox(width: double.infinity),
                  secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('EEEE, hh:mm a')
                                      .format(widget.txn.date),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12)),
                              if (isExpense && widget.txn.bucket.isNotEmpty)
                                _buildTag("Bucket: ${widget.txn.bucket}")
                            ]),
                        const SizedBox(height: 12),
                        if (widget.txn.notes.isNotEmpty) ...[
                          Text("Notes:",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.txn.notes,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13))
                        ]
                      ]),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst)
            ])));
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));
}

class _ReadOnlyCreditTransactionItem extends StatefulWidget {
  final CreditTransactionModel txn;
  final IconData iconData;
  final String? cardName;
  const _ReadOnlyCreditTransactionItem(
      {required this.txn, required this.iconData, this.cardName, super.key});
  @override
  State<_ReadOnlyCreditTransactionItem> createState() =>
      _ReadOnlyCreditTransactionItemState();
}

class _ReadOnlyCreditTransactionItemState
    extends State<_ReadOnlyCreditTransactionItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final bool isIncome = widget.txn.type == 'Income';
    final Color amountColor = isIncome ? Colors.greenAccent : Colors.redAccent;
    final Color iconColor = const Color(0xFF00B4D8);
    final String title = widget.txn.category;
    final String sign = isIncome ? '+' : '-';
    final bool hasSummary = widget.txn.bucket.isNotEmpty ||
        widget.txn.notes.isNotEmpty ||
        widget.cardName != null;
    return GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _isExpanded
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05)),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : []),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(widget.iconData, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        if (widget.cardName != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(widget.cardName!,
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600))))
                        else if (widget.txn.subCategory.isNotEmpty &&
                            widget.txn.subCategory != 'General')
                          Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(widget.txn.subCategory,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12)))
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text("$sign ${currency.format(widget.txn.amount)}",
                      style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM').format(widget.txn.date),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11))
                ])
              ]),
              AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: hasSummary
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 8, left: 56),
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (widget.txn.bucket.isNotEmpty)
                                  _buildTag(widget.txn.bucket),
                                if (widget.txn.notes.isNotEmpty)
                                  Text(widget.txn.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic))
                              ]))
                      : const SizedBox(width: double.infinity),
                  secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('EEEE, hh:mm a')
                                      .format(widget.txn.date),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12)),
                              if (widget.txn.bucket.isNotEmpty)
                                _buildTag("Bucket: ${widget.txn.bucket}")
                            ]),
                        const SizedBox(height: 12),
                        if (widget.txn.notes.isNotEmpty) ...[
                          Text("Notes:",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.txn.notes,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13))
                        ]
                      ]),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst)
            ])));
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));
}
