import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../../core/models/financial_record_model.dart';
import '../../../core/models/settlement_model.dart';
import '../../../core/services/firestore_service.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final _firestoreService = FirestoreService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  bool _isLoading = false;
  Settlement? _settlementData;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _firestoreService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;

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
    final settlement = await _firestoreService.getSettlementById(recordId);
    setState(() {
      _settlementData = settlement;
      _isLoading = false;
    });
  }

  void _showSettlementInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
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
      appBar: AppBar(title: const Text('Settlement Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                const SizedBox(width: 16),
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
                      onSelect: (val) => setState(() => _selectedMonth = val),
                      selectedItem: _selectedMonth,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchSettlementData,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Fetch Settlement Data'),
              ),
            ),
            const Divider(height: 32),
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSettlementInputSheet,
        icon: const Icon(Icons.edit_document),
        label: const Text('Enter/Edit Settlement'),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_settlementData == null) {
      return const Center(
        child: Text(
          'No data fetched or settlement not found for the selected month.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        children: [
          Text(
            'Allocation vs. Expense',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              SizedBox(
                height: 300,
                child: _buildSettlementChart(_settlementData!),
              ),
              const SizedBox(height: 12),
              _buildChartLegend(),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Settlement Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildSettlementTable(_settlementData!),
        ],
      ),
    );
  }

  Widget _buildSettlementChart(Settlement data) {
    final keys = data.allocations.keys.toList()
      ..sort(
        (a, b) =>
            (data.allocations[b] ?? 0).compareTo(data.allocations[a] ?? 0),
      );

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
              BarChartRodData(toY: allocated, color: Colors.blue, width: 12),
              BarChartRodData(toY: spent, color: Colors.red, width: 12),
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
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compactCurrency(symbol: '₹').format(value),
                  style: const TextStyle(fontSize: 10),
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
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
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
        _legendItem(Colors.blue, 'Allocated'),
        const SizedBox(width: 24),
        _legendItem(Colors.red, 'Spent'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildSettlementTable(Settlement data) {
    final sortedEntries = data.allocations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<DataRow> rows = [];

    for (var entry in sortedEntries) {
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
            Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataCell(
            Text(
              _currencyFormat.format(data.totalIncome),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format(data.totalExpense),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _currencyFormat.format(data.totalBalance),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: data.totalBalance >= 0
                        ? Colors.green.shade400
                        : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return DataTable(
      columnSpacing: 20,
      columns: const [
        DataColumn(
          label: Text('Bucket', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Allocated',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Spent / Bal',
            style: TextStyle(fontWeight: FontWeight.bold),
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
        DataCell(Text(category)),
        DataCell(Text(_currencyFormat.format(allocated))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currencyFormat.format(spent)),
              Text(
                _currencyFormat.format(balance),
                style: TextStyle(
                  fontSize: 12,
                  color: balance >= 0
                      ? Colors.green.shade400
                      : Colors.red.shade400,
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
  final _firestoreService = FirestoreService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  FinancialRecord? _budgetRecord;
  Settlement? _existingSettlement;

  final Map<String, TextEditingController> _controllers = {};
  double _totalExpense = 0.0;

  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _firestoreService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;

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
        _firestoreService.getRecordById(recordId),
        _firestoreService.getSettlementById(recordId),
      ]);

      setState(() {
        _budgetRecord = results[0] as FinancialRecord;
        _existingSettlement = results[1] as Settlement?;

        _controllers.clear();
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

  Future<void> _onSettle() async {
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
      await _firestoreService.saveSettlement(settlement);
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

  void _handleKeyPress(String value) {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, value);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + value.length,
      ),
    );
  }

  void _handleBackspace() {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    if (selection.baseOffset > 0) {
      final newText = text.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    }
  }

  void _handleClear() {
    if (_activeController == null) return;
    _activeController!.clear();
  }

  void _handleEquals() {
    if (_activeController == null || _activeController!.text.isEmpty) return;

    String expression = _activeController!.text
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      _activeController!.text = result.toStringAsFixed(2);
      _activeController!.selection = TextSelection.fromPosition(
        TextPosition(offset: _activeController!.text.length),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Expression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              const SizedBox(width: 16),
              Expanded(
                child: ModernDropdownPill<int>(
                  label: _selectedMonth != null
                      ? DateFormat('MMMM').format(DateTime(0, _selectedMonth!))
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
                    onSelect: (val) => setState(() => _selectedMonth = val),
                    selectedItem: _selectedMonth,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.downloading),
                onPressed: _fetchData,
                tooltip: 'Fetch Budget Data',
              ),
            ],
          ),
          const Divider(height: 32),
          Flexible(
            child: _budgetRecord == null
                ? const Center(
                    child: Text('Select a month and fetch data to begin.'),
                  )
                : _buildSettlementForm(),
          ),
          if (_budgetRecord != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _onSettle,
                    child: const Text('Settle'),
                  ),
                ],
              ),
            ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isKeyboardVisible
                ? _CalculatorKeyboard(
                    onKeyPress: _handleKeyPress,
                    onBackspace: _handleBackspace,
                    onClear: _handleClear,
                    onEquals: _handleEquals,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm() {
    final totalBalance = _budgetRecord!.effectiveIncome - _totalExpense;

    final sortedEntries = _budgetRecord!.allocations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GestureDetector(
      onTap: () => setState(() => _isKeyboardVisible = false),
      child: ListView(
        children: [
          ...sortedEntries.map((entry) {
            return _buildSettlementRow(
              title: entry.key,
              allocated: entry.value,
              controller: _controllers[entry.key]!,
            );
          }),

          const Divider(),
          ListTile(
            title: Text(
              'Total Income (Effective)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            subtitle: Text(
              _currencyFormat.format(_budgetRecord!.effectiveIncome),
              style: const TextStyle(fontSize: 16),
            ),
            trailing: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Expense',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _currencyFormat.format(_totalExpense),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Overall Balance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              _currencyFormat.format(totalBalance),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0 ? Colors.green.shade700 : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementRow({
    required String title,
    required double allocated,
    required TextEditingController controller,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('Allocated: ${_currencyFormat.format(allocated)}'),
      trailing: SizedBox(
        width: 150,
        child: TextFormField(
          controller: controller,
          readOnly: true,
          showCursor: true,
          decoration: const InputDecoration(
            labelText: 'Enter Expense',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () {
            setState(() {
              _isKeyboardVisible = true;
              _activeController = controller;
            });
          },
        ),
      ),
    );
  }
}

class _CalculatorKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onEquals;

  const _CalculatorKeyboard({
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    required this.onEquals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('('),
              _buildKey(')'),
              _buildKey('C', onAction: onClear, isFunction: true),
              _buildKey(
                '⌫',
                onAction: onBackspace,
                isFunction: true,
                icon: Icons.backspace_outlined,
              ),
            ],
          ),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildKey('÷', onAction: () => onKeyPress('/'), isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
              _buildKey('×', onAction: () => onKeyPress('*'), isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('-', isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('.'),
              _buildKey('0'),
              _buildKey(
                '=',
                onAction: onEquals,
                isFunction: true,
                isEquals: true,
              ),
              _buildKey('+', isFunction: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    String text, {
    VoidCallback? onAction,
    bool isFunction = false,
    bool isEquals = false,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: isEquals
            ? FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: () =>
                    onAction != null ? onAction() : onKeyPress(text),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: isFunction
                      ? Colors.cyanAccent.shade400
                      : Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                child: icon != null
                    ? Icon(icon, size: 20)
                    : Text(
                        text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ),
    );
  }
}
