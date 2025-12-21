import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/widgets/date_filter_row.dart';
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';
// import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../services/net_worth_service.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  // ... (Code remains same as before)
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Net Worth & Analysis'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Total Net Worth'),
              Tab(text: 'Splits Analysis'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_NetWorthTab(), _NetWorthSplitsTab()],
        ),
      ),
    );
  }
}

// ... (_NetWorthTab, _NetWorthTabState, _NetWorthSplitsTab, _NetWorthSplitsTabState remain unchanged)
// JUST ensure _NetWorthTabState uses _AddNetWorthSheet and _NetWorthSplitsTabState uses _AddNetWorthSplitSheet correctly.
// I will paste the Tab classes briefly to maintain context, but the heavy lifting is in the Sheets below.

// -----------------------------------------------------------------------------
// TAB 1: TOTAL NET WORTH (Copy logic from previous, but focusing on SHEETS below)
// -----------------------------------------------------------------------------
class _NetWorthTab extends StatefulWidget {
  const _NetWorthTab();
  @override
  State<_NetWorthTab> createState() => _NetWorthTabState();
}

class _NetWorthTabState extends State<_NetWorthTab> {
  final _netWorthService = NetWorthService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  int? _filterYear;
  int? _filterMonth;

  Future<void> _deleteRecord(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Record?'),
            content: const Text(
              'Are you sure you want to delete this record? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) await _netWorthService.deleteNetWorthRecord(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<NetWorthRecord>>(
        stream: _netWorthService.getNetWorthRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          var records = snapshot.data ?? [];
          records.sort((a, b) => a.date.compareTo(b.date));

          List<Map<String, dynamic>> processedData = [];
          for (int i = 0; i < records.length; i++) {
            double diff = (i > 0)
                ? records[i].amount - records[i - 1].amount
                : 0;
            processedData.add({'record': records[i], 'diff': diff});
          }
          List<Map<String, dynamic>> filteredData = processedData.where((data) {
            final record = data['record'] as NetWorthRecord;
            bool matchesYear =
                _filterYear == null || record.date.year == _filterYear;
            bool matchesMonth =
                _filterMonth == null || record.date.month == _filterMonth;
            return matchesYear && matchesMonth;
          }).toList();
          final displayList = List<Map<String, dynamic>>.from(
            filteredData.reversed,
          );

          return Column(
            children: [
              _buildModernFilters(records),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      if (filteredData.isNotEmpty) _buildChart(filteredData),
                      const SizedBox(height: 20),
                      _buildTable(displayList),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'net_worth_fab',
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const _AddNetWorthSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Total'),
      ),
    );
  }

  Widget _buildModernFilters(List<NetWorthRecord> allRecords) {
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DateFilterRow(
        selectedYear: _filterYear,
        selectedMonth: _filterMonth,
        availableYears: years,
        availableMonths: List.generate(12, (i) => i + 1),
        onYearSelected: (val) => setState(() {
          _filterYear = val;
          if (val == null) _filterMonth = null;
        }),
        onMonthSelected: (val) => setState(() => _filterMonth = val),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chronologicalData) {
    List<FlSpot> spots = [];
    for (int i = 0; i < chronologicalData.length; i++) {
      final record = chronologicalData[i]['record'] as NetWorthRecord;
      spots.add(FlSpot(i.toDouble(), record.amount));
    }
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(right: 16, top: 16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < chronologicalData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM dd').format(
                          (chronologicalData[index]['record'] as NetWorthRecord)
                              .date,
                        ),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(
                  NumberFormat.compactCurrency(symbol: '₹').format(value),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> displayList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(
            label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Net Worth',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Difference',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: displayList.map((data) {
          final record = data['record'] as NetWorthRecord;
          final diff = data['diff'] as double;
          Color diffColor = diff > 0
              ? Colors.greenAccent
              : (diff < 0 ? Colors.redAccent : Colors.grey);
          return DataRow(
            cells: [
              DataCell(Text(_dateFormat.format(record.date))),
              DataCell(Text(_currencyFormat.format(record.amount))),
              DataCell(
                Text(
                  (diff > 0 ? '+' : '') + _currencyFormat.format(diff),
                  style: TextStyle(
                    color: diffColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _deleteRecord(record.id),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: SPLITS ANALYSIS (Same Logic)
// -----------------------------------------------------------------------------
class _NetWorthSplitsTab extends StatefulWidget {
  const _NetWorthSplitsTab();
  @override
  State<_NetWorthSplitsTab> createState() => _NetWorthSplitsTabState();
}

class _NetWorthSplitsTabState extends State<_NetWorthSplitsTab> {
  final NetWorthService _netWorthService = NetWorthService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  int? _filterYear;
  int? _filterMonth;

  Future<void> _deleteSplit(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Record?'),
            content: const Text(
              'Are you sure you want to delete this split record?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) await _netWorthService.deleteNetWorthSplit(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<NetWorthSplit>>(
        stream: _netWorthService.getNetWorthSplits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          var records = snapshot.data ?? [];
          var filteredRecords = records.where((record) {
            bool matchesYear =
                _filterYear == null || record.date.year == _filterYear;
            bool matchesMonth =
                _filterMonth == null || record.date.month == _filterMonth;
            return matchesYear && matchesMonth;
          }).toList();

          return Column(
            children: [
              _buildModernFilters(records),
              Expanded(
                child: filteredRecords.isEmpty
                    ? const Center(child: Text('No split records found'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 80,
                          left: 16,
                          right: 16,
                        ),
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          final split = filteredRecords[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dateFormat.format(split.date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: split.effectiveSavings >= 0
                                                  ? Colors.green.withOpacity(
                                                      0.2,
                                                    )
                                                  : Colors.red.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Savings: ${_currencyFormat.format(split.effectiveSavings)}',
                                              style: TextStyle(
                                                color:
                                                    split.effectiveSavings >= 0
                                                    ? Colors.greenAccent
                                                    : Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _deleteSplit(split.id),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _row(
                                    'Effective Income',
                                    split.effectiveIncome,
                                    Colors.blueAccent,
                                  ),
                                  _row(
                                    'Effective Expense',
                                    split.effectiveExpense,
                                    Colors.orangeAccent,
                                  ),
                                  const SizedBox(height: 12),
                                  ExpansionTile(
                                    title: const Text(
                                      'View Breakdown',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    tilePadding: EdgeInsets.zero,
                                    children: [
                                      _detailRow('Net Income', split.netIncome),
                                      _detailRow(
                                        'Capital Gain',
                                        split.capitalGain,
                                      ),
                                      _detailRow(
                                        'Non-Calc Income',
                                        split.nonCalcIncome,
                                      ),
                                      const Divider(),
                                      _detailRow(
                                        'Net Expense',
                                        split.netExpense,
                                      ),
                                      _detailRow(
                                        'Capital Loss',
                                        split.capitalLoss,
                                      ),
                                      _detailRow(
                                        'Non-Calc Expense',
                                        split.nonCalcExpense,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'net_worth_split_fab',
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const _AddNetWorthSplitSheet(),
        ),
        icon: const Icon(Icons.playlist_add),
        label: const Text('Add Split'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  Widget _buildModernFilters(List<NetWorthSplit> allRecords) {
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DateFilterRow(
        selectedYear: _filterYear,
        selectedMonth: _filterMonth,
        availableYears: years,
        availableMonths: List.generate(12, (i) => i + 1),
        onYearSelected: (val) => setState(() {
          _filterYear = val;
          if (val == null) _filterMonth = null;
        }),
        onMonthSelected: (val) => setState(() => _filterMonth = val),
      ),
    );
  }

  Widget _row(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            _currencyFormat.format(amount),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UPDATED: ADD SHEET FOR TOTAL NET WORTH
// -----------------------------------------------------------------------------
class _AddNetWorthSheet extends StatefulWidget {
  const _AddNetWorthSheet();
  @override
  State<_AddNetWorthSheet> createState() => _AddNetWorthSheetState();
}

class _AddNetWorthSheetState extends State<_AddNetWorthSheet> {
  final _netWorthService = NetWorthService();
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode(); // NEW
  DateTime _selectedDate = DateTime.now();

  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false; // NEW

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;
    await _netWorthService.addNetWorthRecord(
      NetWorthRecord(id: '', date: _selectedDate, amount: amount),
    );
    if (mounted) Navigator.pop(context);
  }

  // KEYBOARD LOGIC
  void _activate(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _isKeyboardVisible = !_useSystemKeyboard;
      if (_useSystemKeyboard) {
        FocusScope.of(context).requestFocus(node);
      }
    });
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystem() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).requestFocus(_amountFocus);
  }

  @override
  Widget build(BuildContext context) {
    return _BaseInputSheet(
      title: 'Add Total Net Worth',
      date: _selectedDate,
      onDatePick: (d) => setState(() => _selectedDate = d),
      onSave: _save,
      isKeyboardVisible: _isKeyboardVisible,
      // Pass the new logic here
      activeController: _amountController,
      onClose: _closeKeyboard,
      onSwitchSystem: _switchToSystem,
      children: [
        _buildTextField(
          context,
          'Total Amount in Hand',
          _amountController,
          _amountFocus, // Pass FocusNode
          () => _activate(_amountController, _amountFocus),
          _useSystemKeyboard,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// UPDATED: ADD SHEET FOR NET WORTH SPLITS
// -----------------------------------------------------------------------------
class _AddNetWorthSplitSheet extends StatefulWidget {
  const _AddNetWorthSplitSheet();
  @override
  State<_AddNetWorthSplitSheet> createState() => _AddNetWorthSplitSheetState();
}

class _AddNetWorthSplitSheetState extends State<_AddNetWorthSplitSheet> {
  final _netWorthService = NetWorthService();

  final _netIncomeCtrl = TextEditingController();
  final _netExpenseCtrl = TextEditingController();
  final _capGainCtrl = TextEditingController();
  final _capLossCtrl = TextEditingController();
  final _nonCalcIncomeCtrl = TextEditingController();
  final _nonCalcExpenseCtrl = TextEditingController();

  // Focus Nodes
  final _netIncomeFocus = FocusNode();
  final _netExpenseFocus = FocusNode();
  final _capGainFocus = FocusNode();
  final _capLossFocus = FocusNode();
  final _nonCalcIncomeFocus = FocusNode();
  final _nonCalcExpenseFocus = FocusNode();

  // List for "Next" navigation
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  TextEditingController? _activeCtrl;
  FocusNode? _activeFocus; // Track active focus

  DateTime _selectedDate = DateTime.now();
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = [
      _netIncomeFocus,
      _netExpenseFocus,
      _capGainFocus,
      _capLossFocus,
      _nonCalcIncomeFocus,
      _nonCalcExpenseFocus,
    ];
    _controllers = [
      _netIncomeCtrl,
      _netExpenseCtrl,
      _capGainCtrl,
      _capLossCtrl,
      _nonCalcIncomeCtrl,
      _nonCalcExpenseCtrl,
    ];
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeCtrl = ctrl;
      _activeFocus = node;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        // Request focus to show cursor
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystem() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    if (_activeFocus != null) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).requestFocus(_activeFocus);
      });
    }
  }

  void _handleNext() {
    if (_activeFocus == null) return;
    int index = _focusNodes.indexOf(_activeFocus!);
    if (index != -1 && index < _focusNodes.length - 1) {
      // Move to next
      _setActive(_controllers[index + 1], _focusNodes[index + 1]);
    } else {
      // Done or Last field
      _closeKeyboard();
    }
  }

  Future<void> _save() async {
    await _netWorthService.addNetWorthSplit(
      NetWorthSplit(
        id: '',
        date: _selectedDate,
        netIncome: double.tryParse(_netIncomeCtrl.text) ?? 0,
        netExpense: double.tryParse(_netExpenseCtrl.text) ?? 0,
        capitalGain: double.tryParse(_capGainCtrl.text) ?? 0,
        capitalLoss: double.tryParse(_capLossCtrl.text) ?? 0,
        nonCalcIncome: double.tryParse(_nonCalcIncomeCtrl.text) ?? 0,
        nonCalcExpense: double.tryParse(_nonCalcExpenseCtrl.text) ?? 0,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BaseInputSheet(
      title: 'Add Net Worth Splits',
      date: _selectedDate,
      onDatePick: (d) => setState(() => _selectedDate = d),
      onSave: _save,
      isKeyboardVisible: _isKeyboardVisible,
      activeController: _activeCtrl,
      onClose: _closeKeyboard,
      onSwitchSystem: _switchToSystem,
      onNext: _handleNext,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                'Net Income',
                _netIncomeCtrl,
                _netIncomeFocus,
                () => _setActive(_netIncomeCtrl, _netIncomeFocus),
                _useSystemKeyboard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Net Expense',
                _netExpenseCtrl,
                _netExpenseFocus,
                () => _setActive(_netExpenseCtrl, _netExpenseFocus),
                _useSystemKeyboard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                'Capital Gain',
                _capGainCtrl,
                _capGainFocus,
                () => _setActive(_capGainCtrl, _capGainFocus),
                _useSystemKeyboard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Capital Loss',
                _capLossCtrl,
                _capLossFocus,
                () => _setActive(_capLossCtrl, _capLossFocus),
                _useSystemKeyboard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                'Non-Calc Income',
                _nonCalcIncomeCtrl,
                _nonCalcIncomeFocus,
                () => _setActive(_nonCalcIncomeCtrl, _nonCalcIncomeFocus),
                _useSystemKeyboard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Non-Calc Expense',
                _nonCalcExpenseCtrl,
                _nonCalcExpenseFocus,
                () => _setActive(_nonCalcExpenseCtrl, _nonCalcExpenseFocus),
                _useSystemKeyboard,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// UPDATED: SHARED HELPERS & WIDGETS
// -----------------------------------------------------------------------------
Widget _buildTextField(
  BuildContext context,
  String label,
  TextEditingController ctrl,
  FocusNode focusNode, // Added FocusNode
  VoidCallback onTap,
  bool useSystemKeyboard, // Added flag
) {
  return TextFormField(
    controller: ctrl,
    focusNode: focusNode,
    readOnly: !useSystemKeyboard, // Controlled by flag
    showCursor: true,
    keyboardType:
        TextInputType.number, // Enable numeric pad for system keyboard
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      prefixText: '₹ ',
    ),
  );
}

class _BaseInputSheet extends StatelessWidget {
  final String title;
  final DateTime date;
  final Function(DateTime) onDatePick;
  final VoidCallback onSave;
  final bool isKeyboardVisible;
  final TextEditingController? activeController; // Changed from tuple
  final VoidCallback onClose;
  final VoidCallback onSwitchSystem;
  final VoidCallback? onNext; // Added Next callback
  final List<Widget> children;

  const _BaseInputSheet({
    required this.title,
    required this.date,
    required this.onDatePick,
    required this.onSave,
    required this.isKeyboardVisible,
    this.activeController,
    required this.onClose,
    required this.onSwitchSystem,
    this.onNext,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) onDatePick(d);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(DateFormat('dd MMMM yyyy').format(date)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...children,
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSave,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Record'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: isKeyboardVisible && activeController != null
                ? CalculatorKeyboard(
                    onKeyPress: (val) => CalculatorKeyboard.handleKeyPress(
                      activeController!,
                      val,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(activeController!),
                    onClear: () => activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(activeController!),
                    onClose: onClose,
                    onSwitchToSystem: onSwitchSystem,
                    onNext: onNext,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
