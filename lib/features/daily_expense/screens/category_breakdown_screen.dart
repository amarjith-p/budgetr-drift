import 'dart:ui'; // Added for BackdropFilter
import 'package:budget/core/widgets/futuristic_loader.dart';
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

  bool _sortByHealth = false;

  // Search State
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  static const String kGroupBanks = 'group_banks';
  static const String kGroupCredits = 'group_credits';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Date Helpers ---
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
      return [];
    } else {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
    }

    final ids = <String>{};
    DateTime current = DateTime(start.year, start.month, 1);
    final loopEnd = DateTime(end.year, end.month, 1);

    while (current.isBefore(loopEnd) || current.isAtSameMomentAs(loopEnd)) {
      ids.add("${current.year}${current.month.toString().padLeft(2, '0')}");
      current = DateTime(current.year, current.month + 1, 1);
    }
    return ids.toList();
  }

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
        return date
                .isAfter(custom.start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(custom.end.add(const Duration(days: 1)));
      default:
        return true;
    }
  }

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
    final targetTxns = allTxns.where((t) {
      if (t is CreditTransactionModel) {
        // Exclude Credit Card Repayments/Payments from Income
        if (t.type == 'Income') {
          final cat = t.category.toLowerCase();
          if (cat == 'repayment' || cat == 'payment') return false;
        }
        return forIncome ? t.type == 'Income' : t.type == 'Expense';
      } else if (t is ExpenseTransactionModel) {
        return forIncome ? t.type == 'Income' : t.type == 'Expense';
      }
      return false;
    }).toList();

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

    groupedByMain.forEach((mainName, txns) {
      final catTotal = txns.fold(0.0, (sum, t) {
        final amt = (t is ExpenseTransactionModel)
            ? t.amount
            : (t as CreditTransactionModel).amount;
        return sum + amt;
      });

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
        trendPercentage: null,
        budgetLimit: limit,
      ));
    });

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

    if (_sortByHealth && !forIncome && bucketLimits != null) {
      result.sort((a, b) {
        final limitA = a.budgetLimit ?? 0;
        final limitB = b.budgetLimit ?? 0;
        final diffA = a.totalAmount - limitA;
        final diffB = b.totalAmount - limitB;
        if (diffA > 0 && diffB <= 0) return -1;
        if (diffB > 0 && diffA <= 0) return 1;
        if (diffA > 0 && diffB > 0) return diffB.compareTo(diffA);
        return b.totalAmount.compareTo(a.totalAmount);
      });
    } else {
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
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedRange = 'Custom Range';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
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
            if (c.iconCode != null) {
              iconMap[c.name] = IconConstants.getIconByCode(c.iconCode!);
            }
          }
        }

        return StreamBuilder<List<ExpenseAccountModel>>(
            stream: _service.getAccounts(),
            builder: (context, accountListSnap) {
              return StreamBuilder<List<CreditCardModel>>(
                  stream: _creditService.getCreditCards(),
                  builder: (context, cardListSnap) {
                    final Map<String, String> accountNameMap = {};
                    if (accountListSnap.hasData) {
                      for (var acc in accountListSnap.data!) {
                        accountNameMap[acc.id] =
                            "${acc.name} (${acc.bankName})";
                      }
                    }
                    if (cardListSnap.hasData) {
                      for (var card in cardListSnap.data!) {
                        accountNameMap[card.id] =
                            "${card.name} (${card.bankName})";
                      }
                    }

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
                                      !creditSnapshot.hasData) {
                                    return const Center(
                                        child: FuturisticLoader(
                                            size: 80,
                                            label:
                                                "GENERATING FINANCIAL INSIGHTS..."));
                                  }

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

                                  // Search Filtering Logic
                                  List<dynamic> displayedTxns =
                                      currentPeriodTxns;
                                  if (_searchController.text.isNotEmpty) {
                                    final query =
                                        _searchController.text.toLowerCase();
                                    displayedTxns =
                                        currentPeriodTxns.where((t) {
                                      final category = (t
                                                  is ExpenseTransactionModel
                                              ? t.category
                                              : (t as CreditTransactionModel)
                                                  .category)
                                          .toLowerCase();
                                      final subCategory = (t
                                                  is ExpenseTransactionModel
                                              ? t.subCategory
                                              : (t as CreditTransactionModel)
                                                  .subCategory)
                                          .toLowerCase();
                                      final notes = (t
                                                  is ExpenseTransactionModel
                                              ? t.notes
                                              : (t as CreditTransactionModel)
                                                  .notes)
                                          .toLowerCase();
                                      final bucket = (t
                                                  is ExpenseTransactionModel
                                              ? t.bucket
                                              : (t as CreditTransactionModel)
                                                  .bucket)
                                          .toLowerCase();
                                      final amount = (t
                                                  is ExpenseTransactionModel
                                              ? t.amount
                                              : (t as CreditTransactionModel)
                                                  .amount)
                                          .toString();

                                      return category.contains(query) ||
                                          subCategory.contains(query) ||
                                          notes.contains(query) ||
                                          bucket.contains(query) ||
                                          amount.contains(query);
                                    }).toList();
                                  }

                                  double totalIncome = 0;
                                  double totalExpense = 0;

                                  for (var t in displayedTxns) {
                                    if (t is CreditTransactionModel) {
                                      if (t.type == 'Income') {
                                        // Skip credit card bill repayments
                                        final cat = t.category.toLowerCase();
                                        if (cat == 'repayment' ||
                                            cat == 'payment') continue;

                                        totalIncome += t.amount;
                                      } else if (t.type == 'Expense') {
                                        totalExpense += t.amount;
                                      }
                                    } else if (t is ExpenseTransactionModel) {
                                      if (t.type == 'Income') {
                                        totalIncome += t.amount;
                                      } else if (t.type == 'Expense') {
                                        totalExpense += t.amount;
                                      }
                                    }
                                  }
                                  final currentTotal =
                                      _showIncome ? totalIncome : totalExpense;

                                  final uiBreakdownItems = _generateBreakdown(
                                    allTxns: displayedTxns,
                                    forIncome: _showIncome,
                                    iconMap: iconMap,
                                    definedBuckets: _searchController
                                            .text.isEmpty
                                        ? definedBuckets.toList()
                                        : null, // Disable empty bucket fill if searching
                                    bucketLimits: aggregatedLimits,
                                  );

                                  return ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 120),
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      // Top Row: Search or Filters
                                      _isSearchActive
                                          ? _buildSearchBar()
                                          : Row(
                                              children: [
                                                Expanded(
                                                    child: _buildAccountFilter(
                                                        accountListSnap.data ??
                                                            [],
                                                        cardListSnap.data ??
                                                            [])),
                                                const SizedBox(width: 8),
                                                _buildTimeFilter(),
                                                const SizedBox(width: 8),
                                                _buildSearchButton(),
                                                const SizedBox(width: 8),
                                                _buildExportButton(
                                                    displayedTxns,
                                                    iconMap,
                                                    aggregatedLimits,
                                                    accountNameMap,
                                                    totalIncome,
                                                    totalExpense,
                                                    _searchController
                                                            .text.isEmpty
                                                        ? definedBuckets
                                                            .toList()
                                                        : []),
                                              ],
                                            ),
                                      const SizedBox(height: 12),

                                      // Toggles
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

                                      // Summary Cards
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

                                      // List Header
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
                                          if (_selectedRange != 'All Time' &&
                                              _searchController.text.isEmpty)
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
                                                Icon(Icons.search_off_rounded,
                                                    size: 48,
                                                    color: Colors.white
                                                        .withOpacity(0.1)),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "No records found",
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
                                          if (_searchController.text.isEmpty) {
                                            final prevPeriod =
                                                _getPreviousPeriod();
                                            if (_selectedRange != 'All Time') {
                                              double prevTotal = 0;
                                              for (var t
                                                  in rawFilteredByAccount) {
                                                if (!_matchesDateFilter(t.date,
                                                    customRangeOverride:
                                                        prevPeriod.custom,
                                                    rangeTypeOverride:
                                                        prevPeriod.type)) {
                                                  continue;
                                                }
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
                                              if (prevTotal > 0) {
                                                trend = ((item.totalAmount -
                                                            prevTotal) /
                                                        prevTotal) *
                                                    100;
                                              } else if (prevTotal == 0 &&
                                                  item.totalAmount > 0) {
                                                trend = 100;
                                              }
                                            }
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

  Widget _buildSearchButton() {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
          color: const Color(0xFF00B4D8).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3))),
      child: IconButton(
        icon: const Icon(Icons.search_rounded,
            color: Color(0xFF00B4D8), size: 18),
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            _isSearchActive = true;
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Search categories, notes...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _searchController.clear();
                _isSearchActive = false;
              });
            },
          ),
        ],
      ),
    );
  }

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
              incomeItems: incomeList,
              expenseItems: expenseList,
              dateRangeName: reportLabel,
              filterAccountName: accountFilterName,
              accountNameMap: accountNameMap,
              totalIncome: income,
              totalExpense: expense,
              groupingType: _viewByBucket ? "Bucket" : "Category",
            ),
          );
        },
      ),
    );
  }

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

    return GestureDetector(
      onTap: () => _showAccountSelectionSheet(accounts, cards),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getAccountDisplayText(_selectedAccountId, accounts, cards),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return GestureDetector(
      onTap: _showTimeSelectionSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedRange == 'Custom Range' && _customDateRange != null
                  ? "${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}"
                  : _selectedRange,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
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
        if (percentage < 0.75) {
          color = const Color(0xFF00E676);
        } else if (percentage < 1.0) {
          color = Colors.orangeAccent;
        } else {
          color = Colors.redAccent;
        }
      } else {
        statusLabel = "Over: ${fmt.format(remaining.abs())}";
        color = const Color(0xFFFF4D6D);
      }
    } else {
      percentage = totalAmount > 0 ? (item.totalAmount / totalAmount) : 0.0;
      color = _showIncome ? const Color(0xFF00E676) : const Color(0xFF00B4D8);
      statusLabel = "${(percentage * 100).toStringAsFixed(2)}% of total";
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
                                        "${item.trendPercentage!.abs().toStringAsFixed(2)}%",
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

  // ===========================================================================
  // --- BOTTOM SHEETS & LIST HELPERS ---
  // ===========================================================================

  String _getAccountDisplayText(String? id, List<ExpenseAccountModel> accounts,
      List<CreditCardModel> cards) {
    if (id == null) return "All Accounts";
    if (id == kGroupBanks) return "All Bank Accounts";
    if (id == kGroupCredits) return "All Credit Cards";

    final acc = accounts.firstWhereOrNull((a) => a.id == id);
    if (acc != null) return "${acc.name} (${acc.bankName})";

    final card = cards.firstWhereOrNull((c) => c.id == id);
    if (card != null) return "${card.name} (${card.bankName})";

    return "Unknown Account";
  }

  Widget _buildEnhancedListTile({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00B4D8).withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B4D8).withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00B4D8) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF00B4D8), size: 20)
            else
              const Icon(Icons.circle_outlined,
                  color: Colors.white12, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountListHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showTimeSelectionSheet() {
    final periods = [
      'This Month',
      'Last Month',
      'This Year',
      'Last Year',
      'All Time',
      'Custom Range'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF151D29).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Period",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: periods.map((p) {
                    return _buildEnhancedListTile(
                      title: p,
                      isSelected: _selectedRange == p,
                      icon: Icons.calendar_today_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        if (p == 'Custom Range') {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _pickDateRange());
                        } else {
                          setState(() => _selectedRange = p);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountSelectionSheet(
      List<ExpenseAccountModel> accounts, List<CreditCardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151D29).withOpacity(0.9),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white54, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        children: [
                          _buildEnhancedListTile(
                            title: "All Accounts",
                            isSelected: _selectedAccountId == null,
                            icon: Icons.account_balance_wallet_rounded,
                            onTap: () {
                              setState(() => _selectedAccountId = null);
                              Navigator.pop(context);
                            },
                          ),
                          if (accounts.isNotEmpty) ...[
                            _buildAccountListHeader("BANK ACCOUNTS"),
                            _buildEnhancedListTile(
                              title: "All Bank Accounts",
                              isSelected: _selectedAccountId == kGroupBanks,
                              icon: Icons.account_balance_rounded,
                              onTap: () {
                                setState(
                                    () => _selectedAccountId = kGroupBanks);
                                Navigator.pop(context);
                              },
                            ),
                            ...accounts.map((acc) => _buildEnhancedListTile(
                                  title: "${acc.name} (${acc.bankName})",
                                  isSelected: _selectedAccountId == acc.id,
                                  icon: Icons.account_balance_rounded,
                                  onTap: () {
                                    setState(() => _selectedAccountId = acc.id);
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                          if (cards.isNotEmpty) ...[
                            _buildAccountListHeader("CREDIT CARDS"),
                            _buildEnhancedListTile(
                              title: "All Credit Cards",
                              isSelected: _selectedAccountId == kGroupCredits,
                              icon: Icons.credit_card_rounded,
                              onTap: () {
                                setState(
                                    () => _selectedAccountId = kGroupCredits);
                                Navigator.pop(context);
                              },
                            ),
                            ...cards.map((card) => _buildEnhancedListTile(
                                  title: "${card.name} (${card.bankName})",
                                  isSelected: _selectedAccountId == card.id,
                                  icon: Icons.credit_card_rounded,
                                  onTap: () {
                                    setState(
                                        () => _selectedAccountId = card.id);
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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

// -----------------------------------------------------------------------------
// --- [UPDATED SPACE-OPTIMIZED READ-ONLY WIDGETS] ---
// -----------------------------------------------------------------------------

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

    final bool hasSubcategory = widget.txn.subCategory.isNotEmpty &&
        widget.txn.subCategory != 'General';
    final bool hasBucket = isExpense && widget.txn.bucket.isNotEmpty;

    // Calculate max width to prevent absolute overflow
    final maxTextWidth = MediaQuery.of(context).size.width *
        0.40; // Slightly smaller since it's nested inside expansion tiles

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // [SPACE OPTIMIZATION]
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              : [],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              fontSize: 14)),

                      // --- [RESPONSIVE WRAP LOGIC] ---
                      if (hasSubcategory ||
                          hasBucket ||
                          widget.sourceAccountName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // 1. Subcategory
                              if (hasSubcategory)
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: maxTextWidth),
                                  child: Text(
                                    widget.txn.subCategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 11),
                                  ),
                                ),

                              // 2. Bucket Tag
                              if (hasBucket)
                                _buildTag(widget.txn.bucket, maxTextWidth),

                              // 3. Source Account Name
                              if (widget.sourceAccountName != null)
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: maxTextWidth),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    widget.sourceAccountName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$sign ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),

            // Animated Expanded Details
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              // Collapsed state is completely empty to save maximum space
              firstChild: const SizedBox(width: double.infinity, height: 0),

              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // --- [RESPONSIVE EXPANDED ROW FIX] ---
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy, hh:mm a')
                              .format(widget.txn.date),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12),
                        ),
                        if (hasBucket)
                          _buildTag(
                              "Bucket: ${widget.txn.bucket}", maxTextWidth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notes
                  if (widget.txn.notes.isNotEmpty) ...[
                    Text("Notes:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                  // Intentionally removed action buttons (Edit/Delete) for read-only view
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, double maxWidth) => Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w600)));
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

    final bool hasSubcategory = widget.txn.subCategory.isNotEmpty &&
        widget.txn.subCategory != 'General';
    final bool hasBucket = widget.txn.bucket.isNotEmpty;

    // Calculate max width to prevent absolute overflow
    final maxTextWidth = MediaQuery.of(context).size.width * 0.40;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // [SPACE OPTIMIZATION]
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              : [],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              fontSize: 14)),

                      // --- [RESPONSIVE WRAP LOGIC] ---
                      if (hasSubcategory ||
                          hasBucket ||
                          widget.cardName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // 1. Subcategory
                              if (hasSubcategory)
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: maxTextWidth),
                                  child: Text(
                                    widget.txn.subCategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 11),
                                  ),
                                ),

                              // 2. Bucket Tag
                              if (hasBucket)
                                _buildTag(widget.txn.bucket, maxTextWidth),

                              // 3. Card Name
                              if (widget.cardName != null)
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: maxTextWidth),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    widget.cardName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$sign ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),

            // Animated Expanded Details
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              // Collapsed state is completely empty to save maximum space
              firstChild: const SizedBox(width: double.infinity, height: 0),

              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // --- [RESPONSIVE EXPANDED ROW FIX] ---
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy, hh:mm a')
                              .format(widget.txn.date),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12),
                        ),
                        if (hasBucket)
                          _buildTag(
                              "Bucket: ${widget.txn.bucket}", maxTextWidth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notes
                  if (widget.txn.notes.isNotEmpty) ...[
                    Text("Notes:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                  // Intentionally removed action buttons (Edit/Delete) for read-only view
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, double maxWidth) => Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w600)));
}
