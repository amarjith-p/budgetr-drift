import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class CategorySpendingChart extends StatefulWidget {
  const CategorySpendingChart({super.key});

  @override
  State<CategorySpendingChart> createState() => _CategorySpendingChartState();
}

class _CategorySpendingChartState extends State<CategorySpendingChart> {
  final ExpenseService _service = ExpenseService();

  // State
  String _selectedRange = '1M';
  String? _selectedAccountId;
  int _touchedIndex = -1;

  // Colors for categories (Prism Palette)
  final List<Color> _categoryColors = [
    const Color(0xFF00B4D8), // Cyan
    const Color(0xFF00E676), // Neon Green
    const Color(0xFFFF4D6D), // Pink/Red
    const Color(0xFFFFB703), // Amber
    const Color(0xFF7209B7), // Purple
    const Color(0xFF4361EE), // Blue
    const Color(0xFFF72585), // Magenta
    const Color(0xFF4CC9F0), // Light Cyan
  ];

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case '1W':
        return now.subtract(const Duration(days: 7));
      case '1M':
        return DateTime(now.year, now.month - 1, now.day);
      case '3M':
        return DateTime(now.year, now.month - 3, now.day);
      case '6M':
        return DateTime(now.year, now.month - 6, now.day);
      case '1Y':
        return DateTime(now.year - 1, now.month, now.day);
      case 'ALL':
        return DateTime(2000);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatter for 2 decimal places (Used in Center Text & Legend)
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(24),
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
          // --- Header & Filters ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Column
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SPENDING BREAKDOWN",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "By Category",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Account Filter
              // Expanded forces dropdown to respect remaining space
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildAccountFilter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Time Range Filter
          _buildTimeRangeSelector(),

          const SizedBox(height: 32),

          // --- Chart & Data ---
          StreamBuilder<List<ExpenseTransactionModel>>(
            // [UPDATED] Uses optimized service method with Server-Side Filtering
            stream: _service.getTransactions(accountId: _selectedAccountId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: ModernLoader());

              final data = _processData(snapshot.data!);

              if (data.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text("No expenses for this period",
                        style: TextStyle(color: Colors.white54)),
                  ),
                );
              }

              final double totalSpent = data.fold(0, (sum, e) => sum + e.value);

              return Column(
                children: [
                  // Donut Chart
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
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 65,
                            sections: _buildSections(data, totalSpent),
                          ),
                        ),
                        // Center Text
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
                              // [UPDATED] Use 2 Decimal Formatter here
                              Text(
                                currencyFmt.format(totalSpent),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      18, // Reduced slightly to fit long numbers
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

                  // Legend List
                  ...data
                      .map((e) => _buildLegendItem(e, totalSpent, currencyFmt))
                      .toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Logic Helpers ---

  List<CategoryData> _processData(List<ExpenseTransactionModel> txns) {
    final startDate = _getStartDate();

    // [UPDATED] Removed client-side filtering for accountId.
    // Firestore now returns only the relevant transactions.
    final filtered = txns.where((t) {
      if (t.type != 'Expense') return false;
      return t.date.toDate().isAfter(startDate);
    });

    final grouped =
        groupBy(filtered, (ExpenseTransactionModel t) => t.category);

    final List<CategoryData> result = [];
    int colorIndex = 0;

    grouped.forEach((category, list) {
      final sum = list.fold(0.0, (prev, curr) => prev + curr.amount);
      result.add(CategoryData(
        name: category,
        value: sum,
        color: _categoryColors[colorIndex % _categoryColors.length],
      ));
      colorIndex++;
    });

    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  List<PieChartSectionData> _buildSections(
      List<CategoryData> data, double total) {
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

  // --- UI Components ---

  Widget _buildLegendItem(
      CategoryData data, double total, NumberFormat formatter) {
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
          // Amount (2 Decimal)
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

  Widget _buildTimeRangeSelector() {
    final ranges = ['1W', '1M', '3M', '6M', '1Y', 'ALL'];
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ranges.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRange = range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF00B4D8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountFilter() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _service.getAccounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final accounts = snapshot.data!;
        if (_selectedAccountId != null &&
            !accounts.any((a) => a.id == _selectedAccountId)) {
          _selectedAccountId = null;
        }

        return Container(
          height: 28,
          constraints: const BoxConstraints(maxWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedAccountId,
              dropdownColor: const Color(0xFF1B263B),
              icon: const Icon(Icons.filter_list_rounded,
                  color: Colors.white54, size: 14),
              style: const TextStyle(color: Colors.white, fontSize: 11),
              isDense: true,
              isExpanded: true,
              hint: const Text(
                "All Accounts",
                style: TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Accounts"),
                ),
                ...accounts.map((acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Text(
                        "${acc.name} - ${acc.bankName}",
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
      },
    );
  }
}

class CategoryData {
  final String name;
  final double value;
  final Color color;

  CategoryData({required this.name, required this.value, required this.color});
}
