import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/models/settlement_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/widgets/date_filter_row.dart';
import '../services/settlement_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settings/services/settings_service.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final _settlementService = SettlementService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // Theme Constants
  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.6);

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  bool _isLoading = false;
  Settlement? _settlementData;
  PercentageConfig? _percentageConfig;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _settlementService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;

    _percentageConfig = await _settingsService.getPercentageConfig();

    final now = DateTime.now();
    if (_availableYears.contains(now.year)) {
      _selectedYear = now.year;
      final months = _yearMonthData
          .where((data) => data['year'] == now.year)
          .map((data) => data['month']!)
          .toSet()
          .toList();
      months.sort((a, b) => b.compareTo(a));
      _availableMonthsForYear = months;
      if (_availableMonthsForYear.contains(now.month)) {
        _selectedMonth = now.month;
      }
    }
    setState(() {});
  }

  void _onYearSelected(int? year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
      _settlementData = null;
      if (year != null) {
        final months = _yearMonthData
            .where((d) => d['year'] == year)
            .map((d) => d['month']!)
            .toSet()
            .toList();
        months.sort((a, b) => b.compareTo(a));
        _availableMonthsForYear = months;
      } else {
        _availableMonthsForYear = [];
      }
    });
  }

  Future<void> _fetchSettlementData() async {
    HapticFeedback.lightImpact();
    if (_selectedYear == null || _selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year and month.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _settlementData = null;
    });
    final recordId =
        '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';
    final settlement = await _settlementService.getSettlementById(recordId);
    setState(() {
      _settlementData = settlement;
      _isLoading = false;
    });
  }

  void _showSettlementInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettlementInputSheet(),
    ).then((_) {
      if (_selectedYear != null && _selectedMonth != null) {
        _fetchSettlementData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settlement Analysis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: DateFilterRow(
                selectedYear: _selectedYear,
                selectedMonth: _selectedMonth,
                availableYears: _availableYears,
                availableMonths: _availableMonthsForYear,
                onYearSelected: _onYearSelected,
                onMonthSelected: (val) => setState(() => _selectedMonth = val),
                showRefresh: false,
              ),
            ),

            const SizedBox(height: 24),

            // --- COMPACT FETCH BUTTON ---
            Center(
              child: GestureDetector(
                onTap: _fetchSettlementData,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentColor, const Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'FETCH DATA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),

      // --- FLOATING GLASS CAPSULE (REPLACES FAB) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: _showSettlementInputSheet,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accentColor, const Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_note_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                "Update Settlement",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: ModernLoader());
    }
    if (_settlementData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a month & fetch data\nto view analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Allocation vs. Expense',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: _buildSettlementChart(_settlementData!),
                ),
                const SizedBox(height: 16),
                _buildChartLegend(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Settlement Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildSettlementTable(_settlementData!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementChart(Settlement data) {
    final keys = data.allocations.keys.toList();
    if (_percentageConfig != null) {
      keys.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere((c) => c.name == a);
        int idxB = _percentageConfig!.categories.indexWhere((c) => c.name == b);
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      keys.sort(
        (a, b) =>
            (data.allocations[b] ?? 0).compareTo(data.allocations[a] ?? 0),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(keys.length, (index) {
          final key = keys[index];
          final allocated = data.allocations[key] ?? 0.0;
          final spent = data.expenses[key] ?? 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: allocated,
                color: const Color(0xFF3A86FF),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: spent,
                color: const Color(0xFFFF006E),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                  String text = keys[value.toInt()];
                  if (text.length > 3) text = text.substring(0, 3);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      text.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF3A86FF), 'Allocated'),
        const SizedBox(width: 24),
        _legendItem(const Color(0xFFFF006E), 'Spent'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSettlementTable(Settlement data) {
    final entries = data.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    List<DataRow> rows = [];

    for (var entry in entries) {
      final key = entry.key;
      final allocated = entry.value;
      final spent = data.expenses[key] ?? 0.0;
      final balance = allocated - spent;
      rows.add(_createDataRow(key, allocated, spent, balance));
    }

    rows.add(
      DataRow(
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          DataCell(
            Text(
              _currencyFormat.format(data.totalIncome),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format(data.totalExpense),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currencyFormat.format(data.totalBalance),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: data.totalBalance >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return DataTable(
      headingRowColor: MaterialStateProperty.all(
        Colors.white.withOpacity(0.05),
      ),
      columnSpacing: 20,
      columns: [
        DataColumn(
          label: Text(
            'Bucket',
            style: TextStyle(fontWeight: FontWeight.bold, color: _accentColor),
          ),
        ),
        DataColumn(
          label: Text(
            'Allocated',
            style: TextStyle(fontWeight: FontWeight.bold, color: _accentColor),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Spent / Bal',
            style: TextStyle(fontWeight: FontWeight.bold, color: _accentColor),
          ),
          numeric: true,
        ),
      ],
      rows: rows,
    );
  }

  DataRow _createDataRow(
    String category,
    double allocated,
    double spent,
    double balance,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(category, style: const TextStyle(color: Colors.white70))),
        DataCell(
          Text(
            _currencyFormat.format(allocated),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(spent),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                _currencyFormat.format(balance),
                style: TextStyle(
                  fontSize: 11,
                  color: balance >= 0
                      ? Colors.greenAccent.withOpacity(0.7)
                      : Colors.redAccent.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettlementInputSheet extends StatefulWidget {
  const SettlementInputSheet({super.key});

  @override
  State<SettlementInputSheet> createState() => _SettlementInputSheetState();
}

class _SettlementInputSheetState extends State<SettlementInputSheet> {
  final _settlementService = SettlementService();
  final _dashboardService = DashboardService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // --- SCROLL CONTROLLER ADDED ---
  final ScrollController _scrollController = ScrollController();

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  FinancialRecord? _budgetRecord;
  Settlement? _existingSettlement;
  PercentageConfig? _percentageConfig;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  double _totalExpense = 0.0;
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) controller.dispose();
    for (var node in _focusNodes.values) node.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _settlementService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;
    _percentageConfig = await _settingsService.getPercentageConfig();

    final now = DateTime.now();
    if (_availableYears.contains(now.year)) {
      _selectedYear = now.year;
      final months = _yearMonthData
          .where((data) => data['year'] == now.year)
          .map((data) => data['month']!)
          .toSet()
          .toList();
      months.sort((a, b) => b.compareTo(a));
      _availableMonthsForYear = months;
      if (_availableMonthsForYear.contains(now.month)) {
        _selectedMonth = now.month;
      }
    }
    setState(() {});
  }

  void _onYearSelected(int? year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
      _budgetRecord = null;
      _controllers.clear();
      if (year != null) {
        final months = _yearMonthData
            .where((d) => d['year'] == year)
            .map((d) => d['month']!)
            .toSet()
            .toList();
        months.sort((a, b) => b.compareTo(a));
        _availableMonthsForYear = months;
      } else {
        _availableMonthsForYear = [];
      }
    });
  }

  Future<void> _fetchData() async {
    if (_selectedYear == null || _selectedMonth == null) return;
    final recordId =
        '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';

    try {
      final results = await Future.wait([
        _dashboardService.getRecordById(recordId),
        _settlementService.getSettlementById(recordId),
      ]);

      setState(() {
        _budgetRecord = results[0] as FinancialRecord;
        _existingSettlement = results[1] as Settlement?;

        _controllers.clear();
        _focusNodes.clear();

        _budgetRecord!.allocations.forEach((key, _) {
          double initialValue = 0.0;
          if (_existingSettlement != null &&
              _existingSettlement!.expenses.containsKey(key)) {
            initialValue = _existingSettlement!.expenses[key]!;
          }
          final ctrl = TextEditingController(
            text: initialValue == 0 ? '' : initialValue.toString(),
          );
          ctrl.addListener(_calculateTotalExpense);
          _controllers[key] = ctrl;
          _focusNodes[key] = FocusNode();
        });

        _calculateTotalExpense();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  void _calculateTotalExpense() {
    double sum = 0.0;
    for (var ctrl in _controllers.values) {
      sum += double.tryParse(ctrl.text) ?? 0.0;
    }
    setState(() => _totalExpense = sum);
  }

  // --- AUTO SCROLL LOGIC ---
  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
    // Trigger scroll
    _scrollToInput(node);
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == null) return;

    final entries = _budgetRecord!.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    int currentIndex = -1;
    for (int i = 0; i < entries.length; i++) {
      if (_controllers[entries[i].key] == _activeController) {
        currentIndex = i;
        break;
      }
    }

    if (currentIndex != -1 && currentIndex < entries.length - 1) {
      final nextKey = entries[currentIndex + 1].key;
      _setActive(_controllers[nextKey]!, _focusNodes[nextKey]!);
    } else {
      _closeKeyboard();
    }
  }

  Future<void> _onSettle() async {
    _closeKeyboard();
    if (_budgetRecord == null) return;

    Map<String, double> expenses = {};
    _controllers.forEach((key, ctrl) {
      expenses[key] = double.tryParse(ctrl.text) ?? 0.0;
    });

    final settlement = Settlement(
      id: _budgetRecord!.id,
      year: _budgetRecord!.year,
      month: _budgetRecord!.month,
      allocations: _budgetRecord!.allocations,
      expenses: expenses,
      totalIncome: _budgetRecord!.effectiveIncome,
      totalExpense: _totalExpense,
      settledAt: Timestamp.now(),
    );

    try {
      await _settlementService.saveSettlement(settlement);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure bottom sheet works with system keyboard if needed
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: const Color(0xff0D1B2A), // Dark BG for sheet
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Expanded Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: ModernDropdownPill<int>(
                          label: _selectedYear?.toString() ?? 'Year',
                          isActive: _selectedYear != null,
                          icon: Icons.calendar_today_outlined,
                          onTap: () => showSelectionSheet<int>(
                            context: context,
                            title: 'Select Year',
                            items: _availableYears,
                            labelBuilder: (y) => y.toString(),
                            onSelect: _onYearSelected,
                            selectedItem: _selectedYear,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernDropdownPill<int>(
                          label: _selectedMonth != null
                              ? DateFormat(
                                  'MMMM',
                                ).format(DateTime(0, _selectedMonth!))
                              : 'Month',
                          isActive: _selectedMonth != null,
                          icon: Icons.calendar_view_month_outlined,
                          isEnabled: _selectedYear != null,
                          onTap: () => showSelectionSheet<int>(
                            context: context,
                            title: 'Select Month',
                            items: _availableMonthsForYear,
                            labelBuilder: (m) =>
                                DateFormat('MMMM').format(DateTime(0, m)),
                            onSelect: (val) =>
                                setState(() => _selectedMonth = val),
                            selectedItem: _selectedMonth,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.downloading,
                          color: Colors.white70,
                        ),
                        onPressed: _fetchData,
                        tooltip: 'Fetch Budget Data',
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.white24),

                  // Form List
                  Expanded(
                    child: _budgetRecord == null
                        ? Center(
                            child: Text(
                              'Select a month and fetch data to begin.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          )
                        : _buildSettlementForm(),
                  ),
                ],
              ),
            ),
          ),

          // --- STICKY BAR ---
          if (_budgetRecord != null) _buildStickyBottomBar(),

          // Keyboard (Bottom Edge)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeController!,
                      v,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(_activeController!),
                    onClear: () => _activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeController!),
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystemKeyboard,
                    onNext: _handleNext,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    final income = _budgetRecord!.effectiveIncome;
    final balance = income - _totalExpense;
    final isOverBudget = balance < 0;
    final progress = income > 0
        ? (_totalExpense / income).clamp(0.0, 1.0)
        : 0.0;

    // Status Color
    final statusColor = isOverBudget
        ? const Color(0xFFFF5252)
        : const Color(0xFF00E676);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff0D1B2A), // Dark BG
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Spent: ${_currencyFormat.format(_totalExpense)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isOverBudget
                    ? "Over by ${_currencyFormat.format(balance.abs())}"
                    : "Left: ${_currencyFormat.format(balance)}",
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSettle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Settle Budget',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm() {
    final entries = _budgetRecord!.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    return GestureDetector(
      onTap: _closeKeyboard,
      child: ListView.builder(
        // ATTACH THE SCROLL CONTROLLER
        controller: _scrollController,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildSettlementRow(
            title: entry.key,
            allocated: entry.value,
            controller: _controllers[entry.key]!,
          );
        },
      ),
    );
  }

  Widget _buildSettlementRow({
    required String title,
    required double allocated,
    required TextEditingController controller,
  }) {
    if (!_focusNodes.containsKey(title)) _focusNodes[title] = FocusNode();
    final focusNode = _focusNodes[title]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Allocated: ${_currencyFormat.format(allocated)}',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: SizedBox(
          width: 140,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: !_useSystemKeyboard,
            showCursor: true, // Show Cursor
            textAlign: TextAlign.end,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onTap: () => _setActive(controller, focusNode),
          ),
        ),
      ),
    );
  }
}
