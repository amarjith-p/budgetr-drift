import 'package:flutter/material.dart';
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
            DateFilterRow(
              selectedYear: _selectedYear,
              selectedMonth: _selectedMonth,
              availableYears: _availableYears,
              availableMonths: _availableMonthsForYear,
              onYearSelected: _onYearSelected,
              onMonthSelected: (val) => setState(() => _selectedMonth = val),
              showRefresh: false,
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
        heroTag: 'settlement_fab',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildSettlementTable(_settlementData!),
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
  final _settlementService = SettlementService();
  final _dashboardService = DashboardService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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

  // NEW: Logic to find the next controller in order and focus it
  void _handleNext() {
    if (_activeController == null) return;

    // Use the sorted list logic to determine order
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

    // Find index of current active controller
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
      _closeKeyboard(); // Close if last field
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
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
              const SizedBox(width: 12),
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
                    onClose: _closeKeyboard, // WIRED
                    onSwitchToSystem: _switchToSystemKeyboard, // WIRED
                    onNext: _handleNext, // WIRED
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm() {
    final totalBalance = _budgetRecord!.effectiveIncome - _totalExpense;
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
      child: ListView(
        children: [
          ...entries.map((entry) {
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
    if (!_focusNodes.containsKey(title)) _focusNodes[title] = FocusNode();
    final focusNode = _focusNodes[title]!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('Allocated: ${_currencyFormat.format(allocated)}'),
      trailing: SizedBox(
        width: 150,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: !_useSystemKeyboard, // Uses system keyboard flag
          showCursor: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter Expense',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () => _setActive(controller, focusNode),
        ),
      ),
    );
  }
}
