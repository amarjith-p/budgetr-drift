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
                Expanded(child: _buildYearDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildMonthDropdown()),
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

  InputDecoration _modernDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: _modernDropdownDecoration('Year'),
      items: _availableYears
          .map(
            (year) =>
                DropdownMenuItem(value: year, child: Text(year.toString())),
          )
          .toList(),
      onChanged: _onYearSelected,
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: _modernDropdownDecoration('Month'),
      onChanged: _selectedYear == null
          ? null
          : (value) => setState(() => _selectedMonth = value),
      items: _availableMonthsForYear
          .map(
            (month) => DropdownMenuItem(
              value: month,
              child: Text(DateFormat('MMMM').format(DateTime(0, month))),
            ),
          )
          .toList(),
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
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _createBarGroups(data),
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
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                final currencyFormat = NumberFormat.compactCurrency(
                  locale: 'en_IN',
                  symbol: '₹',
                );
                return Text(
                  currencyFormat.format(value),
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(fontSize: 12);
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Nec';
                    break;
                  case 1:
                    text = 'LS';
                    break;
                  case 2:
                    text = 'Inv';
                    break;
                  case 3:
                    text = 'Eme';
                    break;
                  case 4:
                    text = 'Buff';
                    break;
                  default:
                    text = '';
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  angle: -0.7,
                  child: Text(text, style: style),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _currencyFormat.format(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
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

  List<BarChartGroupData> _createBarGroups(Settlement data) {
    final allocated = [
      data.necessitiesAllocation,
      data.lifestyleAllocation,
      data.investmentAllocation,
      data.emergencyAllocation,
      data.bufferAllocation,
    ];
    final spent = [
      data.necessitiesExpense,
      data.lifestyleExpense,
      data.investmentExpense,
      data.emergencyExpense,
      data.bufferExpense,
    ];
    return List.generate(
      5,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: allocated[i], color: Colors.blue, width: 16),
          BarChartRodData(toY: spent[i], color: Colors.red, width: 16),
        ],
      ),
    );
  }

  Widget _buildSettlementTable(Settlement data) {
    return DataTable(
      columnSpacing: 24,
      columns: const [
        DataColumn(
          label: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
            'Spent / Balance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
      ],
      rows: [
        _createDataRow(
          'Necessities',
          data.necessitiesAllocation,
          data.necessitiesExpense,
          data.necessitiesBalance,
        ),
        _createDataRow(
          'Lifestyle',
          data.lifestyleAllocation,
          data.lifestyleExpense,
          data.lifestyleBalance,
        ),
        _createDataRow(
          'Investment',
          data.investmentAllocation,
          data.investmentExpense,
          data.investmentBalance,
        ),
        _createDataRow(
          'Emergency',
          data.emergencyAllocation,
          data.emergencyExpense,
          data.emergencyBalance,
        ),
        _createDataRow(
          'Buffer',
          data.bufferAllocation,
          data.bufferExpense,
          data.bufferBalance,
        ),
        // --- Total Row ---
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
      ],
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

  final _controllers = {
    'necessities': TextEditingController(),
    'lifestyle': TextEditingController(),
    'investment': TextEditingController(),
    'emergency': TextEditingController(),
    'buffer': TextEditingController(),
  };
  double _totalExpense = 0.0;

  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _controllers.values.forEach(
      (controller) => controller.addListener(_calculateTotalExpense),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
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
    final results = await Future.wait([
      _firestoreService.getRecordById(recordId),
      _firestoreService.getSettlementById(recordId),
    ]);
    setState(() {
      _budgetRecord = results[0] as FinancialRecord;
      _existingSettlement = results[1] as Settlement?;
      if (_existingSettlement != null) {
        _controllers['necessities']!.text = _existingSettlement!
            .necessitiesExpense
            .toString();
        _controllers['lifestyle']!.text = _existingSettlement!.lifestyleExpense
            .toString();
        _controllers['investment']!.text = _existingSettlement!
            .investmentExpense
            .toString();
        _controllers['emergency']!.text = _existingSettlement!.emergencyExpense
            .toString();
        _controllers['buffer']!.text = _existingSettlement!.bufferExpense
            .toString();
      } else {
        _controllers.values.forEach((c) => c.clear());
      }
      _calculateTotalExpense();
    });
  }

  void _calculateTotalExpense() {
    final nec = double.tryParse(_controllers['necessities']!.text) ?? 0.0;
    final life = double.tryParse(_controllers['lifestyle']!.text) ?? 0.0;
    // final inv = double.tryParse(_controllers['investment']!.text) ?? 0.0;
    final emer = double.tryParse(_controllers['emergency']!.text) ?? 0.0;
    final buff = double.tryParse(_controllers['buffer']!.text) ?? 0.0;
    setState(() => _totalExpense = (nec + life + emer + buff));
  }

  Future<void> _onSettle() async {
    if (_budgetRecord == null) return;
    final settlement = Settlement(
      id: _budgetRecord!.id,
      year: _budgetRecord!.year,
      month: _budgetRecord!.month,
      necessitiesAllocation: _budgetRecord!.necessities,
      lifestyleAllocation: _budgetRecord!.lifestyle,
      investmentAllocation: _budgetRecord!.investment,
      emergencyAllocation: _budgetRecord!.emergency,
      bufferAllocation: _budgetRecord!.buffer,
      necessitiesExpense:
          double.tryParse(_controllers['necessities']!.text) ?? 0.0,
      lifestyleExpense: double.tryParse(_controllers['lifestyle']!.text) ?? 0.0,
      investmentExpense:
          double.tryParse(_controllers['investment']!.text) ?? 0.0,
      emergencyExpense: double.tryParse(_controllers['emergency']!.text) ?? 0.0,
      bufferExpense: double.tryParse(_controllers['buffer']!.text) ?? 0.0,
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

    String expression = _activeController!.text;
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');

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
        SnackBar(
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
              Expanded(child: _buildYearDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildMonthDropdown()),
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

  InputDecoration _modernDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: _modernDropdownDecoration('Year'),
      items: _availableYears
          .map(
            (year) =>
                DropdownMenuItem(value: year, child: Text(year.toString())),
          )
          .toList(),
      onChanged: _onYearSelected,
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: _modernDropdownDecoration('Month'),
      onChanged: _selectedYear == null
          ? null
          : (value) => setState(() => _selectedMonth = value),
      items: _availableMonthsForYear
          .map(
            (month) => DropdownMenuItem(
              value: month,
              child: Text(DateFormat('MMMM').format(DateTime(0, month))),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSettlementForm() {
    final totalBalance = _budgetRecord!.effectiveIncome - _totalExpense;
    return GestureDetector(
      onTap: () => setState(() => _isKeyboardVisible = false),
      child: ListView(
        children: [
          _buildSettlementRow(
            title: 'Necessities',
            allocated: _budgetRecord!.necessities,
            controller: _controllers['necessities']!,
          ),
          _buildSettlementRow(
            title: 'Lifestyle',
            allocated: _budgetRecord!.lifestyle,
            controller: _controllers['lifestyle']!,
          ),
          _buildSettlementRow(
            title: 'Investment',
            allocated: _budgetRecord!.investment,
            controller: _controllers['investment']!,
          ),
          _buildSettlementRow(
            title: 'Emergency',
            allocated: _budgetRecord!.emergency,
            controller: _controllers['emergency']!,
          ),
          _buildSettlementRow(
            title: 'Buffer',
            allocated: _budgetRecord!.buffer,
            controller: _controllers['buffer']!,
          ),
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
            labelText: 'Enter Calculation',
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
