import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/models/net_worth_model.dart';
import '../../../core/services/firestore_service.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
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
      appBar: AppBar(title: const Text('Net Worth Tracker')),
      body: StreamBuilder<List<NetWorthRecord>>(
        stream: _firestoreService.getNetWorthRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var records = snapshot.data ?? [];

          // 1. Sort Chronologically for Calculation (Oldest first)
          records.sort((a, b) => a.date.compareTo(b.date));

          // 2. Prepare Display Data (Calculate differences)
          List<Map<String, dynamic>> processedData = [];
          for (int i = 0; i < records.length; i++) {
            double diff = 0;
            if (i > 0) {
              diff = records[i].amount - records[i - 1].amount;
            }
            processedData.add({'record': records[i], 'diff': diff});
          }

          // 3. Apply Filters
          List<Map<String, dynamic>> filteredData = processedData.where((data) {
            final record = data['record'] as NetWorthRecord;
            bool matchesYear =
                _filterYear == null || record.date.year == _filterYear;
            bool matchesMonth =
                _filterMonth == null || record.date.month == _filterMonth;
            return matchesYear && matchesMonth;
          }).toList();

          // 4. Reverse for List Display (Newest first)
          // FIX: Explicitly specify the type <Map<String, dynamic>>
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
                      if (filteredData.isNotEmpty)
                        _buildChart(
                          filteredData,
                        ), // Pass chronological data to chart
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
        onPressed: () => _showAddRecordSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildFilters(List<NetWorthRecord> allRecords) {
    // Extract available years
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Descending

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _filterYear,
              decoration: _inputDecoration('Year'),
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
              decoration: _inputDecoration('Month'),
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
    if (chronologicalData.isEmpty) return const SizedBox.shrink();

    // Prepare spots
    List<FlSpot> spots = [];
    for (int i = 0; i < chronologicalData.length; i++) {
      final record = chronologicalData[i]['record'] as NetWorthRecord;
      spots.add(FlSpot(i.toDouble(), record.amount));
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 0),
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
                    final record =
                        chronologicalData[index]['record'] as NetWorthRecord;
                    // Show compact date
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM dd').format(record.date),
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
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compactCurrency(symbol: '₹').format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
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

          Color diffColor = Colors.grey;
          if (diff > 0) diffColor = Colors.greenAccent;
          if (diff < 0) diffColor = Colors.redAccent;

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

  InputDecoration _inputDecoration(String label) {
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

  void _showAddRecordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddNetWorthSheet(),
    );
  }
}

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final record = NetWorthRecord(
      id: '', // Firestore will gen ID if we use .add
      date: _selectedDate,
      amount: amount,
    );

    await _firestoreService.addNetWorthRecord(record);
    if (mounted) Navigator.pop(context);
  }

  // Keyboard Handlers
  void _handleKeyPress(String value) {
    final text = _amountController.text;
    final selection = _amountController.selection;
    // Handle case where selection is -1 (no focus/selection)
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, value);
    _amountController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  void _handleBackspace() {
    final text = _amountController.text;
    final selection = _amountController.selection;
    int start = selection.start >= 0 ? selection.start : text.length;

    if (start > 0) {
      final newText = text.replaceRange(start - 1, start, '');
      _amountController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
    }
  }

  void _handleClear() => _amountController.clear();

  void _handleEquals() {
    String expression = _amountController.text
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      _amountController.text = result.toStringAsFixed(2);
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    } catch (e) {
      // Ignore errors
    }
  }

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
                Text(
                  'Add Net Worth',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Date Picker
                InkWell(
                  onTap: _pickDate,
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
                        Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Field
                TextFormField(
                  controller: _amountController,
                  readOnly: true, // Use Custom Keyboard
                  showCursor: true,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount in Hand',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  onTap: () {
                    setState(() => _isKeyboardVisible = true);
                  },
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Record'),
                  ),
                ),
              ],
            ),
          ),

          // Custom Keyboard
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
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
}

// Reusing the Keyboard Widget Logic locally
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
