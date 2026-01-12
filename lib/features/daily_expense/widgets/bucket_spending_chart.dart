import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';

class BucketSpendingChart extends StatefulWidget {
  const BucketSpendingChart({super.key});

  @override
  State<BucketSpendingChart> createState() => _BucketSpendingChartState();
}

class _BucketSpendingChartState extends State<BucketSpendingChart> {
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();

  // State
  String _selectedPeriod = 'This Month';
  String? _selectedAccountId;
  int _touchedIndex = -1;
  bool _isBudgetMode = false;

  // Constants for group filters
  static const String kGroupBanks = 'group_banks';
  static const String kGroupCredits = 'group_credits';

  // Distinct Color Palette for Buckets (slightly different from Categories to distinguish visually)
  final List<Color> _bucketColors = [
    const Color(0xFF4CC9F0), // Sky Blue
    const Color(0xFF7209B7), // Deep Purple
    const Color(0xFFF72585), // Magenta
    const Color(0xFFFFB703), // Amber
    const Color(0xFF4361EE), // Royal Blue
    const Color(0xFF00E676), // Neon Green
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    final String? fetchId = (_selectedAccountId == kGroupBanks ||
            _selectedAccountId == kGroupCredits)
        ? null
        : _selectedAccountId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ALLOCATION",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "By Bucket",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildModernToggle(),
            ],
          ),
          const SizedBox(height: 16),

          // --- FILTERS ---
          Row(
            children: [
              Expanded(child: _buildAccountFilter()),
              const SizedBox(width: 8),
              _buildPeriodDropdown(),
            ],
          ),
          const SizedBox(height: 32),

          // --- CHART DATA ---
          StreamBuilder<List<ExpenseTransactionModel>>(
            stream: _expenseService.getTransactions(accountId: fetchId),
            builder: (context, expenseSnapshot) {
              return StreamBuilder<List<CreditTransactionModel>>(
                  stream: fetchId == null
                      ? _creditService.getAllTransactions()
                      : _creditService.getTransactionsForCard(fetchId),
                  builder: (context, creditSnapshot) {
                    if (!expenseSnapshot.hasData && !creditSnapshot.hasData) {
                      return const Center(child: ModernLoader());
                    }

                    final expenses = expenseSnapshot.data ?? [];
                    final credits = creditSnapshot.data ?? [];

                    final data = _processData(expenses, credits);

                    if (data.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text("No data for this period",
                              style: TextStyle(color: Colors.white54)),
                        ),
                      );
                    }

                    final double totalSpent =
                        data.fold(0, (sum, e) => sum + e.value);

                    return Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 4, // More spacing for buckets
                                  centerSpaceRadius: 65,
                                  sections: _buildSections(data, totalSpent),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Total",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFmt.format(totalSpent),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        ...data
                            .map((e) =>
                                _buildLegendItem(e, totalSpent, currencyFmt))
                            .toList(),
                      ],
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  // --- LOGIC HELPERS ---

  bool _matchesPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Month':
        return date.year == now.year && date.month == now.month;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return date.year == lastMonth.year && date.month == lastMonth.month;
      case 'This Year':
        return date.year == now.year;
      case 'Last Year':
        return date.year == now.year - 1;
      case 'All Time':
        return true;
      default:
        return true;
    }
  }

  List<BucketData> _processData(List<ExpenseTransactionModel> expenses,
      List<CreditTransactionModel> credits) {
    List<dynamic> combined = [];

    // 1. Bank Expenses
    if (_selectedAccountId != kGroupCredits) {
      combined.addAll(expenses.where((t) {
        if (_selectedAccountId != null &&
            _selectedAccountId != kGroupBanks &&
            t.accountId != _selectedAccountId) return false;

        if (t.type != 'Expense') return false;
        if (!_matchesPeriod(t.date.toDate())) return false;

        if (_isBudgetMode) {
          if (t.bucket == 'Out of Bucket') return false;
          if (t.category == 'Non-Calculated Expense') return false;
        }

        return true;
      }));
    }

    // 2. Credit Expenses
    if (_selectedAccountId != kGroupBanks) {
      combined.addAll(credits.where((t) {
        if (_selectedAccountId != null &&
            _selectedAccountId != kGroupCredits &&
            t.cardId != _selectedAccountId) return false;

        if (t.type != 'Expense') return false;
        if (!_matchesPeriod(t.date.toDate())) return false;

        if (_isBudgetMode) {
          if (t.bucket == 'Out of Bucket') return false;
          if (t.category == 'Non-Calculated Expense') return false;
        }

        return true;
      }));
    }

    final Map<String, double> bucketSums = {};

    for (var txn in combined) {
      // Access 'bucket' dynamically or via casting if models share common interface
      // Assuming models have .bucket getter based on your code
      final String bucket = (txn is ExpenseTransactionModel)
          ? txn.bucket
          : (txn as CreditTransactionModel).bucket;

      final double amount = (txn is ExpenseTransactionModel)
          ? txn.amount
          : (txn as CreditTransactionModel).amount;

      if (bucketSums.containsKey(bucket)) {
        bucketSums[bucket] = bucketSums[bucket]! + amount;
      } else {
        bucketSums[bucket] = amount;
      }
    }

    final List<BucketData> result = [];
    int colorIndex = 0;

    bucketSums.forEach((bucket, sum) {
      result.add(BucketData(
        name: bucket,
        value: sum,
        color: _bucketColors[colorIndex % _bucketColors.length],
      ));
      colorIndex++;
    });

    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  // --- WIDGET BUILDERS (Reused Styles) ---

  Widget _buildModernToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _isBudgetMode = !_isBudgetMode);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Budget Mode",
            style: TextStyle(
              color: _isBudgetMode ? const Color(0xFF00B4D8) : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 40,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _isBudgetMode
                  ? const Color(0xFF00B4D8).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: _isBudgetMode
                    ? const Color(0xFF00B4D8)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  left: _isBudgetMode ? 20 : 2,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBudgetMode
                          ? const Color(0xFF00B4D8)
                          : Colors.white38,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white54, size: 16),
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          isDense: true,
          items: [
            'This Month',
            'Last Month',
            'This Year',
            'Last Year',
            'All Time'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPeriod = val);
          },
        ),
      ),
    );
  }

  Widget _buildAccountFilter() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _expenseService.getAccounts(),
      builder: (context, expenseSnapshot) {
        return StreamBuilder<List<CreditCardModel>>(
            stream: _creditService.getCreditCards(),
            builder: (context, creditSnapshot) {
              final accounts = expenseSnapshot.data ?? [];
              final cards = creditSnapshot.data ?? [];

              if (_selectedAccountId != null &&
                  _selectedAccountId != kGroupBanks &&
                  _selectedAccountId != kGroupCredits) {
                bool exists = accounts.any((a) => a.id == _selectedAccountId) ||
                    cards.any((c) => c.id == _selectedAccountId);
                if (!exists) _selectedAccountId = null;
              }

              return Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedAccountId,
                    dropdownColor: const Color(0xFF1B263B),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54, size: 16),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    isDense: true,
                    isExpanded: true,
                    hint: const Text(
                      "All Accounts",
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text("All Accounts"),
                      ),
                      if (accounts.isNotEmpty)
                        const DropdownMenuItem<String?>(
                          enabled: false,
                          value: 'header_bank',
                          child: Text("BANK ACCOUNTS",
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      if (accounts.isNotEmpty)
                        const DropdownMenuItem<String?>(
                          value: kGroupBanks,
                          child: Text("All Bank Accounts",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ...accounts.map((acc) => DropdownMenuItem(
                            value: acc.id,
                            child: Text(
                              "${acc.name} ( ${acc.bankName} )",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )),
                      if (cards.isNotEmpty)
                        const DropdownMenuItem<String?>(
                          enabled: false,
                          value: 'header_credit',
                          child: Text("CREDIT CARDS",
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      if (cards.isNotEmpty)
                        const DropdownMenuItem<String?>(
                          value: kGroupCredits,
                          child: Text("All Credit Cards",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ...cards.map((card) => DropdownMenuItem(
                            value: card.id,
                            child: Text(
                              "${card.name} ( ${card.bankName} )",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedAccountId = val);
                    },
                  ),
                ),
              );
            });
      },
    );
  }

  List<PieChartSectionData> _buildSections(
      List<BucketData> data, double total) {
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final double radius = isTouched ? 35.0 : 25.0;

      return PieChartSectionData(
        color: data[i].color,
        value: data[i].value,
        title: '${((data[i].value / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: isTouched || (data[i].value / total > 0.1),
      );
    });
  }

  Widget _buildLegendItem(
      BucketData data, double total, NumberFormat formatter) {
    final percentage = (data.value / total) * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: data.color.withOpacity(0.4), blurRadius: 4)
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 50,
            child: Stack(
              children: [
                Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(2))),
                FractionallySizedBox(
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                          color: data.color,
                          borderRadius: BorderRadius.circular(2))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatter.format(data.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BucketData {
  final String name;
  final double value;
  final Color color;

  BucketData({required this.name, required this.value, required this.color});
}
