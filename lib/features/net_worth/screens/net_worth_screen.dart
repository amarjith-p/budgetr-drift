import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';
import '../../../core/services/firestore_service.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
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

// -----------------------------------------------------------------------------
// TAB 1: TOTAL NET WORTH (Original Functionality)
// -----------------------------------------------------------------------------
class _NetWorthTab extends StatefulWidget {
  const _NetWorthTab();

  @override
  State<_NetWorthTab> createState() => _NetWorthTabState();
}

class _NetWorthTabState extends State<_NetWorthTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  int? _filterYear;
  int? _filterMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<NetWorthRecord>>(
        stream: _firestoreService.getNetWorthRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          var records = snapshot.data ?? [];
          records.sort(
            (a, b) => a.date.compareTo(b.date),
          ); // Sort Oldest first for chart

          // Prepare Data
          List<Map<String, dynamic>> processedData = [];
          for (int i = 0; i < records.length; i++) {
            double diff = (i > 0)
                ? records[i].amount - records[i - 1].amount
                : 0;
            processedData.add({'record': records[i], 'diff': diff});
          }

          // Apply Filters
          List<Map<String, dynamic>> filteredData = processedData.where((data) {
            final record = data['record'] as NetWorthRecord;
            bool matchesYear =
                _filterYear == null || record.date.year == _filterYear;
            bool matchesMonth =
                _filterMonth == null || record.date.month == _filterMonth;
            return matchesYear && matchesMonth;
          }).toList();

          // Prepare Display List (Newest First)
          final displayList = List<Map<String, dynamic>>.from(
            filteredData.reversed,
          );

          return Column(
            children: [
              _buildFilters(records),
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

  Widget _buildFilters(List<NetWorthRecord> allRecords) {
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _filterYear,
              decoration: _inputDecoration(context, 'Year'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Time'),
                ),
                ...years.map(
                  (y) => DropdownMenuItem(value: y, child: Text('$y')),
                ),
              ],
              onChanged: (val) => setState(() {
                _filterYear = val;
                if (val == null) _filterMonth = null;
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _filterMonth,
              decoration: _inputDecoration(context, 'Month'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Months'),
                ),
                ...List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      DateFormat('MMMM').format(DateTime(0, index + 1)),
                    ),
                  ),
                ),
              ],
              onChanged: _filterYear == null
                  ? null
                  : (val) => setState(() => _filterMonth = val),
            ),
          ),
        ],
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
            ],
          );
        }).toList(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: SPLITS ANALYSIS (New Feature)
// -----------------------------------------------------------------------------
class _NetWorthSplitsTab extends StatefulWidget {
  const _NetWorthSplitsTab();

  @override
  State<_NetWorthSplitsTab> createState() => _NetWorthSplitsTabState();
}

class _NetWorthSplitsTabState extends State<_NetWorthSplitsTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  int? _filterYear;
  int? _filterMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<NetWorthSplit>>(
        stream: _firestoreService.getNetWorthSplits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          var records = snapshot.data ?? [];

          // Filters
          var filteredRecords = records.where((record) {
            bool matchesYear =
                _filterYear == null || record.date.year == _filterYear;
            bool matchesMonth =
                _filterMonth == null || record.date.month == _filterMonth;
            return matchesYear && matchesMonth;
          }).toList();

          return Column(
            children: [
              _buildFilters(records),
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: split.effectiveSavings >= 0
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Savings: ${_currencyFormat.format(split.effectiveSavings)}',
                                          style: TextStyle(
                                            color: split.effectiveSavings >= 0
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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

  Widget _buildFilters(List<NetWorthSplit> allRecords) {
    // Unique years
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _filterYear,
              decoration: _inputDecoration(context, 'Year'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Time'),
                ),
                ...years.map(
                  (y) => DropdownMenuItem(value: y, child: Text('$y')),
                ),
              ],
              onChanged: (val) => setState(() {
                _filterYear = val;
                if (val == null) _filterMonth = null;
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _filterMonth,
              decoration: _inputDecoration(context, 'Month'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Months'),
                ),
                ...List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      DateFormat('MMMM').format(DateTime(0, index + 1)),
                    ),
                  ),
                ),
              ],
              onChanged: _filterYear == null
                  ? null
                  : (val) => setState(() => _filterMonth = val),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD SHEET: TOTAL NET WORTH
// -----------------------------------------------------------------------------
class _AddNetWorthSheet extends StatefulWidget {
  const _AddNetWorthSheet();
  @override
  State<_AddNetWorthSheet> createState() => _AddNetWorthSheetState();
}

class _AddNetWorthSheetState extends State<_AddNetWorthSheet> {
  final _firestoreService = FirestoreService();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isKeyboardVisible = false;

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;
    await _firestoreService.addNetWorthRecord(
      NetWorthRecord(id: '', date: _selectedDate, amount: amount),
    );
    if (mounted) Navigator.pop(context);
  }

  // Keyboard Handlers Reuse Logic
  void _onKey(String val) => _handleKeyPress(_amountController, val);
  void _onBack() => _handleBackspace(_amountController);
  void _onClear() => _amountController.clear();
  void _onEq() => _handleEquals(_amountController);

  @override
  Widget build(BuildContext context) {
    return _BaseInputSheet(
      title: 'Add Total Net Worth',
      date: _selectedDate,
      onDatePick: (d) => setState(() => _selectedDate = d),
      onSave: _save,
      isKeyboardVisible: _isKeyboardVisible,
      keyboardCallbacks: (_onKey, _onBack, _onClear, _onEq),
      children: [
        _buildTextField(
          context,
          'Total Amount in Hand',
          _amountController,
          () => setState(() => _isKeyboardVisible = true),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ADD SHEET: NET WORTH SPLITS
// -----------------------------------------------------------------------------
class _AddNetWorthSplitSheet extends StatefulWidget {
  const _AddNetWorthSplitSheet();
  @override
  State<_AddNetWorthSplitSheet> createState() => _AddNetWorthSplitSheetState();
}

class _AddNetWorthSplitSheetState extends State<_AddNetWorthSplitSheet> {
  final _firestoreService = FirestoreService();

  final _netIncomeCtrl = TextEditingController();
  final _netExpenseCtrl = TextEditingController();
  final _capGainCtrl = TextEditingController();
  final _capLossCtrl = TextEditingController();
  final _nonCalcIncomeCtrl = TextEditingController();
  final _nonCalcExpenseCtrl = TextEditingController();

  TextEditingController? _activeCtrl;
  DateTime _selectedDate = DateTime.now();
  bool _isKeyboardVisible = false;

  void _setActive(TextEditingController ctrl) {
    setState(() {
      _activeCtrl = ctrl;
      _isKeyboardVisible = true;
    });
  }

  Future<void> _save() async {
    await _firestoreService.addNetWorthSplit(
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

  // Keyboard Handlers
  void _onKey(String val) {
    if (_activeCtrl != null) _handleKeyPress(_activeCtrl!, val);
  }

  void _onBack() {
    if (_activeCtrl != null) _handleBackspace(_activeCtrl!);
  }

  void _onClear() {
    _activeCtrl?.clear();
  }

  void _onEq() {
    if (_activeCtrl != null) _handleEquals(_activeCtrl!);
  }

  @override
  Widget build(BuildContext context) {
    return _BaseInputSheet(
      title: 'Add Net Worth Splits',
      date: _selectedDate,
      onDatePick: (d) => setState(() => _selectedDate = d),
      onSave: _save,
      isKeyboardVisible: _isKeyboardVisible,
      keyboardCallbacks: (_onKey, _onBack, _onClear, _onEq),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                'Net Income',
                _netIncomeCtrl,
                () => _setActive(_netIncomeCtrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Net Expense',
                _netExpenseCtrl,
                () => _setActive(_netExpenseCtrl),
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
                () => _setActive(_capGainCtrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Capital Loss',
                _capLossCtrl,
                () => _setActive(_capLossCtrl),
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
                () => _setActive(_nonCalcIncomeCtrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                'Non-Calc Expense',
                _nonCalcExpenseCtrl,
                () => _setActive(_nonCalcExpenseCtrl),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED UTILS & WIDGETS
// -----------------------------------------------------------------------------

InputDecoration _inputDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _buildTextField(
  BuildContext context,
  String label,
  TextEditingController ctrl,
  VoidCallback onTap,
) {
  return TextFormField(
    controller: ctrl,
    readOnly: true,
    showCursor: true,
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
  final (Function(String), VoidCallback, VoidCallback, VoidCallback)
  keyboardCallbacks;
  final List<Widget> children;

  const _BaseInputSheet({
    required this.title,
    required this.date,
    required this.onDatePick,
    required this.onSave,
    required this.isKeyboardVisible,
    required this.keyboardCallbacks,
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
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
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: isKeyboardVisible
                ? _CalculatorKeyboard(
                    onKeyPress: keyboardCallbacks.$1,
                    onBackspace: keyboardCallbacks.$2,
                    onClear: keyboardCallbacks.$3,
                    onEquals: keyboardCallbacks.$4,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIC HELPERS
// -----------------------------------------------------------------------------
void _handleKeyPress(TextEditingController ctrl, String value) {
  final text = ctrl.text;
  final selection = ctrl.selection;
  int start = selection.start >= 0 ? selection.start : text.length;
  int end = selection.end >= 0 ? selection.end : text.length;
  final newText = text.replaceRange(start, end, value);
  ctrl.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + value.length),
  );
}

void _handleBackspace(TextEditingController ctrl) {
  final text = ctrl.text;
  final selection = ctrl.selection;
  int start = selection.start >= 0 ? selection.start : text.length;
  if (start > 0) {
    final newText = text.replaceRange(start - 1, start, '');
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start - 1),
    );
  }
}

void _handleEquals(TextEditingController ctrl) {
  String expression = ctrl.text.replaceAll('×', '*').replaceAll('÷', '/');
  try {
    Parser p = Parser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);
    ctrl.text = result.toStringAsFixed(2);
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );
  } catch (e) {
    /* ignore */
  }
}

// -----------------------------------------------------------------------------
// CALCULATOR KEYBOARD
// -----------------------------------------------------------------------------
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
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
      child: Column(
        children: [
          Row(
            children: [
              _k('('),
              _k(')'),
              _k('C', a: onClear, f: true),
              _k('⌫', a: onBackspace, f: true, i: Icons.backspace_outlined),
            ],
          ),
          Row(
            children: [
              _k('7'),
              _k('8'),
              _k('9'),
              _k('÷', a: () => onKeyPress('/'), f: true),
            ],
          ),
          Row(
            children: [
              _k('4'),
              _k('5'),
              _k('6'),
              _k('×', a: () => onKeyPress('*'), f: true),
            ],
          ),
          Row(children: [_k('1'), _k('2'), _k('3'), _k('-', f: true)]),
          Row(
            children: [
              _k('.'),
              _k('0'),
              _k('=', a: onEquals, f: true, e: true),
              _k('+', f: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _k(
    String t, {
    VoidCallback? a,
    bool f = false,
    bool e = false,
    IconData? i,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: e
            ? FilledButton(
                onPressed: a,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: () => a != null ? a() : onKeyPress(t),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: f
                      ? Colors.cyanAccent.shade400
                      : Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                child: i != null
                    ? Icon(i, size: 20)
                    : Text(
                        t,
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
